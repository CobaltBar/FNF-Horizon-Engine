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
  - [The Game](https://github.com/FunkinCrew/Funkin)
  - [Assets](https://github.com/FunkinCrew/funkin.assets) - ([See License](https://github.com/FunkinCrew/funkin.assets/blob/main/LICENSE.md))
- [Psych Engine](https://github.com/ShadowMario/FNF-PsychEngine) - Assets

## Credits

- [Cobalt Bar](https://cobaltbar.github.io) - Main Developer
- [Betopia](https://betpowo.github.io/) - Note System/Sprite
- crowplexus and nebulazorua - Alt+Enter cancel + F11 fullscreen
- [superpowers04](https://github.com/superpowers04) - Safer FlxGame
- [Sword352/FnF-Eternal](https://github.com/Sword352/FnF-Eternal) - Tiled Sprite and Sustains
