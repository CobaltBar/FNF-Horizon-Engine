package modding;

import backend.Path;
import flixel.util.FlxColor;
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
		for (modPath in FileSystem.readDirectory('mods'))
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
					name: json.name ?? 'Blank Mod',
					description: json.description ?? 'Blank Mod Description',
					version: json.version ?? '1.0.0',
					color: json.color != null ? FlxColor.fromRGB(json.color[0] ?? 255, json.color[1] ?? 255,
						json.color[2] ?? 255) : FlxColor.fromRGB(255, 255, 255),
					global: json.global ?? true,
					modSysVer: json.modSysVer ?? Main.modSysVer,

					path: modPath,
					icon: FileSystem.exists(iconPath) ? iconPath : Path.find('unknownMod', ['png']),
					enabled: Settings.data.savedMods.get(modPath)?.enabled ?? false,
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
			Log.info('Mods Loaded: $i');
		Path.loadModAssets();
	}

	private static function isStaticMod(modPath:String):Bool
	{
		var menuScriptPath = Path.combine(['mods', modPath, 'menu_scripts']);
		if (FileSystem.exists(menuScriptPath))
			for (script in FileSystem.readDirectory(menuScriptPath))
			{
				var scriptPath = Path.combine(['mods', modPath, 'menu_scripts', script]);
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
				var weekPath = Path.combine(['mods', modPath, 'weeks', week]);
				if (!FileSystem.isDirectory(weekPath) && HaxePath.extension(weekPath) == 'json')
				{
					var json:WeekJson = TJSON.parse(File.getContent(weekPath));
					weeks.set(week, {
						name: json.name ?? 'Blank Week',
						menuChars: json.menuChars ?? ['dad', 'bf', 'gf'],
						menuBG: json.menuBG ?? 'blank',
						locked: json.locked ?? false,
						unlocks: json.unlocks ?? [],
						hideSongsFromFreeplay: json.hideSongsFromFreeplay ?? false,
						songs: json.songs ?? [],

						modName: modPath,
						difficulties: [],
						score: Settings.data.savedMods.get(modPath)?.weeks?.get(week)?.score ?? 0
					});

					for (song in weeks[week].songs)
						if (all[modPath].songs.exists(song))
							for (diff in all[modPath].songs.get(song).difficulties)
								if (!weeks[week].difficulties.contains(diff))
									weeks[week].difficulties.push(diff);
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
				var songPath = Path.combine(['mods', modPath, 'songs', song]);
				var jsonPath = Path.combine([songPath, 'song.json']);
				if (FileSystem.isDirectory(songPath) && FileSystem.exists(jsonPath))
				{
					var json:SongJson = TJSON.parse(File.getContent(jsonPath));
					songs.set(songPath, {
						name: json.name ?? 'Blank Song',
						icon: json.icon ?? 'bf',

						difficulties: [],
						audioFiles: [],
						score: Settings.data.savedMods.get(modPath)?.songs?.get(songPath)?.score ?? 0,
						accuracy: Settings.data.savedMods.get(modPath)?.songs?.get(songPath)?.accuracy ?? 0
					});

					for (file in FileSystem.readDirectory(songPath))
					{
						var filePath = Path.combine([songPath, file]);
						if (!FileSystem.isDirectory(filePath))
						{
							if (HaxePath.extension(filePath) == 'json'
								&& file != 'song.json'
								&& !songs[songPath].difficulties.contains(HaxePath.withoutExtension(file)))
								songs[songPath].difficulties.push(HaxePath.withoutExtension(file));

							if (HaxePath.extension(filePath) == 'ogg')
							{
								if (file == 'Inst.ogg' || file == 'Voices.ogg')
									songs[songPath].audioFiles.push(filePath);
								if (!songs[songPath].audioFiles.contains('Voices.ogg')
									&& (file == 'Voices-Player.ogg' || file == 'Voices-Opponent.ogg'))
									songs[songPath].audioFiles.push(filePath);
							}
						}
					}
				}
			}
		return songs;
	}
}
