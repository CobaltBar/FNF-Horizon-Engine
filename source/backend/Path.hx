package backend;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path as HaxePath;
import modding.Mod;
import modding.ModManager;
import openfl.display.BitmapData;
import openfl.system.System;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class Path
{
	static var assets:Map<String, String> = [];
	static var modAssets:Map<Mod, Map<String, String>> = [];

	public static function cacheBitmap(path:String):FlxGraphic
	{
		if (FileSystem.exists(path))
		{
			var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path), false, path);
			newGraphic.destroyOnNoUse = false;
			return newGraphic;
		}
		else
			ErrorState.error(null, 'Couldn\'t cache bitmap $path.', true);
		return null;
	}

	@:keep
	public static inline function find(key:String, extension:String, error:Bool = false, ?description:String, ?mod:Mod):String
	{
		if (mod != null && modAssets[mod].exists('$key.$extension'))
			return modAssets[mod].get('$key.$extension');
		if (assets.exists('$key.$extension'))
			return assets.get('$key.$extension');

		ErrorState.error(null, description == null ? extension.toUpperCase() : description + '$key not found.', error);
		return null;
	}

	@:keep
	public static inline function image(key:String, ?mod:Mod):String
		return find(key, 'png', false, 'Image', mod);

	@:keep
	public static inline function sound(key:String, ?mod:Mod):String
		return find(key, 'ogg', false, 'Sound', mod);

	@:keep
	public static inline function font(key:String, ?mod:Mod):String
		if (find(key, 'ttf', false, 'Font (TTF)', mod) != null)
			return find(key, 'ttf', false, 'Font (TTF)', mod);
		else
			return find(key, 'otf', false, 'Font (OTF)', mod);

	@:keep
	public static inline function json(key:String, ?mod:Mod):Dynamic
		return TJSON.parse(File.getContent(find(key, 'json', true, null, mod)));

	@:keep
	public static inline function xml(key:String, ?mod:Mod):String
		return find(key, 'xml', true, mod);

	@:keep
	public static inline function txt(key:String, ?mod:Mod):String
		return File.getContent(find(key, 'txt', true, mod));

	public static function sparrow(key:String, ?mod:Mod):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key, mod), xml(key, mod));

	public static function loadAssets():Void
	{
		assets.clear();
		assets = [];
		for (asset in FileSystem.readDirectory('assets'))
			if (FileSystem.isDirectory(combine(['assets', asset])))
			{
				for (asset2 in FileSystem.readDirectory(combine(['assets', asset])))
					if (FileSystem.isDirectory(combine(['assets', asset, asset2])))
					{
						if (asset == "songs")
						{
							addAsset('song-$asset2', combine(['assets', asset, asset2]));
							continue;
						}
						else
							for (asset3 in FileSystem.readDirectory(combine(['assets', asset, asset2])))
								if (!FileSystem.isDirectory(combine(['assets', asset, asset2, asset3])))
									addAsset(asset3, combine(['assets', asset, asset2, asset3]));
					}
					else
						addAsset(asset2, combine(['assets', asset, asset2]));
			}
			else
				addAsset(asset, combine(['assets', asset]));
	}

	public static function reloadEnabledMods():Void
	{
		modAssets.clear();
		modAssets = [];
		for (mod in ModManager.enabledMods)
			for (asset in FileSystem.readDirectory(combine(['mods', mod.path])))
			{
				modAssets.set(mod, []);
				if (FileSystem.isDirectory(combine(['mods', mod.path, asset]))
					&& asset != "custom_events"
					&& asset != "custom_notetypes"
					&& asset != "menu_scripts"
					&& asset != "scripts"
					&& asset != "stages")
					for (asset2 in FileSystem.readDirectory(combine(['mods', mod.path, asset])))
						if (!FileSystem.isDirectory(combine(['mods', mod.path, asset, asset2])))
							addAsset(asset2, combine(['assets', asset, asset2]), mod);
						else
						{
							if (asset == "songs")
							{
								addAsset('song-$asset2', combine(['assets', asset, asset2]), mod);
								continue;
							}
						}
			}
	}

	private static function addAsset(key:String, path:String, ?mod:Mod):Void
		mod == null ? assets.set(assets.exists(key) ? '${HaxePath.withoutExtension(key)}-1${HaxePath.extension(key)}' : key,
			path) : modAssets[mod].set(modAssets[mod].exists(key) ? '${HaxePath.withoutExtension(key)}-1${HaxePath.extension(key)}' : key, path);

	@:keep
	public static inline function combine(paths:Array<String>):String
		return HaxePath.removeTrailingSlashes(HaxePath.normalize(HaxePath.join(paths)));
}
