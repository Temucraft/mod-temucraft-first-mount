-- mod-temucraft-first-mount: every race gets a short quest from its riding trainer: take a borrowed mount to the
-- mount vendor, then pick your first mount and learn Apprentice Riding. The borrowed mount (a quest item) only
-- works while you have the quest and only in the quest's zones; abandoning the quest takes it back.
--
-- Everything you may want to change is in the SET blocks below. Re-runnable: every block deletes its rows first.
--
-- Find mounts to offer: https://wowgaming.altervista.org/aowow/?items=15.5&filter=qu=3
-- Up to 6 choices per race; 0 = no choice in that slot.

-- Level to ride, and what the riding trainer charges for Apprentice Riding (copper) if you skip the quest
SET @RidingLevel := 5;
SET @RidingCost  := 95;

-- Quest IDs: one per race, change the first one and the rest follow
SET @QuestFirst := 602110;
SET @QuestHuman := @QuestFirst + 0; -- 602110
SET @QuestOrc := @QuestFirst + 1; -- 602111
SET @QuestDwarf := @QuestFirst + 2; -- 602112
SET @QuestNightElf := @QuestFirst + 3; -- 602113
SET @QuestUndead := @QuestFirst + 4; -- 602114
SET @QuestTauren := @QuestFirst + 5; -- 602115
SET @QuestGnome := @QuestFirst + 6; -- 602116
SET @QuestTroll := @QuestFirst + 7; -- 602117
SET @QuestBloodElf := @QuestFirst + 8; -- 602118
SET @QuestDraenei := @QuestFirst + 9; -- 602119

-- Borrowed mount items (quest items): change the first one and the rest follow
SET @BorrowedFirst := 602120;
SET @BorrowedHuman := @BorrowedFirst + 0; -- 602120
SET @BorrowedOrc := @BorrowedFirst + 1; -- 602121
SET @BorrowedDwarf := @BorrowedFirst + 2; -- 602122
SET @BorrowedNightElf := @BorrowedFirst + 3; -- 602123
SET @BorrowedUndead := @BorrowedFirst + 4; -- 602124
SET @BorrowedTauren := @BorrowedFirst + 5; -- 602125
SET @BorrowedGnome := @BorrowedFirst + 6; -- 602126
SET @BorrowedTroll := @BorrowedFirst + 7; -- 602127
SET @BorrowedBloodElf := @BorrowedFirst + 8; -- 602128
SET @BorrowedDraenei := @BorrowedFirst + 9; -- 602129

-- Borrowed mount spells. These are in the DBCs (server: mod_temucraft_first_mount_dbc.sql, client: client/),
-- so only change them together with those.
SET @SpellHuman := 95330; -- Borrowed Black Stallion
SET @SpellOrc := 95331; -- Borrowed Brown Wolf
SET @SpellDwarf := 95332; -- Borrowed White Ram
SET @SpellNightElf := 95333; -- Borrowed Striped Frostsaber
SET @SpellUndead := 95334; -- Borrowed Red Skeletal Horse
SET @SpellTauren := 95335; -- Borrowed Gray Kodo
SET @SpellGnome := 95336; -- Borrowed Blue Mechanostrider
SET @SpellTroll := 95337; -- Borrowed Violet Raptor
SET @SpellBloodElf := 95338; -- Borrowed Purple Hawkstrider
SET @SpellDraenei := 95339; -- Borrowed Purple Elekk

-- Human: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterHuman := 6774; -- Falkhaan Isenstrider in Goldshire
SET @EnderHuman   := 384; -- Katie Hunter at Eastvale Logging Camp
SET @ZoneHumanA := 12, @ZoneHumanB := 0;
SET @Choice1Human := 2411, @Choice2Human := 2414, @Choice3Human := 5655, @Choice4Human := 5656, @Choice5Human := 0, @Choice6Human := 0;

-- Orc: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterOrc := 4752; -- Kildar in the Valley of Honor
SET @EnderOrc   := 3362; -- Ogunaro Wolfrunner in the Valley of Honor
SET @ZoneOrcA := 14, @ZoneOrcB := 1637;
SET @Choice1Orc := 1132, @Choice2Orc := 5665, @Choice3Orc := 5668, @Choice4Orc := 46099, @Choice5Orc := 0, @Choice6Orc := 0;

