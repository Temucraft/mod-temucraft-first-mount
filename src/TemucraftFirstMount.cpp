/*
 * mod-temucraft-first-mount: takes the borrowed mount away when its quest leaves the log.
 *
 * The quests, the borrowed mount items and where they work are SQL (data/sql). Two things SQL can't do alone:
 *   - abandoning the quest: AzerothCore takes the quest item back, but a borrowed mount you're sitting on stays;
 *   - turning the quest in: the same.
 * Leaving the quest's zones already drops the mount (spell_area).
 * It also gives the slow mount of "An Old Ride" (quest 602130), the one that matches the player's race, as an item
 * that summons it (items 602180-602189). Nobody keeps a borrowed or slow mount as a learned spell: a character who
 * learned one from an older version loses the spell at login and gets the item instead.
 *
 * Each first mount quest is only for its own race: the classic quests for their race, the copies for the custom
 * races for that race. The core turns a race mask with no playable race in it into "every race", which would show
 * every copy to everyone, so the script hides a quest from the wrong races (its level is raised out of reach).
 *
 * The custom races (mod_temucraft_first_mount_races.sql) are read from `temucraft_first_mount_race` at startup:
 * their quests also drop the borrowed mount, and "An Old Ride" teaches them the slow mount of their home race.
 *
 * The Dracthyr ground drakes are optional: with Temucraft.FirstMount.DracthyrDrakes = 0, a drake picked as a quest
 * reward is swapped for the first mount of the home race's quest (the SQL can also leave them out, @DracthyrDrakes).
 * They are only ever for the Dracthyr (races 25 and 26): anyone else who picks one, or already has one, gets the home
 * race's first mount instead, and a first mount quest of another race found in the log at login is removed.
 */

#include "Config.h"
#include "Item.h"
#include "ObjectMgr.h"
#include "Tokenize.h"
#include "DatabaseEnv.h"
#include "Log.h"
#include "Player.h"
#include "QuestDef.h"
#include "ScriptMgr.h"
#include <unordered_map>
#include <unordered_set>

namespace
{
    struct FirstMountSettings
    {
        bool enable = true;
        uint32 questFirst = 602110;
        uint32 spellFirst = 95330;
        uint32 count = 10;
        uint32 slowQuest = 602130;
        uint32 slowSpellFirst = 95340;
        uint32 slowItemFirst = 602180;
        bool dracthyrDrakes = true;
        std::unordered_set<uint32> drakeItems = { 602160, 602161 };
    } settings;

    // custom race -> home index (the classic race whose mounts it uses, same order as the borrowed mounts)
    std::unordered_map<uint8, uint32> raceHome;
    // the quests of the custom races, and the race each one is for
    std::unordered_set<uint32> raceQuests;
    std::unordered_map<uint32, uint8> questRace;

    void LoadRaceTable()
    {
        raceHome.clear();
        raceQuests.clear();
        questRace.clear();

        QueryResult result = WorldDatabase.Query("SELECT `Race`, `HomeIndex`, `Quest` FROM `temucraft_first_mount_race`");
        if (!result)
        {
            LOG_INFO("module", "mod-temucraft-first-mount: no custom races in temucraft_first_mount_race");
            return;
        }

        do
        {
            Field* fields = result->Fetch();
            uint32 home = fields[1].Get<uint8>();
            if (home >= settings.count)
                continue;
            raceHome[fields[0].Get<uint8>()] = home;
            raceQuests.insert(fields[2].Get<uint32>());
            questRace[fields[2].Get<uint32>()] = fields[0].Get<uint8>();
        } while (result->NextRow());

        LOG_INFO("module", "mod-temucraft-first-mount: loaded {} custom races", raceHome.size());
    }

    // the classic race index whose quest a race copies (custom races from the table, others by faction)
    uint32 HomeIndex(Player* player)
    {
        switch (player->getRace())
        {
            case RACE_HUMAN:         return 0;
            case RACE_ORC:           return 1;
            case RACE_DWARF:         return 2;
            case RACE_NIGHTELF:      return 3;
            case RACE_UNDEAD_PLAYER: return 4;
            case RACE_TAUREN:        return 5;
            case RACE_GNOME:         return 6;
            case RACE_TROLL:         return 7;
            case RACE_BLOODELF:      return 8;
            case RACE_DRAENEI:       return 9;
            default:
            {
                auto itr = raceHome.find(player->getRace());
                if (itr != raceHome.end())
                    return itr->second;
                return player->GetTeamId() == TEAM_ALLIANCE ? 0 : 1;
            }
        }
    }

    // the Dracthyr ground drakes are for the Dracthyr (races 25 and 26) only
    bool IsDracthyr(Player const* player)
    {
        return player->getRace() == 25 || player->getRace() == 26;
    }

