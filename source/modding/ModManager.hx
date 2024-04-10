package modding;

import modding.JsonTypedefs.WeekJsonData;
import modding.JsonTypedefs.ModJsonData;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class ModManager
{
	public static var allMods:Map<String, Mod> = [];
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
				var modData:Mod;
				if (FileSystem.exists(Path.combine(['mods', mod, 'mod.json'])))
				{
					json = TJSON.parse(File.getContent(Path.combine(['mods', mod, 'mod.json'])));
					modData = new Mod(json.name ?? mod, json.description ?? "N/A", json.version ?? "1.0", json.color ?? [255, 255, 255], json.rpcChange ?? "",
						json.modSysVer ?? InitState.modSysVer, mod,
						FileSystem.exists(Path.combine(['mods', mod, 'mod.png'])) ? Path.combine(['mods', mod, 'mod.png']) : Path.find("unknownMod", "png"), i);
				}
				else
					modData = new Mod(mod, "N/A", "1.0", [255, 255, 255], "", InitState.modSysVer, mod,
						FileSystem.exists(Path.combine(['mods', mod, 'mod.png'])) ? Path.combine(['mods', mod, 'mod.png']) : Path.find("unknownMod", "png"), i);
				if (FileSystem.exists(Path.combine(['mods', mod, 'menu_scripts']))
					&& FileSystem.isDirectory(Path.combine(['mods', mod, 'menu_scripts'])))
					for (script in FileSystem.readDirectory(Path.combine(['mods', mod, 'menu_scripts'])))
						if (!FileSystem.isDirectory(Path.combine(['mods', mod, 'menu_scripts', script])))
							if (haxe.io.Path.extension(Path.combine(['mods', mod, 'menu_scripts', script])) == 'lua'
								|| haxe.io.Path.extension(Path.combine(['mods', mod, 'menu_scripts', script])) == 'hx'
								&& !modData.staticMod)
								modData.staticMod = true;
				if ((mod == "Tutorial") // || mod == "Week 1" || mod == "Week 2" || mod == "Week 3" || mod == "Week 4" || mod == "Week 5" || mod == "Week 6" || mod == "Week 7"
					&& !Settings.data.savedMods.exists(mod))
				{
					modData.enabled = true;
					enabledMods.push(modData);
				}
				allMods.set(mod, modData);
				i++;
			}

		for (key in allMods.keys())
			if (Settings.data.savedMods.exists(key))
			{
				allMods[key].enabled = true;
				enabledMods.push(allMods[key]);
			}
	}

	public static function reloadEnabledMods():Void
	{
		@:privateAccess Path.modAssets.clear();
		@:privateAccess Path.modAssets = [];
		for (mod in allMods)
		{
			@:privateAccess Path.modAssets.set(mod, []);
			if (!mod.enabled)
				continue;
			for (folder in FileSystem.readDirectory(Path.combine(['mods', mod.path])))
				if (FileSystem.isDirectory(Path.combine(['mods', mod.path, folder])))
				{
					for (file in FileSystem.readDirectory(Path.combine(['mods', mod.path, folder])))
					{
						if (!FileSystem.isDirectory(Path.combine(['mods', mod.path, folder, file])))
						{
							switch (folder)
							{
								case "achievements":
								case "characters":
								case "charts":
								case "events":
								case "notetypes":
								case "fonts":
									@:privateAccess Path.addAsset(file, Path.combine(['mods', mod.path, folder, file]), mod);
								case "images":
									@:privateAccess Path.addAsset(file, Path.combine(['mods', mod.path, folder, file]), mod);
								case "menu_scripts":
								case "scripts":
								case "shaders":
									@:privateAccess Path.addAsset(file, Path.combine(['mods', mod.path, folder, file]), mod);
								case "sounds":
									@:privateAccess Path.addAsset(file, Path.combine(['mods', mod.path, folder, file]), mod);
								case "stages":
								case "videos":
									@:privateAccess Path.addAsset(file, Path.combine(['mods', mod.path, folder, file]), mod);
								case "weeks":
									var json:WeekJsonData = TJSON.parse(File.getContent(Path.combine(['mods', mod.path, folder, file])));
									mod.weeks.push(new Week(json.name ?? "N/A", json.menuChars ?? ["bf", "gf", "dad"], json.menuBG ?? "blank", json.locked ?? false, json.hideSongsFromFreeplay ?? false, []));
							}
						}
						else
						{
							if (folder == "songs")
								@:privateAccess Path.addAsset('song-' + file, Path.combine(['mods', mod.path, folder, file]), mod);
						}
					}
				}
		}
		/*for (mod in ModManager.allMods)
			{
				for (asset in FileSystem.readDirectory(combine(['mods', mod.path])))
					if (FileSystem.isDirectory(combine(['mods', mod.path, asset]))
						&& asset != "custom_events"
						&& asset != "custom_notetypes"
						&& asset != "menu_scripts"
						&& asset != "scripts"
						&& asset != "stages")
					{
						for (asset2 in FileSystem.readDirectory(combine(['mods', mod.path, asset])))
							if (!FileSystem.isDirectory(combine(['mods', mod.path, asset, asset2])))
								addAsset(asset2, combine(['mods', mod.path, asset, asset2]), mod);
							else
							{
								if (asset == "songs")
								{
									addAsset('song-$asset2', combine(['mods', mod.path, asset, asset2]), mod);
									continue;
								}
							}
					}
					else
						addAsset(asset, combine(['mods', mod.path, asset]));
		}*/
	}

	public static function reloadMods():Void
	{
		allMods.clear();
		enabledMods = [];
		loadMods();
	}
}
