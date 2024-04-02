package modding;

import modding.Mod.ModJsonData;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class ModManager
{
	// final folders:Array<String> = [ "achievements", "characters", "charts", "custom_events", "custom_notetypes", "fonts", "images", "menu_scripts", "scripts", "shaders", "songs", "sounds", "stages", "videos", "weeks"];
	public static var allMods:Map<String, Mod> = [];
	public static var enabledMods:Map<String, Mod> = [];

	public static function loadMods():Void
	{
		var i:Int = 0;
		for (mod in FileSystem.readDirectory('mods'))
			if (FileSystem.isDirectory(Path.combine(['mods', mod])))
			{
				if (mod == "Mod Template")
					continue;
				var json:ModJsonData = null;
				var modData:Mod;
				if (FileSystem.exists(Path.combine(['mods', mod, 'mod.json'])))
					json = TJSON.parse(File.getContent(Path.combine(['mods', mod, 'mod.json'])));
				modData = new Mod(json.name ?? mod, json.description ?? "N/A", json.version ?? "1.0", json.color ?? [255, 255, 255], json.rpcChange ?? "",
					json.modSysVer ?? InitState.modSysVer, mod,
					FileSystem.exists(Path.combine(['mods', mod, 'mod.png'])) ? Path.combine(['mods', mod, 'mod.png']) : Path.image("unknownMod"), i);
				if (FileSystem.exists(Path.combine(['mods', mod, 'menu_scripts']))
					&& FileSystem.isDirectory(Path.combine(['mods', mod, 'menu_scripts'])))
					for (script in FileSystem.readDirectory(Path.combine(['mods', mod, 'menu_scripts'])))
						if (!FileSystem.isDirectory(Path.combine(['mods', mod, 'menu_scripts', script])))
							if (haxe.io.Path.extension(Path.combine(['mods', mod, 'menu_scripts', script])) == 'lua'
								|| haxe.io.Path.extension(Path.combine(['mods', mod, 'menu_scripts', script])) == 'hx'
								&& !modData.staticMod)
								modData.staticMod = true;
				allMods.set(mod, modData);
				i++;
			}

		for (key => mod in allMods)
			if (Settings.data.savedMods.exists(key))
			{
				allMods[key].enabled = true;
				enabledMods.set(key, Settings.data.savedMods[key]);
			}
	}

	public static function reloadMods():Void
	{
		allMods.clear();
		enabledMods.clear();
		loadMods();
	}
}
