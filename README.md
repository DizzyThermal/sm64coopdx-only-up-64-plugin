# sm64ex-coop-only-up-64-plugin

* Adds a Character Height (Y) to the HUD
* Adds Only Up 64 Character Moveset:
  * Wallslide
  * Ground Pound Jump (GP, A on ground)
  * Ground Pound Twirl (GP, A)
  * Ground Pound Dive (GP, B)

## Chat Commands

* `/only_up_show_height on|off` - Show character height on HUDi (Y). Default is On.
* `/only_up_moveset on|off` - Enable Only Up 64 Moveset. Default is On.`

## Known Issues

* Ground Pound Twirl ends in a `ACT_FORWARD_ROLLOUT` to make sure you cannot ground pound consecutively. This means Mario
  does a frontflip before entering free fall.