    // the first mount of the home race's quest that is not a drake (0 = none)
    uint32 HomeReplacement(Player* player)
    {
        Quest const* home = sObjectMgr->GetQuestTemplate(settings.questFirst + HomeIndex(player));
        uint32 replacement = 0;
        for (uint32 i = 0; home && i < QUEST_REWARD_CHOICES_COUNT && !replacement; ++i)
            if (home->RewardChoiceItemId[i] && !settings.drakeItems.count(home->RewardChoiceItemId[i]))
                replacement = home->RewardChoiceItemId[i];
        return replacement && sObjectMgr->GetItemTemplate(replacement) ? replacement : 0;
    }

    void GiveItem(Player* player, uint32 entry)
    {
        ItemPosCountVec dest;
        if (player->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, entry, 1) == EQUIP_ERR_OK)
        {
            if (Item* added = player->StoreNewItem(dest, entry, true))
                player->SendNewItem(added, 1, true, false);
        }
        else
            player->SendItemRetrievalMail(entry, 1);   // bags full: it comes by mail
    }

    // a drake quest reward becomes the first mount of the home race's quest when the drakes are off
    // (DracthyrDrakes = 0) or the player is not a Dracthyr
    void SwapDrake(Player* player, Item* item)
    {
        if (!settings.enable || !item || !settings.drakeItems.count(item->GetEntry()))
            return;
        if (settings.dracthyrDrakes && IsDracthyr(player))
            return;
        uint32 replacement = HomeReplacement(player);
        if (!replacement)
            return;
        player->DestroyItem(item->GetBagSlot(), item->GetSlot(), true);
        GiveItem(player, replacement);
    }

    // "An Old Ride": give the item of the slow mount that matches the race (same order as the borrowed mounts)
    void GiveSlowMount(Player* player)
    {
        if (!settings.slowItemFirst)
            return;
        uint32 item = settings.slowItemFirst + HomeIndex(player);
        if (!sObjectMgr->GetItemTemplate(item) || player->HasItemCount(item, 1, true))
            return;
        ItemPosCountVec dest;
        if (player->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, item, 1) == EQUIP_ERR_OK)
        {
            if (Item* added = player->StoreNewItem(dest, item, true))
                player->SendNewItem(added, 1, true, false);
        }
        else
            player->SendItemRetrievalMail(item, 1);   // bags full: it comes by mail
    }

    void LearnSlowMount(Player* player, uint32 questId)
    {
        if (!settings.enable || !settings.slowQuest || questId != settings.slowQuest)
            return;
        GiveSlowMount(player);
    }

    // a borrowed or slow mount learned as a spell (older versions taught the slow one): take the spell away, and
    // give the slow mount's item instead
    void ForgetMountSpells(Player* player)
    {
        if (!settings.enable)
            return;
        bool hadSlow = false;
        for (uint32 i = 0; i < settings.count; ++i)
        {
            if (player->HasSpell(settings.spellFirst + i))
                player->removeSpell(settings.spellFirst + i, SPEC_MASK_ALL, false);
            if (settings.slowSpellFirst && player->HasSpell(settings.slowSpellFirst + i))
            {
                player->removeSpell(settings.slowSpellFirst + i, SPEC_MASK_ALL, false);
                hadSlow = true;
            }
        }
        if (hadSlow)
            GiveSlowMount(player);
    }

    // the race a first mount quest is for (0 = not one of them)
    uint8 QuestRace(uint32 questId)
    {
        static uint8 const classic[10] = { RACE_HUMAN, RACE_ORC, RACE_DWARF, RACE_NIGHTELF, RACE_UNDEAD_PLAYER,
            RACE_TAUREN, RACE_GNOME, RACE_TROLL, RACE_BLOODELF, RACE_DRAENEI };
        if (questId >= settings.questFirst && questId < settings.questFirst + settings.count && questId - settings.questFirst < 10)
            return classic[questId - settings.questFirst];
        auto itr = questRace.find(questId);
        return itr != questRace.end() ? itr->second : 0;
    }

    // at login: a first mount quest of another race leaves the log (taken while the core still saw races 21-30 as
    // unplayable and so turned their quests' race masks into "every race"), and a non-Dracthyr who already got a drake
    // has it swapped for the home race's first mount
    void FixWrongRace(Player* player)
    {
        if (!settings.enable)
            return;

        for (uint8 slot = 0; slot < MAX_QUEST_LOG_SIZE; ++slot)
        {
            uint32 questId = player->GetQuestSlotQuestId(slot);
            uint8 race = questId ? QuestRace(questId) : 0;
            if (!race || race == player->getRace())
                continue;
            player->SetQuestSlot(slot, 0);
            player->TakeQuestSourceItem(questId, false);
            player->RemoveActiveQuest(questId, false);
            for (uint32 i = 0; i < settings.count; ++i)
                player->RemoveAurasDueToSpell(settings.spellFirst + i);
            LOG_INFO("module", "mod-temucraft-first-mount: removed quest {} (race {}) from {} (race {})",
                questId, race, player->GetName(), player->getRace());
        }

        if (IsDracthyr(player) && settings.dracthyrDrakes)
            return;
        for (uint32 drake : settings.drakeItems)
        {
            // the reins teach the drake (spell 2 of the item): a drake already learned is unlearned too
            bool learned = false;
            if (ItemTemplate const* proto = sObjectMgr->GetItemTemplate(drake))
                if (uint32 spell = proto->Spells[1].SpellId)
                    if (player->HasSpell(spell))
                    {
                        player->removeSpell(spell, SPEC_MASK_ALL, false);
                        learned = true;
                    }
            uint32 count = player->GetItemCount(drake, true);
            if (!count && !learned)
                continue;
            if (count)
                player->DestroyItemCount(drake, count, true, false);
            if (uint32 replacement = HomeReplacement(player))
                if (!player->HasItemCount(replacement, 1, true))
                    GiveItem(player, replacement);
            LOG_INFO("module", "mod-temucraft-first-mount: swapped drake {} of {} (race {})", drake, player->GetName(), player->getRace());
        }
    }

    bool IsBorrowedMountQuest(uint32 questId)
    {
        return (questId >= settings.questFirst && questId < settings.questFirst + settings.count) || raceQuests.count(questId);
    }

    void Dismount(Player* player, uint32 questId)
    {
        if (!settings.enable || !IsBorrowedMountQuest(questId))
            return;
        // the quest of race N goes with the spell of race N; drop any of them to be safe
        for (uint32 i = 0; i < settings.count; ++i)
            player->RemoveAurasDueToSpell(settings.spellFirst + i);
    }
}

