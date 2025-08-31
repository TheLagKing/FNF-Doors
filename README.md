# FNF : Doors Engine
The Engine from [FNF : Doors](https://gamebanana.com/mods/511813), allowing more interesting story mode things,
an easier programming support and some cool features from other engines.


## Credits:
* Leetram - Main Programmer of Doors Engine & FNF : Doors
* Ens4lada - Programmer
* Tiburones202 - Programmer [Hiii I "made" the mechanics manager and some modifiers]
* Winn - Programmer [Hi, I made the game exe icon into an SVG for automatic resizing, added ability to pause tweens (and other HaxeFlixel edits), help with porting old lua build to haxe source, small bugfixes and tweaks to stabilize psych base code]
* Shadow Mario - Psych Engine (This engine was built on Psych 0.6.2)
* Codename Crew - Codename Engine (This engine adds some functionnalities from Codename)
* Funkin Crew - V-Slice (This engine adds some functionnalities from Funkin)
* TheZoroForce240 & Edwhak_KB - Modcharting Tools

### Special Thanks:
* FNF : Doors Team - i love you guys
_____________________________________

# Features

## Items

Actual usable items that all have distinct effects. Think of them like the actual items from doors.

Items are defined as a `backend.storymode.InventoryManager.ItemData` object, containing :
  - itemID (The unique item identifier)
  - displayName (The displayed item name)
  - displayDesc (The displayed item description)
  - isPlural (Whether the item name is plural or not)
  - itemCoinPrice (The price of the item in coins)
  - itemKnobPrice (The price of the item in knobs)
  - itemSlot (The current slot where the item is stored)

  - durabilityRemaining (The durability remaining (in seconds, most of the time))
  - maxDurability (The maximum durability of the item (in seconds, most of the time))

  - ?statesAllowed ("story" / "play" depending on if you can use the item in STORY mode or PLAYstate)

Items are then added to the current run's InventoryManager object, which is simply a list of `ItemData` with extra steps

## Mechanic Manager

> [!CAUTION]
> More documentation will come in the official release of Doors Engine.

Softcoded-ish (They're still in the source code, but in an isolated file) mechanics that don't require adding 500 lines to PlayState.

## Doors-like Story Mode Support

> [!CAUTION]
> This system is fairly unstable. More documentation will come in the official release of Doors Engine.

## Modcharting

By using [FNF-Modcharting-Tools](https://github.com/EdwhakKB/FNF-Modcharting-Tools), we have a fully integrated modchart editor alongside a few modcharts. Please check them out and give them support, we only used their tool !

## Glasshat Support

We have our own online system, to avoid using insecure and non-proprietary systems, like gamejolt. It's currently used for accounts and leaderboards.