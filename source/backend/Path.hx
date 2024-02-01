package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path as HaxePath;
import sys.FileSystem;
import sys.io.File;

class Path
{
	public static inline function font(name:String, ?folder:String, searchSubdirectories:Bool = true, searchTwoLayers:Bool = true):String
		return find(name, folder ?? "fonts", searchSubdirectories, searchTwoLayers);

	public static inline function sparrow(name:String, ?folder:String, searchSubdirectories:Bool = true, searchTwoLayers:Bool = true):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(name, folder, searchSubdirectories, searchTwoLayers), xml(name, folder, searchSubdirectories, searchTwoLayers));

	public static function song(name:String):Array<String>
	{
		var pathArray = [];
		if (FileSystem.exists(HaxePath.join(["assets", "songs", name, "Song.ogg"])))
			pathArray.push(HaxePath.join(["assets", "songs", name, "Song.ogg"]));
		else
		{
			if (FileSystem.exists(HaxePath.join(["assets", "songs", name, "Inst.ogg"])))
				pathArray.push(HaxePath.join(["assets", "songs", name, "Inst.ogg"]));
			if (FileSystem.exists(HaxePath.join(["assets", "songs", name, "Voices.ogg"])))
				pathArray.push(HaxePath.join(["assets", "songs", name, "Voices.ogg"]));

			if (!FileSystem.exists(HaxePath.join(["assets", "songs", name, "Inst.ogg"]))
				&& !FileSystem.exists(HaxePath.join(["assets", "songs", name, "Voices.ogg"]))
				&& !FileSystem.exists(HaxePath.join(["assets", "songs", name, "Song.ogg"])))
				Util.error("Song not found: " + name);
		}
		return pathArray;
	}

	public static inline function sound(name:String, ?folder:String, searchSubdirectories:Bool = true, searchTwoLayers:Bool = true):String
		return find(HaxePath.withExtension(name, "ogg"), folder ?? "sounds", searchSubdirectories, searchTwoLayers);

	public static inline function image(name:String, ?folder:String, searchSubdirectories:Bool = true, searchTwoLayers:Bool = true):String
		return find(HaxePath.withExtension(name, "png"), folder ?? "images", searchSubdirectories, searchTwoLayers);

	public static function xml(name:String, ?folder:String, searchSubdirectories:Bool = true, searchTwoLayers:Bool = true):String
		return find(HaxePath.withExtension(name, "xml"), folder ?? "images", searchSubdirectories, searchTwoLayers);

	public static inline function txt(name:String, ?folder:String, searchSubdirectories:Bool = true, searchTwoLayers:Bool = true):String
		return File.getContent(find(name, folder ?? "data", searchSubdirectories, searchTwoLayers));

	public static function find(name:String, ?folder:String, searchSubdirectories:Bool = true, searchTwoLayers:Bool = true, error:Bool = true):String
	{
		var path = "assets";
		if (folder != null)
			path = HaxePath.join([path, folder]);
		if (FileSystem.exists(HaxePath.join([path, name])))
			return HaxePath.join([path, name]);
		else if (searchSubdirectories)
			for (subdir in FileSystem.readDirectory(path))
			{
				if (!FileSystem.isDirectory(HaxePath.join([path, subdir])))
					continue;
				if (FileSystem.exists(HaxePath.join([path, subdir, name])))
					return HaxePath.join([path, subdir, name]);
				else if (searchTwoLayers)
					for (subsubdir in FileSystem.readDirectory(HaxePath.join([path, subdir])))
					{
						if (!FileSystem.isDirectory(HaxePath.join([path, subdir, subsubdir])))
							continue;
						if (FileSystem.exists(HaxePath.join([path, subdir, subsubdir, name])))
							return HaxePath.join([path, subdir, subsubdir, name]);
					}
			}

		if (error)
			Util.error("File \"" + name + "\" Not Found.\nArguments to Path.find:\nname: " + name + "\nfolder: " + folder + "\nsearchSubdirectories: "
				+ searchSubdirectories + "\nsearchTwoLayers: " + searchTwoLayers);
		return null;
	}
}
