# FNF Horizon Engine

FNF Horizon Engine is a rewrite of Friday Night Funkin', built for mods and made for fun.

(Formerly called Wonder Engine)

## Compilation Instructions

Install Haxe 4.3.6 (and install MSVC if on Windows)

NOTE: You may need to install extra packages on linux to compile lime, see [here](https://github.com/openfl/lime)

```bash
haxelib install hxpkg
haxelib run hxpkg install
cd .haxelib/hxcpp/git/tools/run
haxe compile.hxml
cd ../hxcpp
haxe compile.hxml
cd ../../../../..
haxelib run lime rebuild cpp -release
```

(The above commands install `hxpkg`, install all packages for Horizon Engine, builds the git version of `hxcpp`, and rebuilds lime so you can compile)

Then run the script corresponding to your OS in the build folder (you might have to `chmod +x` it)

## Special Thanks

- FunkinCrew
  - The Game
  - All assets that aren't listed below ([See License](https://github.com/FunkinCrew/funkin.assets/blob/main/LICENSE.md))
- Psych Engine
  - Alphabet image
  - Checkbox image and code
  - Mods image
  - Unknown Mod image
  - Story Menu Menu Characters
  - Story Mode Menu Backgrounds
  - Blue Menu Background Image (?)
  - Note movement code
  - 90% of Intro Texts

## Credits

- Cobalt Bar (Main Developer)
- Betopia (Note Sprite)
- crowplexus (Ordered Map/Dictionary)
- superpowers04 (Safer FlxGame)
- Sword352 (Tiled Sprite and Sustains, see source/objects/game/eternal/NOTE.txt)
