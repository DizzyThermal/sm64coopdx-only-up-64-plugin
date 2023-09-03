# Only Up 64 Plugin (sm64ex-coop)

* Note: This is NOT the [Only Up 64 Map](https://github.com/DizzyThermal/sm64ex-coop-only-up-64)

## Features

### Toggle Height (Y-Coordinate) on HUD / Player list:

* `/only-up-height` - Toggle displaying character height on HUD and player list.

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

### Warp System (from Alpha Testing)

`/w <area #>`

* Areas 1 - 7 can be warped to

#### Examples

* `/w 1` - Warp to Bottom of Area 1
* `/w 1 11` - Warp to Top of Area 1
* `/w 7 11` - Warp to Top of Area 7 (Smoke Stacks)
* `/w 7 13` - Warp to Top of Area 7 (Mario)

## Chat Commands

* `/only-up-height` - Toggle displaying character height on HUD and player list
* `/only-up-moveset` - Toggle Only Up 64 Moveset
* `/only-up-warps` - Toggle Only Up 64 Warps [Host Only]

## Changes

* Added Debug Warp system from Only Up 64 Alpha testing to Only Up 64 Plugin (Default Off)
* Being able to change directions when ground pound diving
* Using the triple jump action for the ground pound jump (removed original ground pound jump)
* Sparkles on frame-perfect dive rollouts, wallkicks, and speed kicks.
* Less jank and higher gravity on the wall slide.
* Merging changes from the Only Up 64 Alpha Tests
* Decreased Ground Pound Twirl Y-Boost (42.0 -> 40.0)
* Decreased Ground Pound Twirl Count (20 -> 10)
* Allow Wallslide after Long Jump (Like Only Up 64)

## Known Issues

* Ground Pound Twirl ends in a `ACT_FORWARD_ROLLOUT` to make sure you cannot ground pound consecutively. This means Mario
  does a frontflip before entering free fall.

## Credits

* Ground Pound Jump, Ground Pound Dive, and Wallslide are from `mods/extended-moveset.lua` with some modifications
* Moveset contributors: @steven3004
* sm64ex-coop technical help: @cooliokid956, @andre8739
* Testing help: @retrodarkgamerx, @cooliokid956