-- Dwarf: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterDwarf := 4772; -- Ultham Ironhorn at Amberstill Ranch
SET @EnderDwarf   := 1261; -- Veron Amberstill at Amberstill Ranch
SET @ZoneDwarfA := 1, @ZoneDwarfB := 0;
SET @Choice1Dwarf := 5864, @Choice2Dwarf := 5872, @Choice3Dwarf := 5873, @Choice4Dwarf := 0, @Choice5Dwarf := 0, @Choice6Dwarf := 0;

-- NightElf: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterNightElf := 4753; -- Jartsam in the Cenarion Enclave
SET @EnderNightElf   := 4730; -- Lelanai in the Cenarion Enclave
SET @ZoneNightElfA := 141, @ZoneNightElfB := 1657;
SET @Choice1NightElf := 8629, @Choice2NightElf := 8631, @Choice3NightElf := 8632, @Choice4NightElf := 47100, @Choice5NightElf := 0, @Choice6NightElf := 0;

-- Undead: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterUndead := 4773; -- Velma Warnam in Brill
SET @EnderUndead   := 4731; -- Zachariah Post in Brill
SET @ZoneUndeadA := 85, @ZoneUndeadB := 0;
SET @Choice1Undead := 13331, @Choice2Undead := 13332, @Choice3Undead := 13333, @Choice4Undead := 46308, @Choice5Undead := 0, @Choice6Undead := 0;

-- Tauren: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterTauren := 3690; -- Kar Stormsinger in Bloodhoof Village
SET @EnderTauren   := 3685; -- Harb Clawhoof in Bloodhoof Village
SET @ZoneTaurenA := 215, @ZoneTaurenB := 0;
SET @Choice1Tauren := 15277, @Choice2Tauren := 15290, @Choice3Tauren := 46100, @Choice4Tauren := 0, @Choice5Tauren := 0, @Choice6Tauren := 0;

-- Gnome: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterGnome := 7954; -- Binjy Featherwhistle at Steelgrill's Depot
SET @EnderGnome   := 7955; -- Milli Featherwhistle at Steelgrill's Depot
SET @ZoneGnomeA := 1, @ZoneGnomeB := 0;
SET @Choice1Gnome := 8595, @Choice2Gnome := 13321, @Choice3Gnome := 13322, @Choice4Gnome := 8563, @Choice5Gnome := 0, @Choice6Gnome := 0;

-- Troll: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterTroll := 7953; -- Xar'Ti in Sen'jin Village
SET @EnderTroll   := 7952; -- Zjolnir in Sen'jin Village
SET @ZoneTrollA := 14, @ZoneTrollB := 0;
SET @Choice1Troll := 8588, @Choice2Troll := 8591, @Choice3Troll := 8592, @Choice4Troll := 0, @Choice5Troll := 0, @Choice6Troll := 0;

-- BloodElf: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterBloodElf := 16280; -- Perascamin at Thuron's Livery
SET @EnderBloodElf   := 16264; -- Winaestra at Thuron's Livery
SET @ZoneBloodElfA := 3430, @ZoneBloodElfB := 3487;
SET @Choice1BloodElf := 28927, @Choice2BloodElf := 29220, @Choice3BloodElf := 29221, @Choice4BloodElf := 29222, @Choice5BloodElf := 0, @Choice6BloodElf := 0;

-- Draenei: who gives the quest, who takes it, where the borrowed mount works (zone IDs, 0 = none), the choices
SET @StarterDraenei := 20914; -- Aalun in the Exodar
SET @EnderDraenei   := 17584; -- Torallius the Pack Handler in the Exodar
SET @ZoneDraeneiA := 3524, @ZoneDraeneiB := 3557;
SET @Choice1Draenei := 28481, @Choice2Draenei := 29743, @Choice3Draenei := 29744, @Choice4Draenei := 0, @Choice5Draenei := 0, @Choice6Draenei := 0;

-- ------------------------------------------------------------------------------------------------------------------
-- Nothing to change below this line
-- ------------------------------------------------------------------------------------------------------------------

