package horizon.modding;

import haxe.ds.ArraySort;

class Mods
{
	public static var all:Array<String> = [];

	public static var enabled:Array<Mod> = [];
	public static var assets:Mod;

	static final defaultJSON:ModJSON = {
		name: 'Untitled Mod',
		description: 'An Untitled Mod',
		version: '1.0.0',
		color: [255, 255, 255],
		global: false,
		modSysVer: Constants.modSysVer
	};

	public static function load():Void
	{
		all = [];
		enabled = [];
		assets = null;

		if (FileSystem.exists('mods'))
		{
			var folders = FileSystem.readDirectory('mods');
			ArraySort.sort(folders, (a, b) -> (a > b ? 1 : a < b ? -1 : 0));

			for (i in 0...folders.length)
			{
				var modPath = PathUtil.combine('mods', folders[i]);
				if (FileSystem.isDirectory(modPath))
				{
					all.push(folders[i]);

					if (Settings.savedMods.exists(folders[i]))
						if (!Settings.savedMods[folders[i]].enabled)
							continue;

					enabled.push(parseMod(modPath, folders[i], i));
				}
			}

			ArraySort.sort(enabled, (a, b) -> (a.ID > b.ID ? 1 : a.ID < b.ID ? -1 : 0));
		}
		else
			Log.warn('Mods folder does not exist. Skipping mod loading');

		assets = {
			name: 'Assets',
			description: 'Internal Assets of Horizon Engine',
			version: Constants.horizonVer,
			color: FlxColor.fromRGB(65, 50, 255),
			global: true,
			modSysVer: Constants.modSysVer,
			ID: enabled.length,

			characters: parseCharacters('assets'),
			songs: parseSongs('assets'),
			stages: parseStages('assets'),
			weeks: parseWeeks('assets'),

			path: 'assets',
			folder: 'assets',
			iconPath: 'assets/images/unknownMod.png'
		};

		@:privateAccess Path.modSearch = enabled.concat([assets]);
	}

	public static function parseMod(path:String, folder:String, ID:Int):Mod
	{
		var jsonPath = PathUtil.combine(path, 'mod.json');
		var json:ModJSON = FileSystem.exists(jsonPath) ? TJSON.parse(File.getContent(jsonPath)) : defaultJSON;

		var iconPath = PathUtil.combine(path, 'mod.png');
		var icon = FileSystem.exists(iconPath) ? iconPath : 'assets/images/unknownMod.png';

		var color:FlxColor = json.color != null ? FlxColor.fromRGB(json.color[0] ?? 255, json.color[1] ?? 255,
			json.color[2] ?? 255) : FlxColor.fromRGB(defaultJSON.color[0] ?? 255, defaultJSON.color[1] ?? 255, defaultJSON.color[2] ?? 255);

		return {
			name: (json.name ?? defaultJSON.name).trim(),
			description: (json.description ?? defaultJSON.description).trim(),
			version: (json.version ?? defaultJSON.version).trim(),
			color: color,
			global: json.global ?? false,
			modSysVer: json.modSysVer ?? Constants.modSysVer,
			ID: Settings.savedMods[folder]?.ID ?? ID,

			characters: parseCharacters(path),
			songs: parseSongs(path),
			stages: parseStages(path),
			weeks: parseWeeks(path),

			path: path,
			folder: folder,
			iconPath: icon
		};
	}

	static function parseCharacters(folder:String):Array<CharacterData>
	{
		var chars:Array<CharacterData> = [];
		var charDir = PathUtil.combine(folder, 'characters');

		if (!FileSystem.exists(charDir))
			return chars;

		for (char in FileSystem.readDirectory(charDir))
		{
			var charPath = PathUtil.combine(charDir, char);
			if (!FileSystem.isDirectory(charPath) && PathUtil.extension(char) == 'json')
			{
				var json:CharacterData = TJSON.parse(File.getContent(charPath));

				chars.push({
					position: json.position ?? [0, 0],
					animData: json.animData ?? [],
					scale: json.scale ?? 1,
					antialiasing: json.antialiasing ?? Settings.antialiasing,
					flipX: json.flipX ?? false,
					multi: json.multi ?? [],

					icon: json.icon ?? 'blank',
					color: json.color ?? [255, 0, 0],
					cameraPos: json.cameraPos ?? [0, 0],
					singDuration: json.singDuration ?? 4
				});
			}
		}

		return chars;
	}

	static function parseSongs(folder:String):Array<Song>
	{
		var songs:Array<Song> = [];
		var songDir = PathUtil.combine(folder, 'songs');

		if (!FileSystem.exists(songDir))
			return songs;

		for (song in FileSystem.readDirectory(songDir))
		{
			var songPath = PathUtil.combine(songDir, song);
			if (FileSystem.isDirectory(songPath))
			{
				var jsonPath = PathUtil.combine(songPath, 'song.json');

				var json:SongJSON = FileSystem.exists(jsonPath) ? TJSON.parse(File.getContent(jsonPath)) : null;

				var audios:Array<String> = [];
				for (file in FileSystem.readDirectory(songPath))
				{
					var filePath = PathUtil.combine(songPath, file);
					if (!FileSystem.isDirectory(filePath))
						if (PathUtil.extension(filePath) == 'ogg')
						{
							file = PathUtil.withoutExtension(file.trim().toLowerCase());
							if (file == 'voices' || file == 'voices-player' || file == 'voices-opponent' || file == 'inst')
								audios.push(filePath);
						}
				}

				songs.push({
					name: json?.name ?? song,
					icon: json?.icon ?? 'blank',
					hide: json?.hide ?? false,
					folder: song,
					audios: audios,

					score: Settings.savedMods[folder.split('/')[1]]?.songs[song]?.score ?? 0,
					accuracy: Settings.savedMods[folder.split('/')[1]]?.songs[song]?.accuracy ?? 0
				});
			}
		}

		return songs;
	}

