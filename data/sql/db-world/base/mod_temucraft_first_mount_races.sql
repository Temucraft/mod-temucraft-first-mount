-- mod-temucraft-first-mount: the first mount quest for every custom playable race.
--
-- mod_temucraft_first_mount.sql has one quest per classic race (602110-602119). This file gives every other playable
-- race (the races of mod-worgoblin-high-elf, IDs from its ChrRaces.dbc) its own copy of the quest of its home race:
-- same quest giver, same turn-in NPC, same borrowed mount and zones, but its own reward choices. The race's own mounts
-- come first (when they exist in item_template and Apprentice Riding can ride them), then the home race's choices
-- fill the free slots, up to 6. Every offered mount is made usable by the race (AllowableRace).
--
-- Dracthyr have no ground mount in our data, so this file adds two: the Blue Ground Drake (Alliance) and the Red Ground
-- Drake (Horde), items 602160-602161 and spells 95350-95351 (server: spell_dbc below, client: client/ Spell.dbc).
--
-- Only races that exist on this server get a quest: a race needs at least one row in `playercreateinfo` (the table
-- mod-worgoblin-high-elf's race modpaks fill for the races you build in; without it nobody can make a character of
-- that race). Run this file again after you add or remove a race.
--
-- The ground drakes are optional: set @DracthyrDrakes to 0 below to leave them out (an earlier run's drakes are then
-- removed, and the Dracthyr get their home race's mounts). Temucraft.FirstMount.DracthyrDrakes in the module's
-- config does the same on a running server without touching the database (see the README).
--
-- Runs after mod_temucraft_first_mount.sql and mod_temucraft_first_mount_dbc.sql (file name order), it reads their
-- quests and spells. The C++ script reads `temucraft_first_mount_race` for the borrowed mount and "An Old Ride".
-- Re-runnable: every block deletes its own rows first.

-- ------------------------------------------------------------------------------------------------------------------
-- What you may want to change
-- ------------------------------------------------------------------------------------------------------------------
SET @RidingLevel     := 5;      -- same as in mod_temucraft_first_mount.sql
SET @RidingSkillRank := 75;     -- only mounts that need this riding skill or less are offered (75 = Apprentice)
SET @QuestFirst      := 602110; -- the first classic race quest (@QuestFirst in mod_temucraft_first_mount.sql)
SET @RaceQuestFirst  := 602140; -- the first quest of this file, one per race below
SET @MaxChoices      := 6;
SET @DracthyrDrakes  := 1;      -- 1 adds the Dracthyr ground drakes, 0 leaves them out

-- Home index = the classic race whose quest is copied:
-- 0 Human, 1 Orc, 2 Dwarf, 3 Night Elf, 4 Undead, 5 Tauren, 6 Gnome, 7 Troll, 8 Blood Elf, 9 Draenei
SET @HomeHuman := 0, @HomeOrc := 1, @HomeDwarf := 2, @HomeNightElf := 3, @HomeUndead := 4;
SET @HomeTauren := 5, @HomeGnome := 6, @HomeTroll := 7, @HomeBloodElf := 8, @HomeDraenei := 9;

-- The race IDs of mod-worgoblin-high-elf (its ChrRaces.dbc)
SET @Goblin := 9, @Worgen := 12, @AlliancePandaren := 13, @HordePandaren := 14, @Nightborne := 15;
SET @HighmountainTauren := 16, @VoidElf := 17, @LightforgedDraenei := 18, @ZandalariTroll := 19, @KulTiran := 20;
SET @Vulpera := 21, @DarkIronDwarf := 22, @MagharOrc := 23, @Mechagnome := 24, @AllianceDracthyr := 25;
SET @HordeDracthyr := 26, @AllianceEarthen := 27, @HordeEarthen := 28, @AllianceHaranir := 29, @HordeHaranir := 30;

-- The racial mount items of mod-worgoblin-high-elf (its config.sql). Items that are missing or need more riding
-- skill are skipped, so listing the swift ones does no harm.
SET @GoblinTrike := 62461, @GoblinTurboTrike := 62462;
SET @MountainHorse := 73838, @SwiftMountainHorse := 73839;
SET @BlueDragonTurtle := 91009, @PurpleDragonTurtle := 91006, @GreenDragonTurtle := 91004, @BlackDragonTurtle := 91008;
SET @NightborneManasaber := 156487, @HighmountainThunderhoof := 155662, @StarcursedVoidstrider := 156486;
SET @LightforgedFelcrusher := 155656, @BlessedFelcrusher := 153043, @AvengingFelcrusher := 153044, @GloriousFelcrusher := 153042;
SET @ZandalariDirehorn := 157870, @KulTiranCharger := 164762, @CaravanHyena := 174066, @CaravanHyenaNoCanopy := 174065;
SET @DarkIronCoreHound := 161331, @MagharDirewolf := 161330;
-- Stock mounts that fit races without their own: rams for the Earthen (their mount is a stone ram),
-- mechanostriders for the Mechagnome, nightsabers and raptors for the Haranir (forest folk)
SET @GrayRam := 5864, @BrownRam := 5872, @WhiteRam := 5873;
SET @BlueMechanostrider := 8595, @RedMechanostrider := 8563, @GreenMechanostrider := 13321, @UnpaintedMechanostrider := 13322;
SET @StripedNightsaber := 8629, @StripedFrostsaber := 8631, @SpottedFrostsaber := 8632;
SET @EmeraldRaptor := 8588, @TurquoiseRaptor := 8591, @VioletRaptor := 8592;

-- The Dracthyr ground drakes: items, spells, the mount creature (its model is what you ride) and the spell icon
SET @DrakeItemFirst  := 602160;
SET @BlueDrakeItem   := @DrakeItemFirst + 0; -- 602160
SET @RedDrakeItem    := @DrakeItemFirst + 1; -- 602161
SET @DrakeSpellFirst := 95350;
SET @BlueDrakeSpell  := @DrakeSpellFirst + 0; -- 95350
SET @RedDrakeSpell   := @DrakeSpellFirst + 1; -- 95351
SET @BlueDrakeCreature := 31695, @BlueDrakeIcon := 3667; -- Blue Drake (59568)
SET @RedDrakeCreature  := 31697, @RedDrakeIcon  := 3495; -- Red Drake (59570)
SET @DrakeItemDisplay  := 56307;  -- the drake reins icon
SET @DrakeTemplateItem := 2411;   -- Black Stallion Bridle: price, riding skill and flags are copied from it
SET @DrakeTemplateSpell := 95330; -- Borrowed Black Stallion (mod_temucraft_first_mount_dbc.sql): a +60% ground mount

-- ------------------------------------------------------------------------------------------------------------------
-- The races: home race, quest, and their own mounts (0 = none)
-- ------------------------------------------------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `temucraft_first_mount_race` (
    `Race` TINYINT UNSIGNED NOT NULL,
    `Name` VARCHAR(50) NOT NULL DEFAULT '',
    `HomeIndex` TINYINT UNSIGNED NOT NULL COMMENT '0 Human, 1 Orc, 2 Dwarf, 3 Night Elf, 4 Undead, 5 Tauren, 6 Gnome, 7 Troll, 8 Blood Elf, 9 Draenei',
    `Quest` INT UNSIGNED NOT NULL,
    `Mount1` INT UNSIGNED NOT NULL DEFAULT 0,
    `Mount2` INT UNSIGNED NOT NULL DEFAULT 0,
    `Mount3` INT UNSIGNED NOT NULL DEFAULT 0,
    `Mount4` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`Race`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='mod-temucraft-first-mount: first mount quest of the custom races';

DELETE FROM `temucraft_first_mount_race`;
INSERT INTO `temucraft_first_mount_race` (`Race`, `Name`, `HomeIndex`, `Quest`, `Mount1`, `Mount2`, `Mount3`, `Mount4`) VALUES
(@Goblin,             'Goblin',              @HomeOrc,      @RaceQuestFirst + 0,  @GoblinTrike,           @GoblinTurboTrike,      0, 0),
(@Worgen,             'Worgen',              @HomeNightElf, @RaceQuestFirst + 1,  @MountainHorse,         @SwiftMountainHorse,    0, 0),
(@AlliancePandaren,   'Pandaren (Alliance)', @HomeHuman,    @RaceQuestFirst + 2,  @BlueDragonTurtle,      @PurpleDragonTurtle,    @GreenDragonTurtle, @BlackDragonTurtle),
(@HordePandaren,      'Pandaren (Horde)',    @HomeTauren,   @RaceQuestFirst + 3,  @BlueDragonTurtle,      @PurpleDragonTurtle,    @GreenDragonTurtle, @BlackDragonTurtle),
(@Nightborne,         'Nightborne',          @HomeBloodElf, @RaceQuestFirst + 4,  @NightborneManasaber,   0,                      0, 0),
(@HighmountainTauren, 'Highmountain Tauren', @HomeTauren,   @RaceQuestFirst + 5,  @HighmountainThunderhoof, 0,                    0, 0),
(@VoidElf,            'Void Elf',            @HomeNightElf, @RaceQuestFirst + 6,  @StarcursedVoidstrider, 0,                      0, 0),
(@LightforgedDraenei, 'Lightforged Draenei', @HomeDraenei,  @RaceQuestFirst + 7,  @LightforgedFelcrusher, @BlessedFelcrusher,     @AvengingFelcrusher, @GloriousFelcrusher),
(@ZandalariTroll,     'Zandalari Troll',     @HomeTroll,    @RaceQuestFirst + 8,  @ZandalariDirehorn,     0,                      0, 0),
(@KulTiran,           'Kul Tiran',           @HomeHuman,    @RaceQuestFirst + 9,  @KulTiranCharger,       0,                      0, 0),
(@Vulpera,            'Vulpera',             @HomeTauren,   @RaceQuestFirst + 10, @CaravanHyena,          @CaravanHyenaNoCanopy,  0, 0),
(@DarkIronDwarf,      'Dark Iron Dwarf',     @HomeDwarf,    @RaceQuestFirst + 11, @DarkIronCoreHound,     0,                      0, 0),
(@MagharOrc,          'Mag''har Orc',        @HomeOrc,      @RaceQuestFirst + 12, @MagharDirewolf,        0,                      0, 0),
(@Mechagnome,         'Mechagnome',          @HomeGnome,    @RaceQuestFirst + 13, @UnpaintedMechanostrider, @BlueMechanostrider,  @RedMechanostrider, @GreenMechanostrider),
(@AllianceDracthyr,   'Dracthyr (Alliance)', @HomeHuman,    @RaceQuestFirst + 14, @BlueDrakeItem,         0,                      0, 0),
(@HordeDracthyr,      'Dracthyr (Horde)',    @HomeOrc,      @RaceQuestFirst + 15, @RedDrakeItem,          0,                      0, 0),
(@AllianceEarthen,    'Earthen (Alliance)',  @HomeDwarf,    @RaceQuestFirst + 16, @GrayRam,               @BrownRam,              @WhiteRam, 0),
(@HordeEarthen,       'Earthen (Horde)',     @HomeOrc,      @RaceQuestFirst + 17, @GrayRam,               @BrownRam,              @WhiteRam, 0),
(@AllianceHaranir,    'Haranir (Alliance)',  @HomeNightElf, @RaceQuestFirst + 18, @StripedNightsaber,     @StripedFrostsaber,     @SpottedFrostsaber, 0),
(@HordeHaranir,       'Haranir (Horde)',     @HomeTroll,    @RaceQuestFirst + 19, @EmeraldRaptor,         @TurquoiseRaptor,       @VioletRaptor, 0);
SET @RaceQuestLast := @RaceQuestFirst + 19;

-- Races that are not set up on this server (no playercreateinfo rows) get nothing
DELETE FROM `temucraft_first_mount_race` WHERE `Race` NOT IN (SELECT DISTINCT `race` FROM `playercreateinfo`);

-- ------------------------------------------------------------------------------------------------------------------
-- Nothing to change below this line
-- ------------------------------------------------------------------------------------------------------------------

-- The Dracthyr ground drakes: spells (copies of the borrowed Black Stallion, without its zone and quest limits,
-- spell_area only limits 95330-95339) and items (copies of the Black Stallion Bridle). Only added when
-- @DracthyrDrakes is 1; the deletes always run, so 0 also removes them.
DELETE FROM `spell_dbc` WHERE `ID` IN (@BlueDrakeSpell, @RedDrakeSpell);
DROP TEMPORARY TABLE IF EXISTS `tmp_temucraft_drake_spell`;
CREATE TEMPORARY TABLE `tmp_temucraft_drake_spell` SELECT * FROM `spell_dbc` WHERE `ID` = @DrakeTemplateSpell;
UPDATE `tmp_temucraft_drake_spell` SET `ID` = @BlueDrakeSpell, `EffectMiscValue_1` = @BlueDrakeCreature, `SpellIconID` = @BlueDrakeIcon,
    `Name_Lang_enUS` = 'Blue Ground Drake', `Description_Lang_enUS` = 'Summons and dismisses a rideable Blue Ground Drake.',
    `AuraDescription_Lang_enUS` = 'Increases speed by 60%.';
INSERT INTO `spell_dbc` SELECT * FROM `tmp_temucraft_drake_spell` WHERE @DracthyrDrakes = 1;
UPDATE `tmp_temucraft_drake_spell` SET `ID` = @RedDrakeSpell, `EffectMiscValue_1` = @RedDrakeCreature, `SpellIconID` = @RedDrakeIcon,
    `Name_Lang_enUS` = 'Red Ground Drake', `Description_Lang_enUS` = 'Summons and dismisses a rideable Red Ground Drake.';
INSERT INTO `spell_dbc` SELECT * FROM `tmp_temucraft_drake_spell` WHERE @DracthyrDrakes = 1;
DROP TEMPORARY TABLE IF EXISTS `tmp_temucraft_drake_spell`;

DELETE FROM `item_template` WHERE `entry` IN (@BlueDrakeItem, @RedDrakeItem);
DROP TEMPORARY TABLE IF EXISTS `tmp_temucraft_drake_item`;
CREATE TEMPORARY TABLE `tmp_temucraft_drake_item` SELECT * FROM `item_template` WHERE `entry` = @DrakeTemplateItem;
UPDATE `tmp_temucraft_drake_item` SET `entry` = @BlueDrakeItem, `name` = 'Reins of the Blue Ground Drake', `displayid` = @DrakeItemDisplay,
    `spellid_2` = @BlueDrakeSpell, `AllowableRace` = -1, `description` = 'A young drake that keeps to the ground. It carries Dracthyr gladly.';
INSERT INTO `item_template` SELECT * FROM `tmp_temucraft_drake_item` WHERE @DracthyrDrakes = 1;
UPDATE `tmp_temucraft_drake_item` SET `entry` = @RedDrakeItem, `name` = 'Reins of the Red Ground Drake', `spellid_2` = @RedDrakeSpell;
INSERT INTO `item_template` SELECT * FROM `tmp_temucraft_drake_item` WHERE @DracthyrDrakes = 1;
DROP TEMPORARY TABLE IF EXISTS `tmp_temucraft_drake_item`;

-- The choices of each race: own mounts first, then the home race's choices; only mounts Apprentice Riding can ride
DROP TABLE IF EXISTS `temucraft_first_mount_choice`;
CREATE TABLE `temucraft_first_mount_choice` (`Race` TINYINT UNSIGNED NOT NULL, `Prio` TINYINT UNSIGNED NOT NULL, `Item` INT UNSIGNED NOT NULL) ENGINE=InnoDB;
INSERT INTO `temucraft_first_mount_choice` (`Race`, `Prio`, `Item`)
          SELECT `Race`, 1, `Mount1` FROM `temucraft_first_mount_race`
UNION ALL SELECT `Race`, 2, `Mount2` FROM `temucraft_first_mount_race`
UNION ALL SELECT `Race`, 3, `Mount3` FROM `temucraft_first_mount_race`
UNION ALL SELECT `Race`, 4, `Mount4` FROM `temucraft_first_mount_race`
UNION ALL SELECT r.`Race`, 11, q.`RewardChoiceItemID1` FROM `temucraft_first_mount_race` r JOIN `quest_template` q ON q.`ID` = @QuestFirst + r.`HomeIndex`
UNION ALL SELECT r.`Race`, 12, q.`RewardChoiceItemID2` FROM `temucraft_first_mount_race` r JOIN `quest_template` q ON q.`ID` = @QuestFirst + r.`HomeIndex`
UNION ALL SELECT r.`Race`, 13, q.`RewardChoiceItemID3` FROM `temucraft_first_mount_race` r JOIN `quest_template` q ON q.`ID` = @QuestFirst + r.`HomeIndex`
UNION ALL SELECT r.`Race`, 14, q.`RewardChoiceItemID4` FROM `temucraft_first_mount_race` r JOIN `quest_template` q ON q.`ID` = @QuestFirst + r.`HomeIndex`
UNION ALL SELECT r.`Race`, 15, q.`RewardChoiceItemID5` FROM `temucraft_first_mount_race` r JOIN `quest_template` q ON q.`ID` = @QuestFirst + r.`HomeIndex`
UNION ALL SELECT r.`Race`, 16, q.`RewardChoiceItemID6` FROM `temucraft_first_mount_race` r JOIN `quest_template` q ON q.`ID` = @QuestFirst + r.`HomeIndex`;
DELETE FROM `temucraft_first_mount_choice` WHERE `Item` NOT IN
    (SELECT `entry` FROM `item_template` WHERE `class` = 15 AND `subclass` = 5 AND `RequiredSkillRank` <= @RidingSkillRank);

DROP TABLE IF EXISTS `temucraft_first_mount_pick`;
CREATE TABLE `temucraft_first_mount_pick` ENGINE=InnoDB
SELECT `Race`, `Item`, ROW_NUMBER() OVER (PARTITION BY `Race` ORDER BY MIN(`Prio`)) AS `Slot`
FROM `temucraft_first_mount_choice` GROUP BY `Race`, `Item`;
DELETE FROM `temucraft_first_mount_pick` WHERE `Slot` > @MaxChoices;

-- The offered mounts can be used from @RidingLevel, and by the races that are offered them
UPDATE `item_template` SET `RequiredLevel` = @RidingLevel WHERE `entry` IN (SELECT `Item` FROM `temucraft_first_mount_pick`);
UPDATE `item_template` i
JOIN (SELECT `Item`, BIT_OR(1 << (`Race` - 1)) AS `Mask` FROM `temucraft_first_mount_pick` GROUP BY `Item`) p ON p.`Item` = i.`entry`
SET i.`AllowableRace` = i.`AllowableRace` | p.`Mask`
WHERE i.`AllowableRace` <> -1;

-- The quests: copies of the home race's quest, for this race only, with this race's choices
DELETE FROM `quest_template` WHERE `ID` BETWEEN @RaceQuestFirst AND @RaceQuestLast;
DELETE FROM `quest_template_addon` WHERE `ID` BETWEEN @RaceQuestFirst AND @RaceQuestLast;
DELETE FROM `creature_queststarter` WHERE `quest` BETWEEN @RaceQuestFirst AND @RaceQuestLast;
DELETE FROM `creature_questender` WHERE `quest` BETWEEN @RaceQuestFirst AND @RaceQuestLast;
DELETE FROM `spell_area` WHERE `quest_start` BETWEEN @RaceQuestFirst AND @RaceQuestLast;

INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `StartItem`, `RewardDisplaySpell`, `RewardSpell`,
    `RewardChoiceItemID1`, `RewardChoiceItemQuantity1`, `RewardChoiceItemID2`, `RewardChoiceItemQuantity2`,
    `RewardChoiceItemID3`, `RewardChoiceItemQuantity3`, `RewardChoiceItemID4`, `RewardChoiceItemQuantity4`,
    `RewardChoiceItemID5`, `RewardChoiceItemQuantity5`, `RewardChoiceItemID6`, `RewardChoiceItemQuantity6`,
    `AllowableRaces`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `VerifiedBuild`)
SELECT r.`Quest`, q.`QuestType`, q.`QuestLevel`, q.`MinLevel`, q.`StartItem`, q.`RewardDisplaySpell`, q.`RewardSpell`,
    IFNULL(c.`C1`, 0), IF(IFNULL(c.`C1`, 0) <> 0, 1, 0), IFNULL(c.`C2`, 0), IF(IFNULL(c.`C2`, 0) <> 0, 1, 0),
    IFNULL(c.`C3`, 0), IF(IFNULL(c.`C3`, 0) <> 0, 1, 0), IFNULL(c.`C4`, 0), IF(IFNULL(c.`C4`, 0) <> 0, 1, 0),
    IFNULL(c.`C5`, 0), IF(IFNULL(c.`C5`, 0) <> 0, 1, 0), IFNULL(c.`C6`, 0), IF(IFNULL(c.`C6`, 0) <> 0, 1, 0),
    1 << (r.`Race` - 1), q.`LogTitle`, q.`LogDescription`, q.`QuestDescription`, q.`QuestCompletionLog`, 0
FROM `temucraft_first_mount_race` r
JOIN `quest_template` q ON q.`ID` = @QuestFirst + r.`HomeIndex`
LEFT JOIN (SELECT `Race`, MAX(IF(`Slot` = 1, `Item`, 0)) AS `C1`, MAX(IF(`Slot` = 2, `Item`, 0)) AS `C2`, MAX(IF(`Slot` = 3, `Item`, 0)) AS `C3`,
                  MAX(IF(`Slot` = 4, `Item`, 0)) AS `C4`, MAX(IF(`Slot` = 5, `Item`, 0)) AS `C5`, MAX(IF(`Slot` = 6, `Item`, 0)) AS `C6`
           FROM `temucraft_first_mount_pick` GROUP BY `Race`) c ON c.`Race` = r.`Race`;

INSERT INTO `quest_template_addon` (`ID`, `ProvidedItemCount`)
SELECT `Quest`, 1 FROM `temucraft_first_mount_race` WHERE `Quest` IN (SELECT `ID` FROM `quest_template`);

INSERT INTO `creature_queststarter` (`id`, `quest`)
SELECT s.`id`, r.`Quest` FROM `temucraft_first_mount_race` r JOIN `creature_queststarter` s ON s.`quest` = @QuestFirst + r.`HomeIndex`;
INSERT INTO `creature_questender` (`id`, `quest`)
SELECT e.`id`, r.`Quest` FROM `temucraft_first_mount_race` r JOIN `creature_questender` e ON e.`quest` = @QuestFirst + r.`HomeIndex`;

-- the borrowed mount works in the home quest's zones while this quest is in the log
INSERT INTO `spell_area` (`spell`, `area`, `quest_start`, `quest_end`, `aura_spell`, `racemask`, `gender`, `autocast`, `quest_start_status`, `quest_end_status`)
SELECT a.`spell`, a.`area`, r.`Quest`, a.`quest_end`, a.`aura_spell`, a.`racemask`, a.`gender`, a.`autocast`, a.`quest_start_status`, a.`quest_end_status`
FROM `temucraft_first_mount_race` r JOIN `spell_area` a ON a.`quest_start` = @QuestFirst + r.`HomeIndex`;

DROP TABLE IF EXISTS `temucraft_first_mount_pick`;
DROP TABLE IF EXISTS `temucraft_first_mount_choice`;
