# Only Up 64 Plugin (sm64ex-coop)

* Note: This is NOT the [Only Up 64 Map](https://github.com/DizzyThermal/sm64ex-coop-only-up-64)

## Features

### Warp System (Disabled by Default)

![warp-menu](./resources/warp-menu.gif)

* To **enable the warp system**, the *host* or *moderator* must type:
    > `/only-up-warps`

* Once warps are enabled, to open the Warp Menu type:
    > `/only-up-practice`

* or use keybind: **`[X]`**

### Toggle Height (Y-Coordinate) on HUD / Player list:

> `/only-up-height` - Toggle Character height on HUD and Player List.

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

> `/only-up-height` - Toggle Character height on HUD and Player List

> `/only-up-moveset` - Toggle Only Up 64 Moveset

> `/only-up-warps` - Toggle Warps [Mod Only]

> `/only-up-practice` - **[X]** Warp Menu (Must be Enabled)

## Changes

* Added Warp Menu for Practice
* Added Flood Mod Support
* Added Area 8 and made the plugin compatible with all versions of Only Up 64
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