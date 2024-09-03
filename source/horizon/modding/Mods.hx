package horizon.modding;

class Mods
{
	public static var all:Array<String> = [];

	public static var enabled:Array<Mod> = [];
	public static var assets:Mod;

	public static function load():Void
	{
		if (FileSystem.exists('mods'))
		{
			var folders = FileSystem.readDirectory('mods');
			ArraySort.sort(folders, (a, b) -> (a > b ? 1 : a < b ? -1 : 0));

			var defaultJSON:ModJSON = {
				name: "Untitled Mod",
				description: "Untitled Mod with No Description",
				version: "1.0.0",
				color: [255, 255, 255],
				global: false,
				modSysVer: Main.modSysVer
			};

			for (i in 0...folders.length)
			{
				var modPath = Path.combine(['mods', folders[i]]);
				if (FileSystem.isDirectory(modPath))
				{
					all.push(folders[i]);

					if (!Settings.savedMods.exists(folders[i]))
						continue;

					var jsonPath = Path.combine([modPath, 'mod.json']);
					var json:ModJSON = FileSystem.exists(jsonPath) ? TJSON.parse(File.getContent(jsonPath)) : defaultJSON;

					var mod:Mod = {
						name: json.name ?? defaultJSON.name,
						description: json.description ?? defaultJSON.description,
						version: json.version ?? defaultJSON.version,
						color: json.color ?? defaultJSON.color,
						global: json.global ?? false,
						modSysVer: json.modSysVer ?? Main.modSysVer,
						ID: Settings.savedMods[folders[i]]?.ID ?? i,

						characters: parseCharacters(modPath),
						songs: parseSongs(modPath),
						stages: parseStages(modPath),
						weeks: parseWeeks(modPath),

						path: modPath
					};
					enabled.push(mod);
				}
			}

			ArraySort.sort(enabled, (a, b) -> (a.ID > b.ID ? 1 : a.ID < b.ID ? -1 : 0));
		}
		else
			Log.warn('Mods folder does not exist. Skipping mod loading');

		assets = {
			name: "Assets",
			description: "Internal Assets of Horizon Engine",
			version: Main.horizonVer,
			color: [65, 50, 255],
			global: true,
			modSysVer: Main.modSysVer,
			ID: enabled.length,

			characters: parseCharacters('assets'),
			songs: parseSongs('assets'),
			stages: parseStages('assets'),
			weeks: parseWeeks('assets'),

			path: 'assets'
		};
	}

	static function parseCharacters(folder:String):Array<CharacterData>
	{
		var chars:Array<CharacterData> = [];
		var charDir = Path.combine([folder, 'characters']);

		if (!FileSystem.exists(charDir))
			return chars;

		for (char in FileSystem.readDirectory(charDir))
		{
			var charPath = Path.combine([charDir, char]);
			if (!FileSystem.isDirectory(charPath) && HaxePath.extension(char) == 'json')
			{
				var json:CharacterData = TJSON.parse(File.getContent(charPath));

				chars.push({
					position: json.position ?? [0, 0],
					animData: json.animData ?? [],
					scale: json.scale ?? 1,
					antialiasing: json.antialiasing ?? Settings.antialiasing,
					flipX: json.flipX ?? false,

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
		var songDir = Path.combine([folder, 'songs']);

		if (!FileSystem.exists(songDir))
			return songs;

		for (song in FileSystem.readDirectory(songDir))
		{
			var songPath = Path.combine([songDir, song]);
			if (FileSystem.isDirectory(songPath))
			{
				var jsonPath = Path.combine([songPath, 'song.json']);

				var json:SongJSON = FileSystem.exists(jsonPath) ? TJSON.parse(File.getContent(jsonPath)) : null;

				var audios:Array<String> = [];
				for (file in FileSystem.readDirectory(songPath))
				{
					var filePath = Path.combine([songPath, file]);
					if (!FileSystem.isDirectory(filePath))
						if (HaxePath.extension(filePath) == 'ogg')
						{
							file = HaxePath.withoutExtension(file.trim().toLowerCase());
							if ((file == 'voices' || file == 'voices-player' || file == 'voices-opponent') && audios.indexOf(file) == -1)
								audios.push(file);
						}
				}

				songs.push({
					name: json?.name ?? song,
					icon: json?.icon ?? 'blank',
					hide: json?.hide ?? false,
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
		var stageDir = Path.combine([folder, 'stages']);

		if (!FileSystem.exists(stageDir))
			return stages;

		for (stage in FileSystem.readDirectory(stageDir))
		{
			var stagePath = Path.combine([stageDir, stage]);
			if (!FileSystem.isDirectory(stagePath) && HaxePath.extension(stage) == 'json')
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
		var weekDir = Path.combine([folder, 'weeks']);

		if (!FileSystem.exists(weekDir))
			return weeks;

		for (week in FileSystem.readDirectory(weekDir))
		{
			var weekPath = Path.combine([weekDir, week]);
			if (!FileSystem.isDirectory(weekPath) && HaxePath.extension(week) == 'json')
			{
				var json:WeekJSON = TJSON.parse(File.getContent(weekPath));

				weeks.push({
					name: json.name ?? week,
					menuChars: json.menuChars ?? ['bf'],
					bg: json.bg,
					bgScale: json.bgScale,
					locked: false ?? Settings.savedMods[folder.split('/')[1]].weeks[week]?.locked,
					unlocks: json.unlocks ?? [],
					songs: json.songs ?? ['test'],
					difficulties: json.difficulties ?? ['normal'],

					score: Settings.savedMods[folder.split('/')[1]]?.weeks[week]?.score ?? 0,
					accuracy: Settings.savedMods[folder.split('/')[1]]?.weeks[week]?.accuracy ?? 0
				});
			}
		}

		return weeks;
	}
}

typedef MenuCharacterData =
{
	var position:Array<Float>;
	var animData:Array<AnimationData>;
	var scale:Float;
	var antialiasing:Bool;
	var flipX:Bool;
}

typedef CharacterData = MenuCharacterData &
{
	var icon:String;
	var color:Array<Int>;
	var cameraPos:Array<Int>;
	var singDuration:Int;
}

typedef StageData =
{
	var defaultZoom:Float;
	var playerPos:Array<Float>;
	var gfPos:Array<Float>;
	var opponentPos:Array<Float>;
	var hideGF:Bool;
	var playerCam:Array<Float>;
	var gfCam:Array<Float>;
	var opponentCam:Array<Float>;
	var camSpeed:Float;

	var objs:Array<StageSprite>;
}

typedef StageSprite = MenuCharacterData &
{
	var imageName:String;
}

typedef AnimationData =
{
	var prefix:String;
	var indices:Array<Int>;
	var fps:Float;
	var offsets:Array<Array<Int>>;
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
