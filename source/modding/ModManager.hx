package modding;

import flixel.addons.util.FlxAsyncLoop;
import haxe.io.Path;
import objects.AssetMGR;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class ModManager
{
	public static var mods:Array<Mod> = new Array<Mod>();
	public static var standaloneMods:Array<Mod> = new Array<Mod>();
	public static var chooseModState:Bool = false;
	public static var theChosenMod:Mod = null;
	public static var loaded = false;

	final folders:Array<String> = [
		"achievements", "characters", "charts", "custom_events", "custom_notetypes", "fonts", "images", "menu_scripts", "scripts", "shaders", "songs",
		"sounds", "stages", "videos", "weeks"
	];

	public static function loadMods():Void
	{
		if (FileSystem.exists('mods/'))
		{
			for (folder in FileSystem.readDirectory('mods/'))
			{
				if (folder == "Mod Template")
					continue;

				if (FileSystem.exists("mods/" + folder + "/mod.json"))
				{
					var data:ModJsonData = TJSON.parse(File.getContent("mods/" + folder + "/mod.json"));

					mods.push(new Mod(data.name ?? "Blank Mod", data.description ?? "No Description", data.version ?? "1.0.0", data.color ?? [255, 255, 255],
						data.globalMod ?? true, data.rpcChange, "mods/" + folder + "/", false,
						FileSystem.exists("mods/" + folder + "/mod.png") ? "mods/" + folder + "/mod.png" : "assets/images/unknownMod.png"));
				}
				else
					mods.push(new Mod("Blank Mod", "No Description", "1.0.0", [255, 255, 255], true, null, "mods/" + folder + "/", false,
						"assets/images/unknownMod.png"));
			}
		}

		for (mod in mods)
		{
			for (file in FileSystem.readDirectory(mod.path + "menu_scripts/"))
			{
				if (file == null || FileSystem.isDirectory(mod.path + "menu_scripts/" + file) || file == "keep.txt")
					continue;
				standaloneMods.push(mod);
				mod.standalone = true;
				chooseModState = true;
			}
		}

		loaded = true;
	}

	public static function replaceAssets():Void
	{
		for (file in FileSystem.readDirectory(theChosenMod.path + "images/"))
		{
			if (file == null || FileSystem.isDirectory(theChosenMod.path + "images/" + file) || file == "keep.txt")
				continue;

			if (AssetMGR.images.exists(Path.withoutExtension(file)))
				AssetMGR.images.set(Path.withoutExtension(file), theChosenMod.path + "images/" + file);

			if (AssetMGR.animatedImages.exists(file.replace(".png", "")))
			{
				var fN:String = file.replace(".png", "");
				var nP:String = theChosenMod.path + "images/" + fN;

				AssetMGR.animatedImages.set(fN, ['$nP.png', '$nP.xml']);
			}
		}

		for (file in FileSystem.readDirectory(theChosenMod.path + "sounds/"))
		{
			if (file == null || FileSystem.isDirectory(theChosenMod.path + "sounds/" + file) || file == "keep.txt")
				continue;

			if (AssetMGR.sounds.exists(Path.withoutExtension(file)))
				AssetMGR.sounds.set(Path.withoutExtension(file), theChosenMod.path + "sounds/" + file);
		}
	}
}

class Mod
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var globalMod:Bool;
	public var rpcChange:String;
	public var path:String;
	public var standalone:Bool;
	public var icon:String;

	public function new(name:String, description:String, version:String, color:Array<Int>, globalMod:Bool, rpcChange:String, path:String, standalone:Bool,
			icon:String)
	{
		this.name = name;
		this.description = description;
		this.version = version;
		this.color = color;
		this.globalMod = globalMod;
		this.rpcChange = rpcChange;
		this.path = path;
		this.standalone = standalone;
		this.icon = icon;
	}
}

typedef ModJsonData =
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var globalMod:Bool;
	public var rpcChange:String;
}
