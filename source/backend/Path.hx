package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path as HaxePath;
import modding.ModManager;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class Path
{
	public static inline function image(name:String, ?p:String, ?folder:String):String
		return find(HaxePath.withExtension(name, "png"), p, folder ?? 'images');

	public static inline function txt(name:String, ?p:String, ?folder:String, modifyExtension:Bool = true):String
		return File.getContent(find(modifyExtension ? HaxePath.withExtension(name, "txt") : name, p, folder ?? 'data'));

	public static inline function json(name:String, ?p:String, ?folder:String):Dynamic
		return TJSON.parse(txt(HaxePath.withExtension(name, "json"), p, folder, false));

	public static inline function xml(name:String, ?p:String, ?folder:String):String
		return find(HaxePath.withExtension(name, "xml"), p, folder);

	public static inline function font(name:String, ?p:String, ?folder:String, extension:String = "ttf"):String
		return find(HaxePath.withExtension(name, extension), p, folder ?? 'fonts');

	public static inline function sound(name:String, ?p:String, ?folder:String, extension:String = "ogg"):String
		return find(HaxePath.withExtension(name, extension), p, folder ?? 'sounds');

	public static inline function sparrow(name:String, ?p:String, ?folder:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(name, p, folder), xml(name, p, folder));

	public static function song(name:String):Array<String>
	{
		var songs:Array<String> = [];

		var path = combine(["assets", "songs", name]);
		if (FileSystem.exists(path) && FileSystem.isDirectory(path))
		{
			if (FileSystem.exists(combine([path, "Song.ogg"])))
				songs.push(combine([path, "Song.ogg"]));
			if (FileSystem.exists(combine([path, "Inst.ogg"])))
				songs.push(combine([path, "Inst.ogg"]));
			if (FileSystem.exists(combine([path, "Voices.ogg"])))
				songs.push(combine([path, "Voices.ogg"]));

			if (songs.length > 0)
				return songs;
		}

		for (mod in ModManager.enabledMods)
		{
			path = combine([mod.path, "songs", name]);
			if (FileSystem.exists(path) && FileSystem.isDirectory(path))
			{
				if (FileSystem.exists(combine([path, "Song.ogg"])))
					songs.push(combine([path, "Song.ogg"]));
				if (FileSystem.exists(combine([path, "Inst.ogg"])))
					songs.push(combine([path, "Inst.ogg"]));
				if (FileSystem.exists(combine([path, "Voices.ogg"])))
					songs.push(combine([path, "Voices.ogg"]));
				if (songs.length > 0)
					return songs;
			}
		}
		Util.error('Song "$name" Not Found.');
		return null;
	}

	public static function find(name:String, ?p:String, ?folder:String):String
	{
		if (p != null && FileSystem.exists(p))
			return p;
		var path = "assets";
		if (folder != null)
			path = combine([path, folder]);
		if (FileSystem.exists(combine([path, name])))
			return combine([path, name]);
		else
		{
			for (subdir in FileSystem.readDirectory(path))
			{
				if (FileSystem.exists(combine([path, subdir, name])))
					return combine([path, subdir, name]);
				else if (FileSystem.isDirectory(combine([path, subdir])))
					for (subsubdir in FileSystem.readDirectory(combine([path, subdir])))
						if (FileSystem.exists(combine([path, subdir, subsubdir, name])))
							return combine([path, subdir, subsubdir, name]);
			}

			if (FileSystem.exists(combine(["assets", name])))
				return combine(["assets", name]);
			else
				for (dir in FileSystem.readDirectory("assets"))
				{
					if (FileSystem.exists(combine(["assets", dir, name])))
						return combine(["assets", dir, name]);
					else if (FileSystem.isDirectory(combine([path, dir])))
						for (subdir in FileSystem.readDirectory(combine([path, dir])))
							if (FileSystem.exists(combine([path, dir, subdir, name])))
								return combine([path, dir, subdir, name]);
				}
		}

		for (mod in ModManager.enabledMods)
		{
			path = mod.path;
			if (folder != null)
				path = combine([path, folder]);
			if (FileSystem.exists(combine([path, name])))
				return combine([path, name]);
			else
			{
				for (subdir in FileSystem.readDirectory(path))
				{
					if (FileSystem.exists(combine([path, subdir, name])))
						return combine([path, subdir, name]);
					else if (FileSystem.isDirectory(combine([path, subdir])))
						for (subsubdir in FileSystem.readDirectory(combine([path, subdir])))
							if (FileSystem.exists(combine([path, subdir, subsubdir, name])))
								return combine([path, subdir, subsubdir, name]);
				}

				if (FileSystem.exists(combine([mod.path, name])))
					return combine([mod.path, name]);
				else
					for (dir in FileSystem.readDirectory(mod.path))
					{
						if (FileSystem.exists(combine([mod.path, dir, name])))
							return combine([mod.path, dir, name]);
						else if (FileSystem.isDirectory(combine([path, dir])))
							for (subdir in FileSystem.readDirectory(combine([path, dir])))
								if (FileSystem.exists(combine([path, dir, subdir, name])))
									return combine([path, dir, subdir, name]);
					}
			}
		}

		Util.error('File "$name" Not Found.');
		return "";
	}

	public static inline function combine(paths:Array<String>):String
		return HaxePath.normalize(HaxePath.join(paths));
}
