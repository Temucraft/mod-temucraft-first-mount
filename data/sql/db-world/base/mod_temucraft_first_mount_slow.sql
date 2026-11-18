-- mod-temucraft-first-mount: "An Old Ride". The NPC who sends you out of your starting zone offers a quest that
-- teaches a slow mount, free and with no riding skill: +30% speed (a trained mount is +60%). The mount matches
-- your race (the script picks it: spells 95340-95349, the borrowed mounts' looks). Re-runnable.
SET @SlowQuest := 602130;
SET @SlowSpellFirst := 95340;
-- who offers it (and takes it back): one per starting zone
SET @ExitHuman := 197;       -- Marshal McBride, Northshire
SET @ExitOrcTroll := 6786;   -- Ukor, Valley of Trials
SET @ExitDwarfGnome := 658;  -- Sten Stoutarm, Coldridge Valley
SET @ExitNightElf := 6780;   -- Porthannius, Shadowglen
SET @ExitUndead := 1519;     -- Deathguard Simmer, Deathknell
SET @ExitTauren := 2981;     -- Chief Hawkwind, Camp Narache
SET @ExitBloodElf := 15281;  -- Lanthan Perilon, Sunstrider Isle
SET @ExitDraenei := 16477;   -- Proenitus, Ammen Vale

DELETE FROM `quest_template` WHERE `ID` = @SlowQuest;
DELETE FROM `quest_template_addon` WHERE `ID` = @SlowQuest;
DELETE FROM `quest_offer_reward` WHERE `ID` = @SlowQuest;
DELETE FROM `creature_queststarter` WHERE `quest` = @SlowQuest;
DELETE FROM `creature_questender` WHERE `quest` = @SlowQuest;
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `AllowableRaces`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `VerifiedBuild`) VALUES
(@SlowQuest, 2, 1, 1, 0, 'An Old Ride',
    'Accept the old mount and learn to ride it.',
    'The road ahead is long, $N, and your legs are young. There''s an old mount in the pens nobody rides anymore. It''s slow and stubborn, but it beats walking, and you don''t need any training to sit on it.$B$BTake it. It''s yours, free of charge.',
    'Return when you''re ready to ride.', 0);
INSERT INTO `quest_offer_reward` (`ID`, `RewardText`) VALUES
(@SlowQuest, 'There. Treat it kindly and it''ll carry you a good way. When you can afford proper lessons, a riding trainer will teach you to ride something faster.');
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES
(@ExitHuman, @SlowQuest), (@ExitOrcTroll, @SlowQuest), (@ExitDwarfGnome, @SlowQuest), (@ExitNightElf, @SlowQuest),
(@ExitUndead, @SlowQuest), (@ExitTauren, @SlowQuest), (@ExitBloodElf, @SlowQuest), (@ExitDraenei, @SlowQuest);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES
(@ExitHuman, @SlowQuest), (@ExitOrcTroll, @SlowQuest), (@ExitDwarfGnome, @SlowQuest), (@ExitNightElf, @SlowQuest),
(@ExitUndead, @SlowQuest), (@ExitTauren, @SlowQuest), (@ExitBloodElf, @SlowQuest), (@ExitDraenei, @SlowQuest);
UPDATE `creature_template` SET `npcflag` = `npcflag` | 2 WHERE `entry` IN (@ExitHuman, @ExitOrcTroll, @ExitDwarfGnome, @ExitNightElf, @ExitUndead, @ExitTauren, @ExitBloodElf, @ExitDraenei);

-- the slow mount spells: copies of the borrowed mounts (95330-95339) at +30% speed, with no zone or quest limit
DELETE FROM `spell_dbc` WHERE `ID` BETWEEN @SlowSpellFirst AND @SlowSpellFirst + 9;
DROP TEMPORARY TABLE IF EXISTS `tmp_slow_mount`;
CREATE TEMPORARY TABLE `tmp_slow_mount` SELECT * FROM `spell_dbc` WHERE `ID` BETWEEN 95330 AND 95339;
UPDATE `tmp_slow_mount` SET `ID` = `ID` - 95330 + @SlowSpellFirst, `EffectBasePoints_2` = 29,
    `Name_Lang_enUS` = REPLACE(`Name_Lang_enUS`, 'Borrowed ', 'Old '),
    `Description_Lang_enUS` = CONCAT('Summons and dismisses an old ', SUBSTRING(`Name_Lang_enUS`, 10), ' to ride. Slower than a trained mount, but faster than walking. No riding skill needed.'),
    `AuraDescription_Lang_enUS` = 'Increases speed by 30%.';
INSERT INTO `spell_dbc` SELECT * FROM `tmp_slow_mount`;
DROP TEMPORARY TABLE IF EXISTS `tmp_slow_mount`;
DELETE FROM `spell_area` WHERE `spell` BETWEEN @SlowSpellFirst AND @SlowSpellFirst + 9;
