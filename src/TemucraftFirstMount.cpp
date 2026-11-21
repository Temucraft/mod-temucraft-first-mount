/*
 * mod-temucraft-first-mount: takes the borrowed mount away when its quest leaves the log.
 *
 * The quests, the borrowed mount items and where they work are SQL (data/sql). Two things SQL can't do alone:
 *   - abandoning the quest: AzerothCore takes the quest item back, but a borrowed mount you're sitting on stays;
 *   - turning the quest in: the same.
 * Leaving the quest's zones already drops the mount (spell_area).
 * It also teaches the slow mount of "An Old Ride" (quest 602130), the one that matches the player's race.
 *
 * The custom races (mod_temucraft_first_mount_races.sql) are read from `temucraft_first_mount_race` at startup:
 * their quests also drop the borrowed mount, and "An Old Ride" teaches them the slow mount of their home race.
 *
 * The Dracthyr ground drakes are optional: with Temucraft.FirstMount.DracthyrDrakes = 0, a drake picked as a quest
 * reward is swapped for the first mount of the home race's quest (the SQL can also leave them out, @DracthyrDrakes).
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
        bool dracthyrDrakes = true;
        std::unordered_set<uint32> drakeItems = { 602160, 602161 };
    } settings;

    // custom race -> home index (the classic race whose mounts it uses, same order as the borrowed mounts)
    std::unordered_map<uint8, uint32> raceHome;
    // the quests of the custom races
    std::unordered_set<uint32> raceQuests;

    void LoadRaceTable()
    {
        raceHome.clear();
        raceQuests.clear();

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

    // DracthyrDrakes = 0: a drake quest reward becomes the first mount of the home race's quest
    void SwapDrake(Player* player, Item* item)
    {
        if (!settings.enable || settings.dracthyrDrakes || !item || !settings.drakeItems.count(item->GetEntry()))
            return;
        Quest const* home = sObjectMgr->GetQuestTemplate(settings.questFirst + HomeIndex(player));
        uint32 replacement = 0;
        for (uint32 i = 0; home && i < QUEST_REWARD_CHOICES_COUNT && !replacement; ++i)
            if (home->RewardChoiceItemId[i] && !settings.drakeItems.count(home->RewardChoiceItemId[i]))
                replacement = home->RewardChoiceItemId[i];
        if (!replacement || !sObjectMgr->GetItemTemplate(replacement))
            return;
        player->DestroyItem(item->GetBagSlot(), item->GetSlot(), true);
        ItemPosCountVec dest;
        if (player->CanStoreNewItem(NULL_BAG, NULL_SLOT, dest, replacement, 1) == EQUIP_ERR_OK)
            if (Item* added = player->StoreNewItem(dest, replacement, true))
                player->SendNewItem(added, 1, true, false);
    }

    // "An Old Ride": teach the slow mount that matches the race (same order as the borrowed mounts)
    void LearnSlowMount(Player* player, uint32 questId)
    {
        if (!settings.enable || !settings.slowQuest || questId != settings.slowQuest)
            return;
        uint32 index = HomeIndex(player);
        uint32 spell = settings.slowSpellFirst + index;
        if (!player->HasSpell(spell))
            player->learnSpell(spell);
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
        { PLAYERHOOK_ON_QUEST_ABANDON, PLAYERHOOK_ON_QUEST_COMPUTE_EXP, PLAYERHOOK_ON_QUEST_REWARD_ITEM }) { }

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
