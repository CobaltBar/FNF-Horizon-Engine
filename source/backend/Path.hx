package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.sound.FlxSound;
import haxe.io.Path as HaxePath;
import modding.ModManager;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class Path
{
	static var assets:Map<String, String> = [];

	public static function loadAssets():Void
	{
		for (asset in FileSystem.readDirectory("assets"))
			if (FileSystem.isDirectory(combine(["assets", asset])))
				for (asset2 in FileSystem.readDirectory(combine(["assets", asset])))
				{
					if (FileSystem.isDirectory(combine(["assets", asset, asset2])))
					{
						if (asset2 == "songs")
							continue;
						for (asset3 in FileSystem.readDirectory(combine(["assets", asset, asset2])))
							if (FileSystem.isDirectory(combine(["assets", asset, asset2, asset3])))
							{
								for (asset4 in FileSystem.readDirectory(combine(["assets", asset, asset2, asset3])))
								{
									if (!FileSystem.isDirectory(combine(["assets", asset, asset2, asset3, asset4])))
										assets.set(asset4, combine(["assets", asset, asset2, asset3, asset4]));
								}
							}
							else
								assets.set(asset3, combine(["assets", asset, asset2, asset3]));
					}
					else
						assets.set(asset2, combine(["assets", asset, asset2]));
				}
			else
				assets.set(asset, combine(["assets", asset]));
	}

	public static function reloadEnabledMods():Void
		for (mod in ModManager.enabledMods)
			for (folder in FileSystem.readDirectory(mod.path))
				if (FileSystem.isDirectory(combine([mod.path, folder])))
					if (folder == "images" || folder == "characters" || folder == "charts" || folder == "sounds" || folder == "videos")
						for (file in FileSystem.readDirectory(combine([mod.path, folder])))
							if (FileSystem.isDirectory(combine([mod.path, folder, file])))
							{
								for (asset in FileSystem.readDirectory(combine([mod.path, folder, file])))
									if (!FileSystem.isDirectory(combine([mod.path, folder, file, asset])))
										assets.set(asset, combine([mod.path, folder, file, asset]));
							}
							else
								assets.set(file, combine([mod.path, folder, file]));

	public static inline function image(name:String):String
	{
		if (!assets.exists(HaxePath.withExtension(name, "png")))
			MusicState.errorText += 'Image ${HaxePath.withExtension(name, "png")} not found.\n';
		return assets.get(HaxePath.withExtension(name, "png"));
	}

	public static inline function sound(name:String):String
	{
		if (assets.exists(HaxePath.withExtension(name, "ogg")))
			return assets.get(HaxePath.withExtension(name, "ogg"));
		else if (assets.exists(HaxePath.withExtension(name, "mp3")))
			return assets.get(HaxePath.withExtension(name, "mp3"));
		else
		{
			MusicState.errorText += 'Sound $name not found.\n';
			return null;
		}
	}

	public static inline function json(name:String):Dynamic
	{
		if (!assets.exists(HaxePath.withExtension(name, "json")))
			MusicState.errorText += 'Image ${HaxePath.withExtension(name, "json")} not found.\n';
		return TJSON.parse(File.getContent(assets.get(HaxePath.withExtension(name, "json"))));
	}

	public static inline function sparrow(name:String):FlxAtlasFrames
	{
		var png:String = "";
		var xml:String = "";

		if (assets.exists(HaxePath.withExtension(name, "png")))
			png = assets.get(HaxePath.withExtension(name, "png"));
		else
			MusicState.errorText += 'Sparrow $name not found (PNG)';
		if (assets.exists(HaxePath.withExtension(name, "xml")))
			xml = assets.get(HaxePath.withExtension(name, "xml"));
		else
			MusicState.errorText += 'Sparrow $name not found (XML)';

		return FlxAtlasFrames.fromSparrow(png, xml);
	}

	public static inline function font(name:String):String
	{
		if (assets.exists(HaxePath.withExtension(name, "ttf")))
			return assets.get(HaxePath.withExtension(name, "ttf"));
		else if (assets.exists(HaxePath.withExtension(name, "otf")))
			return assets.get(HaxePath.withExtension(name, "otf"));
		else
		{
			MusicState.errorText += 'Font $name not found.\n';
			return null;
		}
	}

	public static inline function txt(name:String):String
	{
		if (!assets.exists(HaxePath.withExtension(name, "txt")))
			MusicState.errorText += 'Image ${HaxePath.withExtension(name, "txt")} not found.\n';
		return File.getContent(assets.get(HaxePath.withExtension(name, "txt")));
	}

	public static inline function combine(paths:Array<String>):String
		return HaxePath.removeTrailingSlashes(HaxePath.normalize(HaxePath.join(paths)));
}
