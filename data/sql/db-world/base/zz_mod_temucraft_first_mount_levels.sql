-- mod-temucraft-first-mount: the riding level again, last.
-- mod-individual-progression's mounts_and_riding.sql sets the same rows (the classic mounts to level 40, Apprentice
-- Riding to level 40 and 80 gold). SQL files run in name order, so that file ran after ours and won. This file's name
-- sorts after it, so the first mount quest's levels stay. Keep @RidingLevel / @RidingCost the same as in
-- mod_temucraft_first_mount.sql.
SET @RidingLevel := 5;
SET @RidingCost  := 95;

-- every mount the first mount quests offer (classic races 602110-602119, the other races 602140-602179)
UPDATE `item_template` SET `RequiredLevel` = @RidingLevel WHERE `entry` IN (
    SELECT `e` FROM (
        SELECT `RewardChoiceItemID1` AS `e` FROM `quest_template` WHERE `ID` BETWEEN 602110 AND 602119 OR `ID` BETWEEN 602140 AND 602179
        UNION SELECT `RewardChoiceItemID2` FROM `quest_template` WHERE `ID` BETWEEN 602110 AND 602119 OR `ID` BETWEEN 602140 AND 602179
        UNION SELECT `RewardChoiceItemID3` FROM `quest_template` WHERE `ID` BETWEEN 602110 AND 602119 OR `ID` BETWEEN 602140 AND 602179
        UNION SELECT `RewardChoiceItemID4` FROM `quest_template` WHERE `ID` BETWEEN 602110 AND 602119 OR `ID` BETWEEN 602140 AND 602179
        UNION SELECT `RewardChoiceItemID5` FROM `quest_template` WHERE `ID` BETWEEN 602110 AND 602119 OR `ID` BETWEEN 602140 AND 602179
        UNION SELECT `RewardChoiceItemID6` FROM `quest_template` WHERE `ID` BETWEEN 602110 AND 602119 OR `ID` BETWEEN 602140 AND 602179
    ) AS `choices` WHERE `e` <> 0);

-- Apprentice Riding at the riding trainers (for players who skip the quest)
UPDATE `trainer_spell` SET `ReqLevel` = @RidingLevel, `MoneyCost` = @RidingCost WHERE `SpellId` = 33388;
