# FNF Horizon Engine

FNF Horizon Engine is a rewrite of Friday Night Funkin', built for mods and made for fun.

(Formerly called Wonder Engine)

## Credits

- Cobalt Bar (Creator)
- Betopia (Note sprite stuff)
- crowplexus (Ordered Map/Dictionary)
- Superpowers04 (Safer FlxGame)

## Special Thanks

- FunkinCrew
  - The game and most of the assets used belong to FunkinCrew. [See License](https://github.com/FunkinCrew/funkin.assets/blob/main/LICENSE.md)
- Psych Engine (Some assets, most introtexts, and some code)

## Compilation Instructions

Install Haxe 4.3.4 (and install MSVC if on Windows)

NOTE: You may need to install extra packages on linux to compile lime, see [here](https://github.com/openfl/lime)

```txt
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

Then run the script corresponding to your OS in the util\build folder (you might have to `chmod +x` it)
