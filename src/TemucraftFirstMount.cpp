/*
 * mod-temucraft-first-mount: takes the borrowed mount away when its quest leaves the log.
 *
 * The quests, the borrowed mount items and where they work are SQL (data/sql). Two things SQL can't do alone:
 *   - abandoning the quest: AzerothCore takes the quest item back, but a borrowed mount you're sitting on stays;
 *   - turning the quest in: the same.
 * Leaving the quest's zones already drops the mount (spell_area).
 * It also teaches the slow mount of "An Old Ride" (quest 602130), the one that matches the player's race.
 */

#include "Config.h"
#include "Player.h"
#include "QuestDef.h"
#include "ScriptMgr.h"

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
    } settings;

    // "An Old Ride": teach the slow mount that matches the race (same order as the borrowed mounts)
    void LearnSlowMount(Player* player, uint32 questId)
    {
        if (!settings.enable || !settings.slowQuest || questId != settings.slowQuest)
            return;
        int32 index;
        switch (player->getRace())
        {
            case RACE_HUMAN:         index = 0; break;
            case RACE_ORC:           index = 1; break;
            case RACE_DWARF:         index = 2; break;
            case RACE_NIGHTELF:      index = 3; break;
            case RACE_UNDEAD_PLAYER: index = 4; break;
            case RACE_TAUREN:        index = 5; break;
            case RACE_GNOME:         index = 6; break;
            case RACE_TROLL:         index = 7; break;
            case RACE_BLOODELF:      index = 8; break;
            case RACE_DRAENEI:       index = 9; break;
            default:                 index = player->GetTeamId() == TEAM_ALLIANCE ? 0 : 1; break;   // other races: horse or wolf
        }
        uint32 spell = settings.slowSpellFirst + index;
        if (!player->HasSpell(spell))
            player->learnSpell(spell);
    }

    void Dismount(Player* player, uint32 questId)
    {
        if (!settings.enable || questId < settings.questFirst || questId >= settings.questFirst + settings.count)
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
        { PLAYERHOOK_ON_QUEST_ABANDON, PLAYERHOOK_ON_QUEST_COMPUTE_EXP }) { }

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
    TemucraftFirstMount_World() : WorldScript("TemucraftFirstMount_World", { WORLDHOOK_ON_AFTER_CONFIG_LOAD }) { }

    void OnAfterConfigLoad(bool /*reload*/) override
    {
        settings.enable = sConfigMgr->GetOption<bool>("Temucraft.FirstMount.Enable", true);
        settings.questFirst = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.QuestFirst", 602110);
        settings.spellFirst = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.SpellFirst", 95330);
        settings.count = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.Count", 10);
        settings.slowQuest = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.SlowQuest", 602130);
        settings.slowSpellFirst = sConfigMgr->GetOption<uint32>("Temucraft.FirstMount.SlowSpellFirst", 95340);
    }
};

void AddTemucraftFirstMountScripts()
{
    new TemucraftFirstMount_Player();
    new TemucraftFirstMount_World();
}
