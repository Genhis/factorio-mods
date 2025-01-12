# Gun range visualizer

Adds a shortcut to toggle gun range visualization of the controlled character or vehicle. Useful if you are driving a tank or want to launch a nuke from the furthest possible distance.

## Features

- Keybind (CONTROL + SPACE by default) and shortcut bar button to toggle gun range visibility.
- Customizable range visualization colors - primary color and no ammo color.
- Multiplayer-compatible - each player only sees their range and can change settings according to their preference.
- Lightweight - the on_tick handler makes use of caching frequently-accessed data and if you have the mod installed but don't use it, the handler is inactive.

## Known issues

- Entering a vehicle in ramote view while the visualization is active does not refresh it. (https://forums.factorio.com/118769)
- Special [ammo types](https://lua-api.factorio.com/latest/prototypes/AmmoItemPrototype.html#ammo_type) based on source are not implemented (such as the flamethrower ammo which behaves differently for personal and vehicle flamethrower) - the visualization will only consider the default one.