class TemucraftFirstMount_Player : public PlayerScript
{
public:
    TemucraftFirstMount_Player() : PlayerScript("TemucraftFirstMount_Player",
        { PLAYERHOOK_ON_QUEST_ABANDON, PLAYERHOOK_ON_QUEST_COMPUTE_EXP, PLAYERHOOK_ON_QUEST_REWARD_ITEM,
          PLAYERHOOK_ON_LOGIN, PLAYERHOOK_ON_GET_QUEST_MIN_LEVEL }) { }

    void OnPlayerLogin(Player* player) override
    {
        ForgetMountSpells(player);
        FixWrongRace(player);
    }

    // a first mount quest of another race: out of reach, so it is neither shown nor taken
    void OnPlayerGetQuestMinLevel(Player const* player, Quest const* quest, uint32& minLevel) override
    {
        if (!settings.enable)
            return;
        if (uint8 race = QuestRace(quest->GetQuestId()))
            if (player->getRace() != race)
                minLevel = DEFAULT_MAX_LEVEL + 100;
    }

    void OnPlayerQuestRewardItem(Player* player, Item* item, uint32 /*count*/) override
    {
        SwapDrake(player, item);
    }

    void OnPlayerQuestAbandon(Player* player, uint32 questId) override
    {
        Dismount(player, questId);
    }

    // called while the quest is being rewarded
    void OnPlayerQuestComputeXP(Player* player, Quest const* quest, uint32& /*xpValue*/) override
    {
        Dismount(player, quest->GetQuestId());
        LearnSlowMount(player, quest->GetQuestId());
    }
};

class TemucraftFirstMount_World : public WorldScript
{
public:
    TemucraftFirstMount_World() : WorldScript("TemucraftFirstMount_World", { WORLDHOOK_ON_AFTER_CONFIG_LOAD, WORLDHOOK_ON_STARTUP }) { }

    void OnAfterConfigLoad(bool reload) override
    {
        settings.enable = sConfigMgr->GetOption<bool>("Temucraft.FirstMount.Enable", true);
        settings.questFirst = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.QuestFirst", 602110);
        settings.spellFirst = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.SpellFirst", 95330);
        settings.count = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.Count", 10);
        settings.slowQuest = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.SlowQuest", 602130);
        settings.slowSpellFirst = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.SlowSpellFirst", 95340);
        settings.slowItemFirst = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.SlowItemFirst", 602180);
        settings.dracthyrDrakes = sConfigMgr->GetOption<bool>("Temucraft.FirstMount.DracthyrDrakes", true);
        settings.drakeItems.clear();
        std::string drakes = sConfigMgr->GetOption<std::string>("Temucraft.FirstMount.DracthyrDrakeItems", "602160 602161");
        for (std::string_view id : Acore::Tokenize(drakes, ' ', false))
            if (Optional<uint32> entry = Acore::StringTo<uint32>(id))
                settings.drakeItems.insert(*entry);

        // `.reload config` also reloads the race table; at server start it is read in OnStartup (world DB is ready)
        if (reload)
            LoadRaceTable();
    }

    void OnStartup() override
    {
        LoadRaceTable();
    }
};

void AddTemucraftFirstMountScripts()
{
    new TemucraftFirstMount_Player();
    new TemucraftFirstMount_World();
}
