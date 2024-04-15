package modding;

import modding.JsonTypedefs.ModJsonData;
import modding.JsonTypedefs.SongJsonData;
import modding.JsonTypedefs.WeekJsonData;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

/*
	TO ANYONE TRYING TO OPTIMIZE THIS
	GOOD FUCKING LUCK
	IDK HOW THIS WORKS AND I WROTE IT
 */
class ModManager
{
	public static var allMods:Map<String, Mod> = [];
	public static var enabledMods:Array<Mod> = [];

	private static function loadMods():Void
	{
		var i:Int = 0;
		if (FileSystem.exists('mods') && FileSystem.isDirectory('mods'))
			for (modDir in FileSystem.readDirectory('mods'))
				if (FileSystem.isDirectory(Path.combine(['mods', modDir])))
				{
					if (modDir == "Mod Template")
						continue;

					var json:ModJsonData = FileSystem.exists(Path.combine(['mods', modDir, 'mod.json'])) ? TJSON.parse(File.getContent(Path.combine(['mods', modDir, 'mod.json']))) : null;

					var savedMod:Mod = Settings.data.savedMods.exists(json.name ?? modDir) ? Settings.data.savedMods.get(json.name ?? modDir) : null;
					var mod:Mod = {
						name: json.name ?? modDir,
						description: json.description ?? "N/A",
						version: json.version ?? "1.0",
						color: json.color ?? [255, 255, 255],
						globalMod: json.globalMod ?? true,
						modSysVer: json.modSysVer ?? InitState.modSysVer,
						path: modDir,
						icon: FileSystem.exists(Path.combine(['mods', modDir, 'mod.png'])) ? Path.combine(['mods', modDir, 'mod.png']) : Path.find('unknownMod',
							'png'),
						enabled: savedMod == null ? true : savedMod.enabled,
						staticMod: checkModStatic(Path.combine(['mods', modDir, 'menu_scripts'])),
						weeks: getModWeeks(Path.combine(['mods', modDir, 'weeks']), savedMod, json.name ?? modDir),
						songs: getModSongs(Path.combine(['mods', modDir, 'songs']), savedMod, json.name ?? modDir),
						ID: savedMod == null ? i : savedMod.ID
					}
					for (key => value in mod.weeks)
						for (song in value.songs)
							if (mod.songs.exists(song))
								for (difficulty in mod.songs.get(song).difficulties)
									if (!mod.weeks[key].difficulties.contains(difficulty))
										mod.weeks[key].difficulties.push(difficulty);
					allMods.set(modDir, mod);
					if (mod.enabled)
						enabledMods.insert(mod.ID, mod);
					i++;
				}
		haxe.ds.ArraySort.sort(ModManager.enabledMods, (a, b) ->
		{
			return a.ID < b.ID ? -1 : a.ID > b.ID ? 1 : 0;
		});
	}

	public static function reloadMods():Void
	{
		allMods.clear();
		enabledMods = [];
		loadMods();
		Path.reloadModAssets();
	}

	private static function checkModStatic(dir:String):Bool
	{
		if (FileSystem.exists(dir) && FileSystem.isDirectory(dir))
			for (file in FileSystem.readDirectory(dir))
				if (!FileSystem.isDirectory(Path.combine([dir, file]))
					&& InitState.extensions.get("script").contains(haxe.io.Path.extension(Path.combine([dir, file]))))
					return true;
		return false;
	}

	private static function getModWeeks(dir:String, savedMod:Mod, modName:String):Map<String, Week>
	{
		var weeks:Map<String, Week> = [];
		if (FileSystem.exists(dir) && FileSystem.isDirectory(dir))
			for (week in FileSystem.readDirectory(dir))
				if (!FileSystem.isDirectory(Path.combine([dir, week])) && haxe.io.Path.extension(Path.combine([dir, week])) == "json")
				{
					var json:WeekJsonData = TJSON.parse(File.getContent(Path.combine([dir, week])));
					weeks.set(week.toLowerCase(), {
						name: json.name ?? "Week",
						menuChars: json.menuChars ?? ["dad", "bf", "gf"],
						menuBG: json.menuBG ?? "blank",
						locked: json.locked ?? false,
						hideSongsFromFreeplay: json.hideSongsFromFreeplay ?? false,
						songs: json.songs ?? ["Test"],
						modName: modName,
						score: savedMod == null ? 0 : savedMod.weeks.get(week.toLowerCase()).score
					});
				}
		return weeks;
	}

	private static function getModSongs(dir:String, savedMod:Mod, modName:String):Map<String, Song>
	{
		var songs:Map<String, Song> = [];
		if (FileSystem.exists(dir) && FileSystem.isDirectory(dir))
			for (songDir in FileSystem.readDirectory(dir))
				if (FileSystem.isDirectory(Path.combine([dir, songDir])))
				{
					if (!FileSystem.exists(Path.combine([dir, songDir, 'song.json'])))
						continue;
					var difficulties:Array<String> = [];
					for (song in FileSystem.readDirectory(Path.combine([dir, songDir])))
						if (!FileSystem.isDirectory(Path.combine([dir, songDir, song]))
							&& haxe.io.Path.extension(Path.combine([dir, songDir, song])) == "json")
							if (song.startsWith('$songDir-'))
								difficulties.push(song);

					var json:SongJsonData = TJSON.parse(File.getContent(Path.combine([dir, songDir, 'song.json'])));

					var audioFiles:Array<String> = [];
					if (FileSystem.exists(Path.combine([dir, songDir, 'Inst.ogg'])))
						audioFiles.push(Path.combine([dir, songDir, 'Inst.ogg']));
					if (FileSystem.exists(Path.combine([dir, songDir, 'Voices_Player.ogg']))
						&& FileSystem.exists(Path.combine([dir, songDir, 'Voices_Opponent.ogg'])))
					{
						audioFiles.push(Path.combine([dir, songDir, 'Voices_Player.ogg']));
						audioFiles.push(Path.combine([dir, songDir, 'Voices_Opponent.ogg']));
					}
					else if (FileSystem.exists(Path.combine([dir, songDir, 'Voices.ogg'])))
						audioFiles.push(Path.combine([dir, songDir, 'Voices.ogg']));

					songs.set(songDir.toLowerCase(), {
						name: json.name ?? songDir.toLowerCase(),
						difficulties: difficulties,
						icon: json.icon ?? "bf",
						audioFiles: audioFiles,
						modName: modName,
						score: savedMod == null ? 0 : savedMod.songs.get(songDir.toLowerCase()).score,
						accuracy: savedMod == null ? 0 : savedMod.songs.get(songDir.toLowerCase()).accuracy
					});
				}
		return songs;
	}
}