-- The mounts on offer can be used from @RidingLevel, and the trainer teaches Apprentice Riding from then too
UPDATE `item_template` SET `RequiredLevel` = @RidingLevel WHERE `entry` IN (@Choice1Human, @Choice2Human, @Choice3Human, @Choice4Human, @Choice5Human, @Choice6Human, @Choice1Orc, @Choice2Orc, @Choice3Orc, @Choice4Orc, @Choice5Orc, @Choice6Orc, @Choice1Dwarf, @Choice2Dwarf, @Choice3Dwarf, @Choice4Dwarf, @Choice5Dwarf, @Choice6Dwarf, @Choice1NightElf, @Choice2NightElf, @Choice3NightElf, @Choice4NightElf, @Choice5NightElf, @Choice6NightElf, @Choice1Undead, @Choice2Undead, @Choice3Undead, @Choice4Undead, @Choice5Undead, @Choice6Undead, @Choice1Tauren, @Choice2Tauren, @Choice3Tauren, @Choice4Tauren, @Choice5Tauren, @Choice6Tauren, @Choice1Gnome, @Choice2Gnome, @Choice3Gnome, @Choice4Gnome, @Choice5Gnome, @Choice6Gnome, @Choice1Troll, @Choice2Troll, @Choice3Troll, @Choice4Troll, @Choice5Troll, @Choice6Troll, @Choice1BloodElf, @Choice2BloodElf, @Choice3BloodElf, @Choice4BloodElf, @Choice5BloodElf, @Choice6BloodElf, @Choice1Draenei, @Choice2Draenei, @Choice3Draenei, @Choice4Draenei, @Choice5Draenei, @Choice6Draenei) AND `entry` <> 0;
UPDATE `trainer_spell` SET `MoneyCost` = @RidingCost, `ReqLevel` = @RidingLevel WHERE `SpellId` = 33388;

-- Borrowed mounts: quest items, given when the quest is accepted, taken back when it is abandoned or done
DELETE FROM `item_template` WHERE `entry` IN (@BorrowedHuman, @BorrowedOrc, @BorrowedDwarf, @BorrowedNightElf, @BorrowedUndead, @BorrowedTauren, @BorrowedGnome, @BorrowedTroll, @BorrowedBloodElf, @BorrowedDraenei);
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedHuman, 12, 0, -1, 'Borrowed Black Stallion', `displayid`, 1, 1, 1, 1, @SpellHuman, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1Human;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedOrc, 12, 0, -1, 'Borrowed Brown Wolf', `displayid`, 1, 1, 1, 1, @SpellOrc, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1Orc;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedDwarf, 12, 0, -1, 'Borrowed White Ram', `displayid`, 1, 1, 1, 1, @SpellDwarf, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1Dwarf;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedNightElf, 12, 0, -1, 'Borrowed Striped Frostsaber', `displayid`, 1, 1, 1, 1, @SpellNightElf, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1NightElf;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedUndead, 12, 0, -1, 'Borrowed Red Skeletal Horse', `displayid`, 1, 1, 1, 1, @SpellUndead, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1Undead;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedTauren, 12, 0, -1, 'Borrowed Gray Kodo', `displayid`, 1, 1, 1, 1, @SpellTauren, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1Tauren;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedGnome, 12, 0, -1, 'Borrowed Blue Mechanostrider', `displayid`, 1, 1, 1, 1, @SpellGnome, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1Gnome;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedTroll, 12, 0, -1, 'Borrowed Violet Raptor', `displayid`, 1, 1, 1, 1, @SpellTroll, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1Troll;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedBloodElf, 12, 0, -1, 'Borrowed Purple Hawkstrider', `displayid`, 1, 1, 1, 1, @SpellBloodElf, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1BloodElf;
INSERT INTO `item_template` (`entry`, `class`, `subclass`, `SoundOverrideSubclass`, `name`, `displayid`, `Quality`, `ItemLevel`, `maxcount`, `stackable`, `spellid_1`, `spelltrigger_1`, `spellcharges_1`, `spellcooldown_1`, `bonding`, `description`, `Material`, `VerifiedBuild`)
SELECT @BorrowedDraenei, 12, 0, -1, 'Borrowed Purple Elekk', `displayid`, 1, 1, 1, 1, @SpellDraenei, 0, 0, -1, 4, 'Only while you are taking it to the stables, and only nearby.', -1, 0 FROM `item_template` WHERE `entry` = @Choice1Draenei;

