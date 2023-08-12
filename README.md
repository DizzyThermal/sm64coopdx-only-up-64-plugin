# sm64ex-coop-only-up-64-plugin

## Features

### Show Height (Y-Coordinate)

* Show character height (Y-Coordinate) on HUD:

![y-coordinate](./resources/y-coordinate.gif)

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
