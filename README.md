# pentasteroids
You need DUB: https://code.dlang.org/download  
and a D compiler, for example DMD: https://dlang.org/download.html#dmd  
Clone and "dub run" to play

# MacOs
For MacOs you also need to install sdl2, sdl2_image, sdl2_ttf, and sdl2_mixer

```
brew install sdl2 sdl2_image sdl2_ttf sdl2_mixer
```

Left mouse click toggles shooting
Middle mouse click toggles beam (currently instant kills everything it hits :bowtie: )

Font by [zacfreeland.com](http://zacfreeland.com/portfolio/cornerstone/)

To do:
* Refactor:
    * Menu item struct
    * Animation struct
    * Current appstate struct
* Clear vfx arrays on death
* Make scoring sensible again
* Draw score last
* Add alternative shoot buttons
* Make compact sprite with sprite packer
* Bomb weapon on right mouse button, instantly kill everything.
* Death animations
* More color variations for enemies
* Huge enemy orb, need bomb or beam to kill
* Background music, multilayered/random per background square
* Accelerating spawn timers (maybe not, spawning small from the big might be enough)
* ~~Beam weapon on middle mouse button, long range and OP~~.
* ~~Big orbs spawn smaller orbs on death~~


![Alt-text](http://i.imgur.com/muejR0C.png "menu screenshot")


![Alt-text](http://i.imgur.com/nPd6kW5.png "ingame screenshot")