-- The quests
DELETE FROM `quest_template` WHERE `ID` IN (@QuestHuman, @QuestOrc, @QuestDwarf, @QuestNightElf, @QuestUndead, @QuestTauren, @QuestGnome, @QuestTroll, @QuestBloodElf, @QuestDraenei);
DELETE FROM `quest_template_addon` WHERE `ID` IN (@QuestHuman, @QuestOrc, @QuestDwarf, @QuestNightElf, @QuestUndead, @QuestTauren, @QuestGnome, @QuestTroll, @QuestBloodElf, @QuestDraenei);
DELETE FROM `creature_queststarter` WHERE `quest` IN (@QuestHuman, @QuestOrc, @QuestDwarf, @QuestNightElf, @QuestUndead, @QuestTauren, @QuestGnome, @QuestTroll, @QuestBloodElf, @QuestDraenei);
DELETE FROM `creature_questender` WHERE `quest` IN (@QuestHuman, @QuestOrc, @QuestDwarf, @QuestNightElf, @QuestUndead, @QuestTauren, @QuestGnome, @QuestTroll, @QuestBloodElf, @QuestDraenei);
INSERT INTO `quest_template` (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `StartItem`, `RewardDisplaySpell`, `RewardSpell`,
    `RewardChoiceItemID1`, `RewardChoiceItemQuantity1`, `RewardChoiceItemID2`, `RewardChoiceItemQuantity2`,
    `RewardChoiceItemID3`, `RewardChoiceItemQuantity3`, `RewardChoiceItemID4`, `RewardChoiceItemQuantity4`,
    `RewardChoiceItemID5`, `RewardChoiceItemQuantity5`, `RewardChoiceItemID6`, `RewardChoiceItemQuantity6`,
    `AllowableRaces`, `LogTitle`, `LogDescription`, `QuestDescription`, `QuestCompletionLog`, `VerifiedBuild`) VALUES
(@QuestHuman, 2, @RidingLevel, @RidingLevel, @BorrowedHuman, 33388, 33389, @Choice1Human, IF(@Choice1Human <> 0, 1, 0), @Choice2Human, IF(@Choice2Human <> 0, 1, 0), @Choice3Human, IF(@Choice3Human <> 0, 1, 0), @Choice4Human, IF(@Choice4Human <> 0, 1, 0), @Choice5Human, IF(@Choice5Human <> 0, 1, 0), @Choice6Human, IF(@Choice6Human <> 0, 1, 0), 1, 'A Mount of Your Own',
    'Ride the borrowed Black Stallion to Katie Hunter at Eastvale Logging Camp.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Black Stallion; it knows the way.$B$BRide it over to Katie Hunter at Eastvale Logging Camp. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Black Stallion to Katie Hunter.', 0),
(@QuestOrc, 2, @RidingLevel, @RidingLevel, @BorrowedOrc, 33388, 33389, @Choice1Orc, IF(@Choice1Orc <> 0, 1, 0), @Choice2Orc, IF(@Choice2Orc <> 0, 1, 0), @Choice3Orc, IF(@Choice3Orc <> 0, 1, 0), @Choice4Orc, IF(@Choice4Orc <> 0, 1, 0), @Choice5Orc, IF(@Choice5Orc <> 0, 1, 0), @Choice6Orc, IF(@Choice6Orc <> 0, 1, 0), 2, 'A Mount of Your Own',
    'Ride the borrowed Brown Wolf to Ogunaro Wolfrunner in the Valley of Honor.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Brown Wolf; it knows the way.$B$BRide it over to Ogunaro Wolfrunner in the Valley of Honor. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Brown Wolf to Ogunaro Wolfrunner.', 0),
(@QuestDwarf, 2, @RidingLevel, @RidingLevel, @BorrowedDwarf, 33388, 33389, @Choice1Dwarf, IF(@Choice1Dwarf <> 0, 1, 0), @Choice2Dwarf, IF(@Choice2Dwarf <> 0, 1, 0), @Choice3Dwarf, IF(@Choice3Dwarf <> 0, 1, 0), @Choice4Dwarf, IF(@Choice4Dwarf <> 0, 1, 0), @Choice5Dwarf, IF(@Choice5Dwarf <> 0, 1, 0), @Choice6Dwarf, IF(@Choice6Dwarf <> 0, 1, 0), 4, 'A Mount of Your Own',
    'Ride the borrowed White Ram to Veron Amberstill at Amberstill Ranch.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this White Ram; it knows the way.$B$BRide it over to Veron Amberstill at Amberstill Ranch. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed White Ram to Veron Amberstill.', 0),
