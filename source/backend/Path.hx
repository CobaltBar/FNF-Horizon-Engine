package backend;

import flash.media.Sound;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import haxe.io.Path as HaxePath;
import modding.Mod;
import modding.ModManager;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.system.System;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class Path
{
	static var assets:Map<String, String> = [];
	static var modAssets:Map<Mod, Map<String, String>> = [];

	// Stolen Psych Code
	static var localTrackedAssets:Array<String> = [];
	static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	static var currentTrackedSounds:Map<String, Sound> = [];

	public static function clearUnusedMemory():Void
	{
		for (key in currentTrackedAssets.keys())
		{
			if (!localTrackedAssets.contains(key) && key != "assets/songs/menuSong.ogg")
			{
				var obj = currentTrackedAssets.get(key);
				if (obj != null)
				{
					@:privateAccess FlxG.bitmap._cache.remove(key);
					Assets.cache.removeBitmapData(key);
					currentTrackedAssets.remove(key);
					obj.persist = false;
					obj.destroyOnNoUse = true;
					obj.destroy();
				}
			}
		}
		System.gc();
	}

	public static function clearStoredMemory():Void
	{
		for (key in @:privateAccess FlxG.bitmap._cache.keys())
		{
			var obj = @:privateAccess FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				@:privateAccess FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		for (key => value in currentTrackedSounds)
			if (!localTrackedAssets.contains(key) && key != "assets/songs/menuSong.ogg")
			{
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}

		// Thanks Sword
		for (key in cast(openfl.utils.Assets.cache, openfl.utils.AssetCache).font.keys())
			cast(openfl.utils.Assets.cache, openfl.utils.AssetCache).font.remove(key);
		localTrackedAssets = [];
	}

	public static function cacheBitmap(key:String, ?mod:Mod, ?path:Bool = false):FlxGraphicAsset
	{
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path ? key : find(key, 'png', true, true, 'Bitmap Cache - Image', mod)), false,
			key);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		currentTrackedAssets.set(key, graphic);
		localTrackedAssets.push(key);
		return graphic;
	} // Horizon Engine Time

	@:keep
	public static inline function find(key:String, extension:String, error:Bool = false, kill:Bool = false, ?description:String, ?mod:Mod):String
	{
		if (mod != null && modAssets[mod].exists('$key.$extension'))
			return modAssets[mod].get('$key.$extension');
		if (assets.exists('$key.$extension'))
			return assets.get('$key.$extension');

		ErrorState.error(null, description == null ? extension.toUpperCase() : description + ' $key not found.', kill);
		return null;
	}

	@:keep
	public static inline function image(key:String, ?mod:Mod):FlxGraphicAsset
	{
		if (currentTrackedAssets.exists(key))
		{
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}

		return cacheBitmap(key, mod);
	}

	@:keep
	public static inline function sound(key:String, ?mod:Mod):Sound
	{
		var file = find(key, 'ogg', true, false, 'Sound', mod);
		if (!currentTrackedSounds.exists(file))
			currentTrackedSounds.set(file, Sound.fromFile(file));
		localTrackedAssets.push(file);
		return currentTrackedSounds.get(file);
	}

	@:keep
	public static inline function font(key:String, ?mod:Mod):String
		if (find(key, 'ttf', false, false, 'Font (TTF)', mod) != null)
			return find(key, 'ttf', false, false, 'Font (TTF)', mod);
		else
			return find(key, 'otf', false, false, 'Font (OTF)', mod);

	@:keep
	public static inline function json(key:String, ?mod:Mod):Dynamic
		return TJSON.parse(File.getContent(find(key, 'json', true, true, null, mod)));

	@:keep
	public static inline function xml(key:String, ?mod:Mod):String
		return find(key, 'xml', true, true, mod);

	@:keep
	public static inline function txt(key:String, ?mod:Mod):String
		return File.getContent(find(key, 'txt', true, true, mod));

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
							continue;
						else
							for (asset3 in FileSystem.readDirectory(combine(['assets', asset, asset2])))
								if (FileSystem.isDirectory(combine(['assets', asset, asset2, asset3])))
								{
									for (asset4 in FileSystem.readDirectory(combine(['assets', asset, asset2, asset3])))
										if (!FileSystem.isDirectory(combine(['assets', asset, asset2, asset3, asset4])))
											addAsset(asset4, combine(['assets', asset, asset2, asset3, asset4]));
								}
								else
									addAsset(asset3, combine(['assets', asset, asset2, asset3]));
					}
					else
						addAsset(asset2, combine(['assets', asset, asset2]));
			}
			else
				addAsset(asset, combine(['assets', asset]));
	}

	public static function reloadModAssets():Void
	{
		modAssets.clear();
		for (mod in ModManager.allMods)
		{
			modAssets.set(mod, []);
			if (!mod.enabled)
				continue;
			for (folder in FileSystem.readDirectory(combine(['mods', mod.path])))
				if (FileSystem.isDirectory(combine(['mods', mod.path, folder])))
					for (file in FileSystem.readDirectory(combine(['mods', mod.path, folder])))
						if (!FileSystem.isDirectory(combine(['mods', mod.path, folder, file])))
							switch (folder)
							{
								case "achievements":
								case "characters":
								case "events":
								case "notetypes":
								case "fonts" | "images" | "shaders" | "sounds" | "videos":
									addAsset(file, combine(['mods', mod.path, folder, file]), mod);
								case "menu_scripts":
								case "scripts":
								case "songs":
								case "stages":
								case "weeks":
							}
		}
	}

	private static function addAsset(key:String, path:String, ?mod:Mod):Void
		mod == null ? assets.set(assets.exists(key) ? '${HaxePath.withoutExtension(key)}-1${HaxePath.extension(key)}' : key,
			path) : modAssets[mod].set(modAssets[mod].exists(key) ? '${HaxePath.withoutExtension(key)}-1${HaxePath.extension(key)}' : key, path);

	public static function combine(paths:Array<String>):String
		return HaxePath.removeTrailingSlashes(HaxePath.normalize(HaxePath.join(paths)));
}
