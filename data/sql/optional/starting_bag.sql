-- mod-temucraft-first-mount (optional, not run automatically): every new character starts with extra bag(s).
-- Run it yourself in acore_world if you want it. Re-runnable.
--
-- Pick any bag: https://wowgaming.altervista.org/aowow/?items=1.0&filter=cr=15:83:5;crs=2:2:2;crv=0:0:0#0-9+4-3-2

SET @StartingBag := 4501;                                   -- Deprecated Brown Wayfarer's Knapsack
SET @HowManyBags := 1;
SET @BagName     := 'Deprecated Brown Wayfarer''s Knapsack'; -- only a note in the table

-- race 0 and class 0 = every race and class
DELETE FROM `playercreateinfo_item` WHERE `race` = 0 AND `class` = 0 AND `itemid` = @StartingBag;
INSERT INTO `playercreateinfo_item` (`race`, `class`, `itemid`, `amount`, `Note`) VALUES (0, 0, @StartingBag, @HowManyBags, @BagName);