(@QuestNightElf, 2, @RidingLevel, @RidingLevel, @BorrowedNightElf, 33388, 33389, @Choice1NightElf, IF(@Choice1NightElf <> 0, 1, 0), @Choice2NightElf, IF(@Choice2NightElf <> 0, 1, 0), @Choice3NightElf, IF(@Choice3NightElf <> 0, 1, 0), @Choice4NightElf, IF(@Choice4NightElf <> 0, 1, 0), @Choice5NightElf, IF(@Choice5NightElf <> 0, 1, 0), @Choice6NightElf, IF(@Choice6NightElf <> 0, 1, 0), 8, 'A Mount of Your Own',
    'Ride the borrowed Striped Frostsaber to Lelanai in the Cenarion Enclave.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Striped Frostsaber; it knows the way.$B$BRide it over to Lelanai in the Cenarion Enclave. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Striped Frostsaber to Lelanai.', 0),
(@QuestUndead, 2, @RidingLevel, @RidingLevel, @BorrowedUndead, 33388, 33389, @Choice1Undead, IF(@Choice1Undead <> 0, 1, 0), @Choice2Undead, IF(@Choice2Undead <> 0, 1, 0), @Choice3Undead, IF(@Choice3Undead <> 0, 1, 0), @Choice4Undead, IF(@Choice4Undead <> 0, 1, 0), @Choice5Undead, IF(@Choice5Undead <> 0, 1, 0), @Choice6Undead, IF(@Choice6Undead <> 0, 1, 0), 16, 'A Mount of Your Own',
    'Ride the borrowed Red Skeletal Horse to Zachariah Post in Brill.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Red Skeletal Horse; it knows the way.$B$BRide it over to Zachariah Post in Brill. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Red Skeletal Horse to Zachariah Post.', 0),
(@QuestTauren, 2, @RidingLevel, @RidingLevel, @BorrowedTauren, 33388, 33389, @Choice1Tauren, IF(@Choice1Tauren <> 0, 1, 0), @Choice2Tauren, IF(@Choice2Tauren <> 0, 1, 0), @Choice3Tauren, IF(@Choice3Tauren <> 0, 1, 0), @Choice4Tauren, IF(@Choice4Tauren <> 0, 1, 0), @Choice5Tauren, IF(@Choice5Tauren <> 0, 1, 0), @Choice6Tauren, IF(@Choice6Tauren <> 0, 1, 0), 32, 'A Mount of Your Own',
    'Ride the borrowed Gray Kodo to Harb Clawhoof in Bloodhoof Village.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Gray Kodo; it knows the way.$B$BRide it over to Harb Clawhoof in Bloodhoof Village. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Gray Kodo to Harb Clawhoof.', 0),
(@QuestGnome, 2, @RidingLevel, @RidingLevel, @BorrowedGnome, 33388, 33389, @Choice1Gnome, IF(@Choice1Gnome <> 0, 1, 0), @Choice2Gnome, IF(@Choice2Gnome <> 0, 1, 0), @Choice3Gnome, IF(@Choice3Gnome <> 0, 1, 0), @Choice4Gnome, IF(@Choice4Gnome <> 0, 1, 0), @Choice5Gnome, IF(@Choice5Gnome <> 0, 1, 0), @Choice6Gnome, IF(@Choice6Gnome <> 0, 1, 0), 64, 'A Mount of Your Own',
    'Ride the borrowed Blue Mechanostrider to Milli Featherwhistle at Steelgrill\'s Depot.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Blue Mechanostrider; it knows the way.$B$BRide it over to Milli Featherwhistle at Steelgrill\'s Depot. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Blue Mechanostrider to Milli Featherwhistle.', 0),
(@QuestTroll, 2, @RidingLevel, @RidingLevel, @BorrowedTroll, 33388, 33389, @Choice1Troll, IF(@Choice1Troll <> 0, 1, 0), @Choice2Troll, IF(@Choice2Troll <> 0, 1, 0), @Choice3Troll, IF(@Choice3Troll <> 0, 1, 0), @Choice4Troll, IF(@Choice4Troll <> 0, 1, 0), @Choice5Troll, IF(@Choice5Troll <> 0, 1, 0), @Choice6Troll, IF(@Choice6Troll <> 0, 1, 0), 128, 'A Mount of Your Own',
    'Ride the borrowed Violet Raptor to Zjolnir in Sen\'jin Village.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Violet Raptor; it knows the way.$B$BRide it over to Zjolnir in Sen\'jin Village. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Violet Raptor to Zjolnir.', 0),
