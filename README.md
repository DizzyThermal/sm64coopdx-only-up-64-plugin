# Only Up 64 Plugin (sm64ex-coop)

* Note: This is NOT the Only Up 64 Map. This is a mod to add character height (Y-Position) and the Only Up 64 moveset.

## Features

### Show Height (Y-Coordinate) on HUD:

* `/only_up_show_height on|off` - Show character height (Y) on HUD. Default is On.

![y-coordinate](./resources/y-coordinate.gif)

### Wallslide
#### _(Modified from: mods/extended-moveset.lua)_

* _Allows wallslide from long jump_

![wallslide](./resources/wallslide.gif)

### Ground Pound Twirl (Z, A)

* _Rollout after twirl is to not allow consecutive ground pound twirls_

![ground-pound-twirl](./resources/ground-pound-twirl.gif)

### Ground Pound Jump (Z, A on ground)
#### _(Modified from: mods/extended-moveset.lua)_

* _Triple front flip animation instead of jump twirl_

![ground-pound-jump](./resources/ground-pound-jump.gif)

### Ground Pound Dive (Z, B)
#### _(From: mods/extended-moveset.lua)_

![ground-pound-dive](./resources/ground-pound-dive.gif)

## Chat Commands

* `/only_up_show_height on|off` - Show character height (Y) on HUD. Default is On.
* `/only_up_moveset on|off` - Enable Only Up 64 Moveset. Default is On.`

## Changes

* Decreased Ground Pound Twirl Y-Boost (42.0 -> 40.0)
* Decreased Ground Pound Twirl Count (20 -> 10)
* Allow Wallslide after Long Jump (Like Only Up 64)

## Known Issues

* Ground Pound Twirl ends in a `ACT_FORWARD_ROLLOUT` to make sure you cannot ground pound consecutively. This means Mario
  does a frontflip before entering free fall.

## Credits

* Ground Pound Jump, Ground Pound Dive, and Wallslide are from `mods/extended-moveset.lua` with some modifications
* sm64ex-coop technical help: @cooliokid956, @andre8739
* Testing help: @retrodarkgamerx
