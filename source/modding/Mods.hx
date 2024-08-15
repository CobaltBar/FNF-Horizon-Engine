package modding;

import haxe.ds.ArraySort;
import haxe.io.Path as HaxePath;
import sys.FileSystem;
import sys.io.File;
import util.Dictionary.StringDictionary;

class Mods
{
	public static var all:Map<String, Mod>;
	public static var enabled:Array<Mod>;

	public static function load():Void
	{
		all = [];
		enabled = [];

		if (FileSystem.exists('mods'))
		{
			var mods = FileSystem.readDirectory('mods');
			ArraySort.sort(mods, (a, b) -> (a < b ? -1 : (a > b ? 1 : 0)));
			for (i in 0...mods.length)
				if (FileSystem.isDirectory(Path.combine(['mods', mods[i]])))
				{
					if (mods[i] == 'Mod Template')
						continue;

					var json:ModJSON = TJSON.parse(File.getContent(Path.combine(['mods', mods[i], 'mod.json'])) ?? '');

					var modPath = Path.combine(['mods', mods[i]]);
					var iconPath = Path.combine([modPath, 'mod.png']);
					all.set(mods[i], {
						name: json.name ?? 'Blank Mod',
						description: json.description ?? 'This mod does not have a description in mod.json',
						version: json.version ?? '1.0.0',
						color: FlxColor.fromRGB(json.color[0] ?? 255, json.color[1] ?? 255, json.color[2] ?? 255),
						global: json.global ?? true,
						modSysVer: json.modSysVer ?? Main.modSysVer,

						folderName: mods[i],
						iconPath: FileSystem.exists(iconPath) ? iconPath : Path.combine(['assets', 'images', 'unknownMod.png']),
						enabled: Settings.data.savedMods.get(mods[i])?.enabled ?? true,
						staticMod: isStatic(modPath),
						songs: getSongs(modPath),
						weeks: getWeeks(modPath),
						ID: Settings.data.savedMods.get(mods[i])?.ID ?? i
					});

					if (all[mods[i]].enabled)
						enabled.push(all[mods[i]]);
				}
		}

		all.set('assets', {
			name: 'Assets',
			description: 'Internal Horizon Engine Assets',
			version: '${Main.horizonVer}',
			color: 0xFF2565FF,
			global: true,
			modSysVer: Main.modSysVer,
			folderName: 'assets',
			iconPath: Path.combine(['assets', 'images', 'unknownMod.png']),
			enabled: true,
			staticMod: false,
			songs: getSongs('assets'),
			weeks: getWeeks('assets'),
			ID: enabled.length
		});
	}

	private static function isStatic(path:String):Bool
	{
		var scriptsPath = Path.combine([path, 'menuScripts']);
		if (FileSystem.exists(scriptsPath))
			for (script in FileSystem.readDirectory(scriptsPath))
			{
				var scriptPath = Path.combine([scriptsPath, script]);
				if (!FileSystem.isDirectory(scriptPath)
					&& (HaxePath.extension(scriptPath) == 'hx' || HaxePath.extension(scriptPath) == 'lua'))
					return true;
			}
		return false;
	}

	private static function getWeeks(path:String):StringDictionary<Week>
	{
		var weeks:StringDictionary<Week> = new StringDictionary<Week>();
		var weeksPath = Path.combine([path, 'weeks']);
		if (FileSystem.exists(weeksPath))
			for (week in FileSystem.readDirectory(weeksPath))
			{
				var weekPath = Path.combine([weeksPath, week]);
				if (!FileSystem.isDirectory(weekPath) && HaxePath.extension(weekPath) == 'json')
				{
					var json:WeekJSON = TJSON.parse(File.getContent(weekPath));
					var lowercaseSongs:Array<String> = [];
					if (json?.songs != null)
						for (song in json.songs)
							lowercaseSongs.push(song.toLowerCase());
					weeks.set(week, {
						name: json.name ?? 'Blank Week',
						chars: json.chars ?? ['dad', 'bf', 'gf'],
						bg: json.bg ?? 'blank',
						bgScale: json.bgScale ?? 1,
						locked: json.locked ?? false,
						unlocks: json.unlocks ?? [],
						songs: lowercaseSongs,

						difficulties: json.difficulties ?? ["easy", "normal", "hard"],
						score: Settings.data.savedMods.get(path)?.weeks?.get(week)?.score ?? 0
					});
				}
			}
		return weeks;
	}

	private static function getSongs(path:String):StringDictionary<Song>
	{
		var songs:StringDictionary<Song> = new StringDictionary<Song>();
		var songsPath = Path.combine([path, 'songs']);
		if (FileSystem.exists(songsPath))
			for (song in FileSystem.readDirectory(songsPath))
			{
				var songPath = Path.combine([songsPath, song]);
				var jsonPath = Path.combine([songPath, 'song.json']);
				if (FileSystem.isDirectory(songPath) && FileSystem.exists(jsonPath))
				{
					var json:SongJSON = TJSON.parse(File.getContent(jsonPath));
					songs.set(song.toLowerCase(), {
						name: json.name ?? 'Blank Song',
						icon: json.icon ?? 'bf',
						hide: json.hide ?? false,

						audioFiles: [],
						score: Settings.data.savedMods.get(path)?.songs?.get(song.toLowerCase())?.score ?? 0,
						accuracy: Settings.data.savedMods.get(path)?.songs?.get(song.toLowerCase())?.accuracy ?? 0,
						folderName: song
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