(@QuestBloodElf, 2, @RidingLevel, @RidingLevel, @BorrowedBloodElf, 33388, 33389, @Choice1BloodElf, IF(@Choice1BloodElf <> 0, 1, 0), @Choice2BloodElf, IF(@Choice2BloodElf <> 0, 1, 0), @Choice3BloodElf, IF(@Choice3BloodElf <> 0, 1, 0), @Choice4BloodElf, IF(@Choice4BloodElf <> 0, 1, 0), @Choice5BloodElf, IF(@Choice5BloodElf <> 0, 1, 0), @Choice6BloodElf, IF(@Choice6BloodElf <> 0, 1, 0), 512, 'A Mount of Your Own',
    'Ride the borrowed Purple Hawkstrider to Winaestra at Thuron\'s Livery.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Purple Hawkstrider; it knows the way.$B$BRide it over to Winaestra at Thuron\'s Livery. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Purple Hawkstrider to Winaestra.', 0),
(@QuestDraenei, 2, @RidingLevel, @RidingLevel, @BorrowedDraenei, 33388, 33389, @Choice1Draenei, IF(@Choice1Draenei <> 0, 1, 0), @Choice2Draenei, IF(@Choice2Draenei <> 0, 1, 0), @Choice3Draenei, IF(@Choice3Draenei <> 0, 1, 0), @Choice4Draenei, IF(@Choice4Draenei <> 0, 1, 0), @Choice5Draenei, IF(@Choice5Draenei <> 0, 1, 0), @Choice6Draenei, IF(@Choice6Draenei <> 0, 1, 0), 1024, 'A Mount of Your Own',
    'Ride the borrowed Purple Elekk to Torallius the Pack Handler in the Exodar.',
    'Every traveler needs a good mount, $N, and you''ve walked enough. Take this Purple Elekk; it knows the way.$B$BRide it over to Torallius the Pack Handler in the Exodar. Pick whichever mount suits you, and you''ll learn to ride it properly.$B$BMind you, it''s borrowed: it goes back to the stables, and it won''t carry you anywhere else.',
    'Bring the borrowed Purple Elekk to Torallius the Pack Handler.', 0);
INSERT INTO `quest_template_addon` (`ID`, `ProvidedItemCount`) VALUES (@QuestHuman, 1), (@QuestOrc, 1), (@QuestDwarf, 1), (@QuestNightElf, 1), (@QuestUndead, 1), (@QuestTauren, 1), (@QuestGnome, 1), (@QuestTroll, 1), (@QuestBloodElf, 1), (@QuestDraenei, 1);
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES (@StarterHuman, @QuestHuman), (@StarterOrc, @QuestOrc), (@StarterDwarf, @QuestDwarf), (@StarterNightElf, @QuestNightElf), (@StarterUndead, @QuestUndead), (@StarterTauren, @QuestTauren), (@StarterGnome, @QuestGnome), (@StarterTroll, @QuestTroll), (@StarterBloodElf, @QuestBloodElf), (@StarterDraenei, @QuestDraenei);
INSERT INTO `creature_questender` (`id`, `quest`) VALUES (@EnderHuman, @QuestHuman), (@EnderOrc, @QuestOrc), (@EnderDwarf, @QuestDwarf), (@EnderNightElf, @QuestNightElf), (@EnderUndead, @QuestUndead), (@EnderTauren, @QuestTauren), (@EnderGnome, @QuestGnome), (@EnderTroll, @QuestTroll), (@EnderBloodElf, @QuestBloodElf), (@EnderDraenei, @QuestDraenei);
UPDATE `creature_template` SET `npcflag` = `npcflag` | 2 WHERE `entry` IN (@StarterHuman, @EnderHuman, @StarterOrc, @EnderOrc, @StarterDwarf, @EnderDwarf, @StarterNightElf, @EnderNightElf, @StarterUndead, @EnderUndead, @StarterTauren, @EnderTauren, @StarterGnome, @EnderGnome, @StarterTroll, @EnderTroll, @StarterBloodElf, @EnderBloodElf, @StarterDraenei, @EnderDraenei);

