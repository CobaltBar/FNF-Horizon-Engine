package modding;

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

	static var discoveredMods:Array<Mod> = [];
	public static var disabledMods:Array<Mod> = [];
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

		disabledMods = discoveredMods;
		for (mod in disabledMods)
			for (saved in Settings.data.savedMods)
				if (Mod.isEqual(mod, saved))
				{
					enabledMods.push(mod);
					disabledMods.remove(mod);
				}
	}

	@:keep
	public static inline function reloadMods():Void
	{
		discoveredMods = enabledMods = disabledMods = [];
		loadMods();
	}
}
