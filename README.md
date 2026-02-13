# Only Up 64 Plugin (sm64coopdx)

> [!NOTE]
> This is NOT the [Only Up 64 Map](https://github.com/DizzyThermal/sm64coopdx-only-up-64)

## Plugin Features

### Warp System (Disabled by Default)

![warp-menu](./resources/warp-menu.gif)

> [!NOTE]
> To **enable the warp system**, the *host* or *moderator* must type: `/ou64-warps`


> [!TIP]
> With warps enabled, type: `/ou64-practice` or use keybind: **`[X]`**

### Toggle Height (Y-Coordinate) on HUD / Player list:

> `/ou64-height` - Toggles Character height on HUD and Player List.

![y-coordinate](./resources/y-coordinate.gif)

### Ground Pound Twirl (A, Z, A)

* _Rollout after twirl is to not allow consecutive ground pound twirls_

![ground-pound-twirl](./resources/ground-pound-twirl.gif)

### Ground Pound Jump (A, Z, A on ground)

* _Triple front flip animation instead of jump twirl_

![ground-pound-jump](./resources/ground-pound-jump.gif)

### Ground Pound Dive (A, Z, B)

![ground-pound-dive](./resources/ground-pound-dive.gif)

### Wallslide

* _Allows wallslide from long jump_

![wallslide](./resources/wallslide.gif)

### Instant-Turn

* _Allows for the player to make 180-degree turns when moving slow enough_

## Chat Commands

> `/ou64-height` - Toggles Character height on HUD and Player List

> `/ou64-meter` - Toggles Height Meter

> `/ou64-moveset` - Toggles Only Up 64 Moveset

> `/ou64-checkpoints` - Toggles Checkpointing [Mod Only]

> `/ou64-warps` - Toggles Warps [Mod Only]

> `/ou64-practice` - Shows Warp Menu (Must be Enabled)

> `/ou64-run-timer` - Toggles Run Timer

> `/ou64-leaderboard` - Toggles Leaderboard

## Changes

* Added Leaderboard and Run Timer
* Added / Refactored Chat Commands
* Added Checkpoints - modified to work in different areas (thanks djoslin0!)
* Added exportable server metrics
* Refactored a lot of the code
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
* Checkpoints: @djoslin0
* Recolored player heads: @EmilyEmmi
* sm64coopdx technical help: @cooliokid956, @andre8739
* Testing help: @retrodarkgamerx, @cooliokid956, @colbyrayz.z64