	static function parseStages(folder:String):Array<StageData>
	{
		var stages:Array<StageData> = [];
		var stageDir = PathUtil.combine(folder, 'stages');

		if (!FileSystem.exists(stageDir))
			return stages;

		for (stage in FileSystem.readDirectory(stageDir))
		{
			var stagePath = PathUtil.combine(stageDir, stage);
			if (!FileSystem.isDirectory(stagePath) && PathUtil.extension(stage) == 'json')
			{
				var json:StageData = TJSON.parse(File.getContent(stagePath));

				stages.push({
					defaultZoom: json.defaultZoom ?? 1,
					playerPos: json.playerPos ?? [400, 0],
					gfPos: json.gfPos ?? [0, 0],
					opponentPos: json.opponentPos ?? [-400, 0],
					hideGF: json.hideGF ?? false,
					playerCam: json.playerCam ?? [350, -50],
					gfCam: json.gfCam ?? [0, -100],
					opponentCam: json.opponentPos,
					camSpeed: json.camSpeed ?? 1,
					objs: json.objs ?? []
				});
			}
		}

		return stages;
	}

	static function parseWeeks(folder:String):Array<Week>
	{
		var weeks:Array<Week> = [];
		var weekDir = PathUtil.combine(folder, 'weeks');

		if (!FileSystem.exists(weekDir))
			return weeks;

		for (week in FileSystem.readDirectory(weekDir))
		{
			var weekPath = PathUtil.combine(weekDir, week);
			if (!FileSystem.isDirectory(weekPath) && PathUtil.extension(week) == 'json')
			{
				var json:WeekJSON = TJSON.parse(File.getContent(weekPath));

				weeks.push({
					name: json.name ?? week,
					menuChars: json.menuChars ?? ['bf'],
					bg: json.bg ?? 'blank',
					bgScale: json.bgScale ?? 1,
					locked: false ?? Settings.savedMods[folder.split('/')[1]].weeks[week]?.locked,
					unlocks: json.unlocks ?? [],
					songs: json.songs ?? ['test'],
					folder: PathUtil.withoutExtension(week),
					difficulties: json.difficulties ?? ['normal'],

					score: Settings.savedMods[folder.split('/')[1]]?.weeks[week]?.score ?? 0,
					accuracy: Settings.savedMods[folder.split('/')[1]]?.weeks[week]?.accuracy ?? 0
				});
			}
		}

		return weeks;
	}
}

typedef GenericAnimatedSprite =
{
	var animData:Array<AnimationData>;
	var scale:Null<Float>;
	var antialiasing:Null<Bool>;
	var flipX:Null<Bool>;
	var multi:Array<String>;
}

typedef AnimatedChracterData = GenericAnimatedSprite &
{
	var position:Array<Float>;
}

typedef CharacterData = AnimatedChracterData &
{
	var icon:Null<String>;
	var color:Array<Int>;
	var cameraPos:Array<Int>;
	var singDuration:Null<Int>;
}

typedef StageData =
{
	var defaultZoom:Null<Float>;
	var playerPos:Array<Float>;
	var gfPos:Array<Float>;
	var opponentPos:Array<Float>;
	var hideGF:Null<Bool>;
	var playerCam:Array<Float>;
	var gfCam:Array<Float>;
	var opponentCam:Array<Float>;
	var camSpeed:Null<Float>;

	var objs:Array<StageSprite>;
}

typedef StageSprite = AnimatedChracterData &
{
	var imageName:Null<String>;
}

typedef AnimationData =
{
	var name:Null<String>;
	var prefix:Null<String>;
	var indices:Array<Int>;
	var fps:Null<Float>;
	var offsets:Array<Float>;
	var looped:Null<Bool>;
}

// JSONs
/*
	Horizon Engine Mod

	Mod Folder Structure:
		Awards				Modded Awards (png, json) 
		Characters			Modded Characters (png, json, xml, lua)
		Events				Modded Events (lua, optional png)
		Images				Images (Stages, extras)
		Notes				Notes (png, xml, lua)
		Scripts				All Scripts (`menu_STATE` for menu scripts)
		Songs				Modded Songs (ogg, json, lua)
		Stages				Modded Stages (json, lua)
		Weeks				Modded Weeks (json)
		mod.json			Contains metadata for the mod (Name, Description, BG Color, Version, Global, Mod System Version)
		mod.png         	(Optional) Mod Icon

	Character Metadata:
		Animations			Animation Info (Prefix, indices, fps, offsets)
		Icon
		Healthbar Color
		Camera Position		Camera Position relative to the character
		Flip X
		Scale
		Antialiasing
		Position
		Sing Duration		How long the character sings in steps

	Song Metadata:
		Name				Song Name
		Icon				The character icon to use in freeplay
		Hide				Hide the song in freeplay
		Score				Score for this song (Saved Data)
		Accuracy			Accuracy for this song (Saved Data)

	Week Metadata:
		Name				Week Name
		Menu Characters		Story Menu Boppers
		BG					Background in the Story Menu
		BG Scale
		Locked				(Saved Data)
		Unlocks				What Weeks beating this week unlocks
		Songs
		Difficulties		(`normal` by default)
		Score				(Saved Data)
		Accuracy			Average Accuracy (Saved Data)

	Chart Format:
		Notes				Notes (0-3 for player, 4-7 for opponent)
		Events
		Scroll Speed
		BPM
		Characters

		Event Metadata:
		Name
		Time
		Values

	Menu Character Metadata:
		Animations			Animation Info (Prefix, indices, fps, offsets)
		Position
		Scale
 */
