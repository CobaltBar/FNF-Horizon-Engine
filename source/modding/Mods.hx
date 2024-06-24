package modding;

import backend.Path;
import flixel.util.FlxColor;
import haxe.ds.ArraySort;
import haxe.io.Path as HaxePath;
import modding.ModTypes;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;
import util.Dictionary.StringDictionary;
import util.Log;

class Mods
{
	public static var all:Map<String, Mod>;
	public static var enabled:Array<Mod>;

	/*
		To anyone trying to optimize this function:

		Good luck.
		-Cobalt
	 */
	public static function load():Void
	{
		all = [];
		enabled = [];

		var i = 0;
		var modsFolderContent = FileSystem.readDirectory('mods');
		ArraySort.sort(modsFolderContent, (a, b) -> (a < b ? -1 : (a > b ? 1 : 0)));
		for (modPath in modsFolderContent)
			if (FileSystem.isDirectory(Path.combine(['mods', modPath])))
			{
				if (modPath == 'Mod Template')
					continue;

				var jsonPath = Path.combine(['mods', modPath, 'mod.json']);
				var json:ModJson = FileSystem.exists(jsonPath) ? TJSON.parse(File.getContent(jsonPath)) : {
					name: 'Blank Mod',
					description: 'Blank Mod Description',
					version: '1.0.0',
					color: [255, 255, 255],
					global: false,
					modSysVer: Main.modSysVer
				};
				var iconPath = Path.combine(['mods', modPath, 'mod.png']);
				all.set(modPath, {
					name: json?.name ?? 'Blank Mod',
					description: json?.description ?? 'Blank Mod Description',
					version: json?.version ?? '1.0.0',
					color: json?.color != null ? FlxColor.fromRGB(json?.color[0] ?? 255, json?.color[1] ?? 255,
						json?.color[2] ?? 255) : FlxColor.fromRGB(255, 255, 255),
					global: json?.global ?? true,
					modSysVer: json?.modSysVer ?? Main.modSysVer,

					path: modPath,
					icon: FileSystem.exists(iconPath) ? iconPath : Path.find('unknownMod', ['png']).path,
					enabled: Settings.data.savedMods.get(modPath)?.enabled ?? true,
					staticMod: isStaticMod(modPath),
					songs: new StringDictionary(),
					weeks: new StringDictionary(),
					ID: Settings.data.savedMods.get(modPath)?.ID ?? i
				});

				all[modPath].songs = getSongs(modPath);
				all[modPath].weeks = getWeeks(modPath);

				if (all[modPath].enabled)
					enabled.push(all[modPath]);
				i++;
			}
		if (Main.verboseLogging)
			Log.info('Mods Loaded: ${[for (mod in all) mod.name].join(', ')}');
		Path.loadModAssets();
	}

	private static function isStaticMod(modPath:String):Bool
	{
		var menuScriptPath = Path.combine(['mods', modPath, 'menu_scripts']);
		if (FileSystem.exists(menuScriptPath))
			for (script in FileSystem.readDirectory(menuScriptPath))
			{
				var scriptPath = Path.combine([menuScriptPath, script]);
				if (!FileSystem.isDirectory(scriptPath)
					&& (HaxePath.extension(scriptPath) == 'hx' || HaxePath.extension(scriptPath) == 'lua'))
					return true;
			}
		return false;
	}

	private static function getWeeks(modPath:String):StringDictionary<Week>
	{
		var weeks:StringDictionary<Week> = new StringDictionary<Week>();
		var weeksPath = Path.combine(['mods', modPath, 'weeks']);
		if (FileSystem.exists(weeksPath))
			for (week in FileSystem.readDirectory(weeksPath))
			{
				var weekPath = Path.combine([weeksPath, week]);
				if (!FileSystem.isDirectory(weekPath) && HaxePath.extension(weekPath) == 'json')
				{
					var json:WeekJson = TJSON.parse(File.getContent(weekPath));
					var lowercaseSongs:Array<String> = [];
					if (json?.songs != null)
						for (song in json?.songs)
							lowercaseSongs.push(song.toLowerCase());
					weeks.set(week, {
						name: json?.name ?? 'Blank Week',
						menuChars: json?.menuChars ?? ['dad', 'bf', 'gf'],
						menuBG: json?.menuBG ?? 'blank',
						bgScale: json?.bgScale ?? 1,
						locked: json?.locked ?? false,
						unlocks: json?.unlocks ?? [],
						hideSongsFromFreeplay: json?.hideSongsFromFreeplay ?? false,
						songs: lowercaseSongs,

						difficulties: json?.difficulties ?? ["easy", "normal", "hard"],
						score: Settings.data.savedMods.get(modPath)?.weeks?.get(week)?.score ?? 0
					});
				}
			}
		return weeks;
	}

	private static function getSongs(modPath:String):StringDictionary<Song>
	{
		var songs:StringDictionary<Song> = new StringDictionary<Song>();
		var songsPath = Path.combine(['mods', modPath, 'songs']);
		if (FileSystem.exists(songsPath))
			for (song in FileSystem.readDirectory(songsPath))
			{
				var songPath = Path.combine([songsPath, song]);
				var jsonPath = Path.combine([songPath, 'song.json']);
				if (FileSystem.isDirectory(songPath) && FileSystem.exists(jsonPath))
				{
					var json:SongJson = TJSON.parse(File.getContent(jsonPath));
					songs.set(song.toLowerCase(), {
						name: json?.name ?? 'Blank Song',
						icon: json?.icon ?? 'bf',

						audioFiles: [],
						score: Settings.data.savedMods.get(modPath)?.songs?.get(song.toLowerCase())?.score ?? 0,
						accuracy: Settings.data.savedMods.get(modPath)?.songs?.get(song.toLowerCase())?.accuracy ?? 0,
						path: songPath
					});

					if (FileSystem.readDirectory(songPath).indexOf("Inst.ogg") != -1)
						songs[song.toLowerCase()].audioFiles.push(Path.combine([songPath, "Inst.ogg"]));
					if (FileSystem.readDirectory(songPath).indexOf("Voices-Player.ogg") != -1)
						songs[song.toLowerCase()].audioFiles.push(Path.combine([songPath, "Voices-Player.ogg"]));
					if (FileSystem.readDirectory(songPath).indexOf("Voices-Opponent.ogg") != -1)
						songs[song.toLowerCase()].audioFiles.push(Path.combine([songPath, "Voices-Opponent.ogg"]));
					if (FileSystem.readDirectory(songPath).indexOf("Voices.ogg") != -1)
						songs[song.toLowerCase()].audioFiles.push(Path.combine([songPath, "Voices.ogg"]));
				}
			}
		return songs;
	}
}
