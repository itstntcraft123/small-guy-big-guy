# small guy BIG GUY
small guy BIG GUY is a platformer made in Godot Engine. In this (local) multiplayer game, you and your friend try to solve levels together by reaching the portal. However, one of you is the small guy, who can walk faster and jump higher, while the other is the big guy, who can trigger heavier buttons and boost you up.

# How to Play
Small Guy uses WASD to move around (A D for movement, W to jump). Big Guy arrow keys to move around (← → for movement, ↑ to jump). To use a button, you must jump on top of it. You can coordinate movements (constructive interference!) to boost each other up.

# Features
This game features:
- game, level, and config autosaving. to see this in action, go to options > debug options > save indicator
- player weight that allows small guy to jump higher and big guy to press more buttons
- weighted buttons and anti-buttons
- players can ride on each other :D
- big guy can push small guy with a speed penalty
- a spritesheet that auto-connects blocks
- a game menu that can be accessed using escape or tab
- both keyboard and mouse support for UI
- built in FPS and TPS counter in options > debug options
- a nice smooth camera with auto-zoom

# Development
To develop, `git clone` this repo and use the Godot 4 editor.

## Installation
Grab a copy for your OS and architecture from releases and run it. To run the web build, unzip the file and host it using a web server. Or, you can try this out at the [itch page](https://itstntcraft.itch.io/small-guy-big-guy).

## Tech Stack
This game was made in Godot 4. To avoid spending time manually tiling the floor sprite, this awesome [autotiler](https://route1rodent.itch.io/autotiler) was used.

## Contributors
This game was made by rbird6 and itstntcraft123 as a team. rbird6 made most of the sprites, and we both worked on the code and levels.
