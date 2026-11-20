# mod-temucraft-first-mount

Your first mount, as a quest. Each race's riding trainer hands you a **borrowed mount** and asks you to bring it to the race's mount vendor. There you **pick your first mount** from several (a quest reward choice) and learn **Apprentice Riding**.

The borrowed mount is a quest item:
- it's given when you accept the quest and taken back when you turn it in or abandon it;
- it can be ridden as often as you like, but only while the quest is in your log and only in the quest's zones;
- leaving those zones, abandoning or finishing the quest takes you off it.

Riding (the quest's mounts and the trainer's Apprentice Riding) is lowered to level 5, changeable in the SQL.

| Race | Quest from | Turned in to | Borrowed mount works in (zone IDs) | Quest / item / spell |
|---|---|---|---|---|
| Human | Falkhaan Isenstrider in Goldshire | Katie Hunter at Eastvale Logging Camp | 12 | 602110 / 602120 / 95330 |
| Orc | Kildar in the Valley of Honor | Ogunaro Wolfrunner in the Valley of Honor | 14, 1637 | 602111 / 602121 / 95331 |
| Dwarf | Ultham Ironhorn at Amberstill Ranch | Veron Amberstill at Amberstill Ranch | 1 | 602112 / 602122 / 95332 |
| NightElf | Jartsam in the Cenarion Enclave | Lelanai in the Cenarion Enclave | 141, 1657 | 602113 / 602123 / 95333 |
| Undead | Velma Warnam in Brill | Zachariah Post in Brill | 85 | 602114 / 602124 / 95334 |
| Tauren | Kar Stormsinger in Bloodhoof Village | Harb Clawhoof in Bloodhoof Village | 215 | 602115 / 602125 / 95335 |
| Gnome | Binjy Featherwhistle at Steelgrill's Depot | Milli Featherwhistle at Steelgrill's Depot | 1 | 602116 / 602126 / 95336 |
| Troll | Xar'Ti in Sen'jin Village | Zjolnir in Sen'jin Village | 14 | 602117 / 602127 / 95337 |
| BloodElf | Perascamin at Thuron's Livery | Winaestra at Thuron's Livery | 3430, 3487 | 602118 / 602128 / 95338 |
| Draenei | Aalun in the Exodar | Torallius the Pack Handler in the Exodar | 3524, 3557 | 602119 / 602129 / 95339 |

## Custom races

