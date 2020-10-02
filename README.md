## A minimalistic example of a Löve "game" with character movement and drawing sprites using the Concord ECS among other good community libraries.

The idea of this repo is to serve as a minimal but functional example on how to set up a game template using common patterns such as:

- Using an Entity Component System (ECS) for separating logic from data, with each part of the game handled in their corresponding systems
- Game state management (currently just switches to "ingame")
- Separate of concerns (thanks to the ECS)

Also features a media manager that loads your media into an atlas manager that you can query with hierarchical accessors like 'decals.bushes.purpleBush' based on the directory hierarchy.

#### Usage (requires love installed on your system)
```
git clone https://github.com/speakk/love_minimal_gameish
cd love_minimal_gameish
love ./
```

#### Libaries used
- Love (the actual game library) [https://love2d.org/](https://love2d.org/)
- Concord (Entity Component System lib) [https://github.com/Tjakka5/Concord](https://github.com/Tjakka5/Concord/)
- batteries (handy util functions) [https://github.com/1bardesign/batteries/](https://github.com/1bardesign/batteries/)
- hump (for gamestate and classes) [https://github.com/vrld/hump](https://github.com/vrld/hump/)
- brinevector (fast vector maths) [https://github.com/novemberisms/brinevector](https://github.com/novemberisms/brinevector)

If you have any questions or comments, feel free to pop by at the [official Love Discord server](https://discord.gg/rhUets9) and say hi.

#### A screenshot (that lil fella moves with w-a-s-d)
![Screenshot](screenshot.jpg)