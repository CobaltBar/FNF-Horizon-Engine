package backend;

// TODO finish the todo below and MAKE MODS  AN ARRAY
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import haxe.io.Path as HaxePath;
import modding.ModTypes;
import modding.Mods;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.system.System;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;
import util.Log;

// Based off of PsychEngine's Paths.hx
class Path
{
	static var assets:Map<String, String> = [];
	static var modAssets:Map<Mod, Map<String, String>> = [];

	static var localAssets:Array<String> = [];
	static var trackedImages:Map<String, FlxGraphic> = [];
	static var trackedSounds:Map<String, Sound> = [];

	static final memoryClearExlusions:Array<String> = ['assets/songs/menuSong.ogg'];

	public static function clearUnusedMemory():Void
	{
		for (key in trackedImages.keys())
			if (!localAssets.contains(key) && !memoryClearExlusions.contains(key) && trackedImages.get(key) != null)
			{
				var obj = trackedImages.get(key);
				@:privateAccess FlxG.bitmap._cache.remove(key);
				Assets.cache.removeBitmapData(key);
				trackedImages.remove(key);
				obj.persist = false;
				obj.destroyOnNoUse = true;
				obj.destroy();
			}
		System.gc();
	}

	public static function clearStoredMemory():Void
	{
		for (key in @:privateAccess FlxG.bitmap._cache.keys())
		{
			var obj = @:privateAccess FlxG.bitmap._cache.get(key);
			if (obj != null && !trackedImages.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				@:privateAccess FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		for (key => value in trackedSounds)
			if (!localAssets.contains(key) && !memoryClearExlusions.contains(key))
			{
				Assets.cache.clear(key);
				trackedSounds.remove(key);
			}

		// Thanks Sword
		for (key in cast(openfl.utils.Assets.cache, openfl.utils.AssetCache).font.keys())
			cast(openfl.utils.Assets.cache, openfl.utils.AssetCache).font.remove(key);
		localAssets = [];
	}

	public static function loadAssets():Void
	{
		assets.clear();
		for (asset in FileSystem.readDirectory('assets'))
		{
			var assetPath = combine(['assets', asset]);
			if (FileSystem.isDirectory(assetPath))
				for (asset2 in FileSystem.readDirectory(assetPath))
				{
					var asset2Path = combine(['assets', asset, asset2]);
					if (FileSystem.isDirectory(asset2Path))
					{
						if (asset == 'songs')
							continue;
						for (asset3 in FileSystem.readDirectory(asset2Path))
						{
							var asset3Path = combine(['assets', asset, asset2, asset3]);
							if (FileSystem.isDirectory(asset3Path))
								for (asset4 in FileSystem.readDirectory(asset3Path))
								{
									var asset4Path = combine(['assets', asset, asset2, asset3, asset4]);
									if (!FileSystem.isDirectory(asset4Path))
										addAsset(asset4, asset4Path);
								}
							else
								addAsset(asset3, asset3Path);
						}
					}
					else
						addAsset(asset2, asset2Path);
				}
			else
				addAsset(asset, assetPath);
		}
		if (Main.verboseLogging)
			Log.info('Assets Loaded');
	}

	public static function loadModAssets():Void
	{
		modAssets.clear();
		for (mod in Mods.enabled)
		{
			modAssets.set(mod, []);
			var modDir = combine(['mods', mod.path]);
			for (folder in FileSystem.readDirectory(modDir))
				if (FileSystem.isDirectory(modDir))
					if (folder == 'fonts' || folder == 'images' || folder == 'shaders' || folder == 'sounds' || folder == 'videos')
						for (asset in FileSystem.readDirectory(combine([modDir, folder])))
						{
							var assetPath = combine([modDir, folder, asset]);
							if (!FileSystem.isDirectory(assetPath))
								addAsset(asset, assetPath, mod);
						}
		}
		if (Main.verboseLogging)
			Log.info('Mod Assets Loaded: ${Mods.enabled.length} Mods');
	}

	public static function cacheBitmap(key:String, ?mod:Mod, path:Null<Bool> = false):FlxGraphic
	{
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path ? key : find(key, ['png'], mod)), false,
			mod != null ? '${mod.path}-$key' : key);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		trackedImages.set(mod != null ? '${mod.path}-$key' : key, graphic);
		localAssets.push(mod != null ? '${mod.path}-$key' : key);
		return graphic;
	}

	public static function find(key:String, extensions:Array<String>, ?mod:Mod, fatal:Null<Bool> = false):Null<String>
	{
		for (extension in extensions)
		{
			if (mod != null)
				if (modAssets.exists(mod))
					if (modAssets[mod].exists('$key.$extension'))
						return modAssets[mod].get('$key.$extension');
			if (assets.exists('$key.$extension'))
				return assets.get('$key.$extension');

			Log.warn('Asset $key.$extension not found.');
			return null;
		}
		return null;
	}

	@:keep
	public static inline function image(key:String, ?mod:Mod):FlxGraphic
		if (trackedImages.exists(mod != null ? '${mod.path}-$key' : key))
		{
			localAssets.push(mod != null ? '${mod.path}-$key' : key);
			return trackedImages.get(mod != null ? '${mod.path}-$key' : key);
		}
		else
		{
			Log.info('Caching image $key');
			return cacheBitmap(key, mod);
		}

	public static function sound(key:String, ?mod:Mod):Sound
	{
		if (!trackedSounds.exists(key))
			if (find(key, ['ogg'], mod) == null)
			{
				Log.warn('Sound $key not found. Playing beep.');
				return FlxAssets.getSound('flixel/sounds/beep');
			}
			else
				trackedSounds.set(key, Sound.fromFile(find(key, ['ogg'], mod)));
		localAssets.push(key);
		return trackedSounds.get(key);
	}

	@:keep
	public static inline function font(key:String, ?mod:Mod):Null<String>
		return find(key, ['ttf', 'otf'], mod);

	@:keep
	public static inline function json(key:String, ?mod:Mod):Dynamic
		return TJSON.parse(File.getContent(find(key, ['json'], mod) ?? ''));

	@:keep
	public static inline function xml(key:String, ?mod:Mod):Null<String>
		return find(key, ['xml'], mod, true);

	@:keep
	public static inline function txt(key:String, ?mod:Mod):Null<String>
		return File.getContent(find(key, ['txt'], mod));

	@:keep
	public static inline function sparrow(key:String, ?mod:Mod):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key, mod), xml(key, mod));

	public static inline function combine(paths:Array<String>):String
		return HaxePath.removeTrailingSlashes(HaxePath.normalize(HaxePath.join(paths)));

	// TODO: Change `-1` to be a number rather than a hardcoded string
	private static function addAsset(key:String, path:String, ?mod:Mod):Void
	{
		if (mod != null)
		{
			if (modAssets[mod].exists(key))
			{
				Log.warn('Mod (${mod.name}) Asset $key already exists. Renaming to ${HaxePath.withoutExtension(key)}-1.${HaxePath.extension(key)}');
				modAssets[mod].set('${HaxePath.withoutExtension(key)}-1.${HaxePath.extension(key)}', path);
			}
			else
				modAssets[mod].set(key, path);
		}
		else
		{
			if (assets.exists(key))
			{
				Log.warn('Asset $key already exists. Renaming to ${HaxePath.withoutExtension(key)}-1.${HaxePath.extension(key)}');
				assets.set('${HaxePath.withoutExtension(key)}-1.${HaxePath.extension(key)}', path);
			}
			else
				assets.set(key, path);
		}
	}
}