The custom playable races of mod-worgoblin-high-elf (ChrRaces 9 and 12-30) get their own copy of the quest of their
home race (`mod_temucraft_first_mount_races.sql`): same quest giver, turn-in NPC, borrowed mount and zones, but
their own mounts on offer. The race's own mounts come first, when they are in `item_template` and Apprentice Riding
can ride them (the swift ones are skipped); the home race's mounts fill the free slots, up to six. Every mount on
offer is made usable by the race (its bit is added to the item's `AllowableRace`), and is usable from `@RidingLevel`.

| Race | Home race (quest NPCs, borrowed mount) | Own mounts first | Quest |
|---|---|---|---|
| Goblin | Orc | Goblin Trike (62461) | 602140 |
| Worgen | Night Elf | Mountain Horse (73838) | 602141 |
| Pandaren (Alliance) | Human | Blue, Purple, Green and Black Dragon Turtle (91009, 91006, 91004, 91008) | 602142 |
| Pandaren (Horde) | Tauren | the same dragon turtles | 602143 |
| Nightborne | Blood Elf | Nightborne Manasaber (156487) | 602144 |
| Highmountain Tauren | Tauren | Highmountain Thunderhoof (155662) | 602145 |
| Void Elf | Night Elf | Starcursed Voidstrider (156486) | 602146 |
| Lightforged Draenei | Draenei | the Felcrushers (155656, 153043, 153044, 153042) | 602147 |
| Zandalari Troll | Troll | Zandalari Direhorn (157870) | 602148 |
| Kul Tiran | Human | Kul Tiran Charger (164762) | 602149 |
| Vulpera | Tauren | Caravan Hyena with and without canopy (174066, 174065) | 602150 |
| Dark Iron Dwarf | Dwarf | Dark Iron Core Hound (161331) | 602151 |
| Mag'har Orc | Orc | Mag'har Direwolf (161330) | 602152 |
| Mechagnome | Gnome | mechanostriders (no racial mount in our data; the gnome mount fits a mechagnome) | 602153 |
| Dracthyr (Alliance) | Human | **Blue Ground Drake** (602160, new) | 602154 |
| Dracthyr (Horde) | Orc | **Red Ground Drake** (602161, new) | 602155 |
| Earthen (Alliance) | Dwarf | rams (their racial mount is a stone ram) | 602156 |
| Earthen (Horde) | Orc | rams, then wolves | 602157 |
| Haranir (Alliance) | Night Elf | nightsabers (forest folk) | 602158 |
| Haranir (Horde) | Troll | raptors (forest folk) | 602159 |

The racial mounts are the items of the race modpaks of mod-worgoblin-high-elf; a race whose modpak is not built simply
gets its home race's mounts. The Dracthyr have no ground mount anywhere in our data, so this module adds two:
spells 95350-95351 (+60%, Apprentice Riding, the Blue Drake and Red Drake models) and their reins, items
602160-602161. They live here and not in mod-worgoblin-high-elf because they only exist for this quest and this
module already carries the Spell.dbc patch and `spell_dbc` rows for its mounts.

The race list is the table `temucraft_first_mount_race` (race, home race, quest, own mounts). The script reads it at
startup: a custom race's quest also takes the borrowed mount away, and "An Old Ride" teaches the slow mount of the
home race. A race added to mod-worgoblin-high-elf later: add a row there and run the file again.

## An Old Ride (slow mount, free)

The NPC who sends you out of each starting zone (Marshal McBride, Ukor, Sten Stoutarm, Porthannius, Deathguard Simmer,
Chief Hawkwind, Lanthan Perilon, Proenitus) offers **An Old Ride** (quest 602130): turn it in right away and you
learn an old mount of your race's kind. It's free, needs no riding skill and runs at +30% speed (a trained mount is
+60%). Spells 95340-95349, in `Spell.dbc` (client) and `mod_temucraft_first_mount_slow.sql` (server). Custom races get the
slow mount of their home race (see Custom races below); other races get the horse (Alliance) or the wolf (Horde).

## Install

1. Put this folder in `modules/` of your AzerothCore source, re-run CMake and build.
2. The SQL in `data/sql/db-world/base/` is applied by the worldserver on its next start. Every file deletes its own rows before inserting them, so running one again is safe.
   Copy `conf/mod-temucraft-first-mount.conf.dist` to your `configs/modules/` as `mod-temucraft-first-mount.conf` to change its settings.
3. **Client.** `client/patch-F.MPQ/` is a patch folder, not a packed MPQ: pack it yourself (for example with Ladik's MPQ Editor: new MPQ, add the folder contents keeping the `DBFilesClient\` path) and put the `.MPQ` in the game's `Data/` folder. Its `Spell.dbc` is the stock 3.3.5a (12340) file plus the borrowed mount spells (95330-95339), the slow mounts (95340-95349) and the Dracthyr ground drakes (95350-95351).
   **Using more than one Temucraft module, or other DBC changes?** Two patches that both carry `Spell.dbc` overwrite each other. Use the all-in-one patch from the Temucraft configuration repo (`client/patch-5.MPQ/`), or merge the rows yourself. The server side never conflicts: it reads the spells from `spell_dbc`.

## Customising

Everything is in the `SET` blocks at the top of `data/sql/db-world/base/mod_temucraft_first_mount.sql`, like the AzerothCore-Additions SQL:
- `@RidingLevel`, `@RidingCost`: the level to ride, and the trainer's price for Apprentice Riding.
- `@QuestFirst`, `@BorrowedFirst`: change the first quest and item ID, the rest follow.
- Per race: `@Starter...` and `@Ender...` (who gives and takes the quest), `@Zone...A/B` (where the borrowed mount works, 0 = none), `@Choice1...` to `@Choice6...` (the mounts on offer, 0 = empty slot).
- The borrowed mount spells (95330-95339) are also in the DBCs; change them together with `mod_temucraft_first_mount_dbc.sql`, `client/` and the config.
- If you change `@QuestFirst`, also set `Temucraft.FirstMount.QuestFirst` in the config.

`data/sql/optional/` has extras that are **not** run automatically; run them yourself if you want them:
- `starting_bag.sql`: every new character starts with an extra bag (which bag and how many are `SET` at the top).

## What it adds, and where

| Database | Table | IDs |
|---|---|---|
| world | `quest_template`, `quest_template_addon` | 602110-602119 |
| world | `creature_queststarter`, `creature_questender` | the riding trainers and mount vendors above (they get the quest giver flag) |
| world | `item_template` | 602120-602129 (borrowed mounts); the mounts on offer get `RequiredLevel` = `@RidingLevel` |
| world | `trainer_spell` | Apprentice Riding (33388): price and level |
| world | `spell_area` | 95330-95339: only in the quest's zones, only with the quest |
| world | `quest_template`, `quest_template_addon`, `creature_queststarter`, `creature_questender`, `spell_area` | 602140-602159 (custom races, copies of the home race's quest) |
| world | `item_template` | 602160-602161 (Dracthyr ground drakes); the mounts offered to custom races get the race's bit in `AllowableRace` |
| world | `spell_dbc` | 95350-95351 (Dracthyr ground drakes) |
| world | `temucraft_first_mount_race` | the custom races, their home race, quest and own mounts |
| client | `Spell.dbc` | 95350-95351 |
| world | `spell_dbc` | 95330-95339 |
| client | `Spell.dbc` | 95330-95339 |

## Works with other modules

- Changes the `RequiredLevel` of the stock apprentice mounts and the price and level of Apprentice Riding at every riding trainer: another module changing those wins or loses depending on which runs last.
- Gives the riding trainers and mount vendors the quest giver flag.

## Independence

This module doesn't need any other module, nor any other Temucraft module.

Part of the Temucraft modules for AzerothCore 3.3.5a.