-- The borrowed mount can only be cast in the quest's zones, while the quest is in the log (not yet turned in):
-- quest_start_status 10 = complete (2) or incomplete (8). Leaving the zone drops the mount.
DELETE FROM `spell_area` WHERE `spell` IN (@SpellHuman, @SpellOrc, @SpellDwarf, @SpellNightElf, @SpellUndead, @SpellTauren, @SpellGnome, @SpellTroll, @SpellBloodElf, @SpellDraenei);
INSERT INTO `spell_area` (`spell`, `area`, `quest_start`, `quest_start_status`, `quest_end`, `quest_end_status`, `autocast`)
SELECT @SpellHuman, @ZoneHumanA, @QuestHuman, 10, 0, 11, 0 FROM DUAL WHERE @ZoneHumanA <> 0
UNION ALL SELECT @SpellHuman, @ZoneHumanB, @QuestHuman, 10, 0, 11, 0 FROM DUAL WHERE @ZoneHumanB <> 0
UNION ALL SELECT @SpellOrc, @ZoneOrcA, @QuestOrc, 10, 0, 11, 0 FROM DUAL WHERE @ZoneOrcA <> 0
UNION ALL SELECT @SpellOrc, @ZoneOrcB, @QuestOrc, 10, 0, 11, 0 FROM DUAL WHERE @ZoneOrcB <> 0
UNION ALL SELECT @SpellDwarf, @ZoneDwarfA, @QuestDwarf, 10, 0, 11, 0 FROM DUAL WHERE @ZoneDwarfA <> 0
UNION ALL SELECT @SpellDwarf, @ZoneDwarfB, @QuestDwarf, 10, 0, 11, 0 FROM DUAL WHERE @ZoneDwarfB <> 0
UNION ALL SELECT @SpellNightElf, @ZoneNightElfA, @QuestNightElf, 10, 0, 11, 0 FROM DUAL WHERE @ZoneNightElfA <> 0
UNION ALL SELECT @SpellNightElf, @ZoneNightElfB, @QuestNightElf, 10, 0, 11, 0 FROM DUAL WHERE @ZoneNightElfB <> 0
UNION ALL SELECT @SpellUndead, @ZoneUndeadA, @QuestUndead, 10, 0, 11, 0 FROM DUAL WHERE @ZoneUndeadA <> 0
UNION ALL SELECT @SpellUndead, @ZoneUndeadB, @QuestUndead, 10, 0, 11, 0 FROM DUAL WHERE @ZoneUndeadB <> 0
UNION ALL SELECT @SpellTauren, @ZoneTaurenA, @QuestTauren, 10, 0, 11, 0 FROM DUAL WHERE @ZoneTaurenA <> 0
UNION ALL SELECT @SpellTauren, @ZoneTaurenB, @QuestTauren, 10, 0, 11, 0 FROM DUAL WHERE @ZoneTaurenB <> 0
UNION ALL SELECT @SpellGnome, @ZoneGnomeA, @QuestGnome, 10, 0, 11, 0 FROM DUAL WHERE @ZoneGnomeA <> 0
UNION ALL SELECT @SpellGnome, @ZoneGnomeB, @QuestGnome, 10, 0, 11, 0 FROM DUAL WHERE @ZoneGnomeB <> 0
UNION ALL SELECT @SpellTroll, @ZoneTrollA, @QuestTroll, 10, 0, 11, 0 FROM DUAL WHERE @ZoneTrollA <> 0
UNION ALL SELECT @SpellTroll, @ZoneTrollB, @QuestTroll, 10, 0, 11, 0 FROM DUAL WHERE @ZoneTrollB <> 0
UNION ALL SELECT @SpellBloodElf, @ZoneBloodElfA, @QuestBloodElf, 10, 0, 11, 0 FROM DUAL WHERE @ZoneBloodElfA <> 0
UNION ALL SELECT @SpellBloodElf, @ZoneBloodElfB, @QuestBloodElf, 10, 0, 11, 0 FROM DUAL WHERE @ZoneBloodElfB <> 0
UNION ALL SELECT @SpellDraenei, @ZoneDraeneiA, @QuestDraenei, 10, 0, 11, 0 FROM DUAL WHERE @ZoneDraeneiA <> 0
UNION ALL SELECT @SpellDraenei, @ZoneDraeneiB, @QuestDraenei, 10, 0, 11, 0 FROM DUAL WHERE @ZoneDraeneiB <> 0;
