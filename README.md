# Roblox ECS Framework
Entity-Component-System framework for use in Roblox games

## About

What is an ECS?
* [Wikipedia](https://en.wikipedia.org/wiki/Entity%E2%80%93component%E2%80%93system)
* [http://entity-systems.wikidot.com/]

This framework uses a hybrid ECS so that Roblox's classes can be utilized. Wrapper components for these can be added.

## Requirements

In order to use this framework, you must have the [NevermoreEngine by Quenty](https://github.com/Quenty/NevermoreEngine) installed.

An easy way to install it is by pasting the following code into the command bar in Roblox Studio:

```lua
local h = game:GetService("HttpService")
local e = h.HttpEnabled h.HttpEnabled = true
loadstring(h:GetAsync("https://raw.githubusercontent.com/Quenty/NevermoreEngine/version2/Install.lua"))(e)
```

### ECS Compiler and Resources

Entities can be created in studio using instances then compiled into entities.

Scenes in this framework are known as EntityLists.

```lua
local ECSCompiler = require("RobloxECSCompiler")
```

## Examples

[ECS Obby (Uncopylocked)](https://www.roblox.com/games/1815190355/ECS-Obby)
* A short obstacle course game created with the framework and designed to work entirely client-side for single player games. Originally used to aid in designing the framework, now it may be unusuable with newer versions. Currently uses an older version but with the same API.

## To Do

- [ ] "Prefabs" 
- [ ] Documentation
- [ ] Make a game
- [X] Make a list
