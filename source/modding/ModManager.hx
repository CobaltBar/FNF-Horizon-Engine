package modding;

import haxe.io.Path as Path;
import modding.Mod.ModJsonData;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class ModManager
{
	final folders:Array<String> = [
		"achievements", "characters", "charts", "custom_events", "custom_notetypes", "fonts", "images", "menu_scripts", "scripts", "shaders", "songs",
		"sounds", "stages", "videos", "weeks"
	];

	public static var discoveredMods:Array<Mod> = [];
	public static var allMods:Array<Mod> = []; // discoveredMods - enabledMods
	public static var enabledMods:Array<Mod> = [];

	public static function loadMods():Void
	{
		for (modDir in FileSystem.readDirectory("mods"))
		{
			if (!FileSystem.isDirectory(Path.combine(["mods", modDir])) || modDir == "Mod Template")
				continue;
			if (FileSystem.exists(Path.combine(["mods", modDir, "mod.json"])))
			{
				var json:ModJsonData = TJSON.parse(File.getContent(Path.combine(["mods", modDir, "mod.json"])));
				discoveredMods.push(new Mod(json.name, json.description, json.version, json.color, json.globalMod, json.rpcChange,
					Path.combine(["mods", modDir]),
					FileSystem.exists(Path.combine(["mods", modDir, "mod.png"])) ? Path.combine(["mods", modDir, "mod.png"]) : Path.image("unknownMod")));
			}
			else
				discoveredMods.push(new Mod(modDir, "Unknown", "1.0", [255, 255, 255], true, "", Path.combine(["mods", modDir]),
					FileSystem.exists(Path.combine(["mods", modDir, "mod.png"])) ? Path.combine(["mods", modDir, "mod.png"]) : Path.image("unknownMod")));
		}

		allMods = discoveredMods;

		for (mod in discoveredMods)
			if (Settings.data.savedMods.exists(mod))
			{
				enabledMods.push(mod);
				allMods.remove(mod);
			}
	}

	public static function reloadMods():Void
	{
		discoveredMods = [];
		enabledMods = [];
		loadMods();
	}
}
