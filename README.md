# ./pack.lua
A simple embedded Lua script packer designed for simplicity

## How to use
Download the `pack.lua` file and embed it in your project, it can be renamed to however you want and modified in any way you want, as long as you keep the license intact.

You will need a `main.lua` file as the core of your project and an _Unix-based OS_ (for now).
After you have both of those ready, you can simply run `./pack.lua` as an executable.

It will return a big `output.lua` file which is a mix of all your local lua files alongside a `.log` file which stores everything logged.

## Test it out!
    git clone https://github.com/darltrash/pack.lua
    cd pack.lua
    ./pack.lua
    lua output.lua

## Limitations
- No minifying mechanisms
- Only bundles the files found locally (No LuaRocks for example)
- No Windows support (yet)

## Roadmap
- [X] Package everything without inherent clashing
- [X] Add Logging features
- [X] Make it simple to use
- [ ] Add Windows support
- [ ] Add comptime features to add or remove code features with flags and no macros
- [ ] Minify code

## License
The license comes bundled within the pack.lua file as a comment.