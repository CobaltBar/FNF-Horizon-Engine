package modding;

import flixel.addons.util.FlxAsyncLoop;
import modding.Mod.ModJsonData;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class ModManager
{
	// final folders:Array<String> = [ "achievements", "characters", "charts", "custom_events", "custom_notetypes", "fonts", "images", "menu_scripts", "scripts", "shaders", "songs", "sounds", "stages", "videos", "weeks"];
	static var discoveredMods:Array<Mod> = [];
	public static var allMods:Array<Mod> = [];
	public static var enabledMods:Array<Mod> = [];

	public static function loadMods():Void
	{
		var i:Int = 0;
		for (mod in FileSystem.readDirectory('mods'))
			if (FileSystem.isDirectory(Path.combine(['mods', mod])))
			{
				if (mod == "Mod Template")
					continue;
				var json:ModJsonData = null;
				if (FileSystem.exists(Path.combine(['mods', mod, 'mod.json'])))
					json = TJSON.parse(File.getContent(Path.combine(['mods', mod, 'mod.json'])));
				discoveredMods.push(new Mod(json.name ?? mod, json.description ?? "N/A", json.version ?? "1.0", json.color ?? [255, 255, 255],
					json.rpcChange ?? "", json.modSysVer ?? InitState.modSysVer, Path.combine(['mods', mod]),
					FileSystem.exists(Path.combine(['mods', mod, 'mod.png'])) ? Path.combine(['mods', mod, 'mod.png']) : Path.image("unknownMod"), i));
				i++;
			}

		allMods = discoveredMods;
		enabledMods = Settings.data.savedMods;

		// superpowers04 is gonna kill me for this
		// if you know any other way to compare both sides is Mod.isEqual, PR it
		for (amod in allMods)
			for (bmod in enabledMods)
				if (amod == bmod)
					allMods.remove(amod);
				else
					enabledMods.remove(bmod);
	}

	public static function reloadMods():Void
	{
		discoveredMods = [];
		enabledMods = [];
		allMods = [];
		loadMods();
	}
}
