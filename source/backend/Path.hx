package backend;

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

// Based off of Psych Engine's Paths.hx
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

		for (key in trackedSounds.keys())
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
		recursiveSearch('assets', path ->
		{
			var key = HaxePath.withoutDirectory(path);
			if (assets.exists(key))
			{
				var i:Int = 1;
				while (assets.exists('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}'))
					i++;
				Log.warn('Asset \'$key\' already exists. Renaming to \'${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}\' (Assets)');
				assets.set('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}', path);
			}
			else
				assets.set(key, path);
		});
		if (Main.verboseLogging)
			Log.info('Assets Loaded');
	}

	public static function loadModAssets():Void
	{
		modAssets.clear();
		for (mod in Mods.enabled)
		{
			modAssets.set(mod, []);
			recursiveSearch(combine(['mods', mod.path]), path ->
			{
				var key = HaxePath.withoutDirectory(path);
				if (path.contains('songs'))
				{
					if (HaxePath.extension(path) == 'json')
						key = 'song-${HaxePath.withoutDirectory(HaxePath.directory(path))}-$key';
				}
				else if (key.contains('stages'))
					key = 'stage-$key';
				else if (key.contains('scripts'))
					key = 'script-$key';

				if (modAssets[mod].exists(key))
				{
					var i:Int = 1;
					while (modAssets[mod].exists('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}'))
						i++;
					Log.warn('Asset \'$key\' already exists. Renaming to \'${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}\' (Mod \'${mod.name}\')');
					modAssets[mod].set('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}', path);
				}
				else
					modAssets[mod].set(key, path);
			});

			if (Main.verboseLogging)
				Log.info('Assets Loaded for Mods: ${[for (mod in Mods.enabled) mod.name].join(', ')}');
		}
	}

	public static function find(key:String, extensions:Array<String>, ?mods:Array<Mod>, fatal:Null<Bool> = false):Null<{path:String, mod:Mod}>
	{
		for (extension in extensions)
		{
			if (mods != null)
				for (mod in mods)
					if (modAssets[mod].exists('$key.$extension'))
						return {path: modAssets[mod].get('$key.$extension'), mod: mod};
			if (assets.exists('$key.$extension'))
				return {path: assets.get('$key.$extension'), mod: null};
			Log.warn('Asset \'$key.$extension\' not found.');
		}
		return {path: '', mod: null};
	}

	public static function cacheBitmap(key:String, ?mods:Array<Mod>, path:Null<Bool> = false):FlxGraphic
	{
		var found = path ? {path: '', mod: null} : find(key, ['png'], mods, false);
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path ? key : found.path) ?? FlxAssets.getBitmapData('flixel/images/logo/default.png'),
			false,
			found.mod != null ? '${found.mod.path}-$key' : key);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		trackedImages.set(found.mod != null ? '${found.mod.path}-$key' : key, graphic);
		localAssets.push(found.mod != null ? '${found.mod.path}-$key' : key);
		if (found.path != null)
			Log.info('Caching image \'$key\' ' + (found.mod != null ? '(Mod \'${found.mod.name}\')' : '(Assets)'));
		return graphic;
	}

	public static function image(key:String, ?mods:Array<Mod>):FlxGraphic
	{
		if (mods != null)
			for (mod in mods)
				if (trackedImages.exists('${mod.path}-$key'))
				{
					localAssets.push('${mod.path}-$key');
					return trackedImages.get('${mod.path}-$key');
				}

		if (trackedImages.exists(key))
		{
			localAssets.push(key);
			return trackedImages.get(key);
		}

		return cacheBitmap(key, mods);
	}

	public static function sound(key:String, ?mods:Array<Mod>):Sound
	{
		if (!trackedSounds.exists(key))
			if (find(key, ['ogg'], mods).path == '')
			{
				Log.warn('Sound \'$key\' not found. Playing beep.');
				return FlxAssets.getSound('flixel/sounds/beep');
			}
			else
				trackedSounds.set(key, Sound.fromFile(find(key, ['ogg'], mods).path));
		localAssets.push(key);
		return trackedSounds.get(key);
	}

	private static function recursiveSearch(path:String, callback:String->Void)
		if (FileSystem.isDirectory(path))
			for (entry in FileSystem.readDirectory(path))
			{
				var realPath = combine([path, entry]);
				if (FileSystem.isDirectory(realPath))
					recursiveSearch(realPath, callback);
				else
					callback(realPath);
			}

	@:keep
	public static inline function font(key:String, ?mods:Array<Mod>):Null<String>
		return find(key, ['ttf', 'otf'], mods).path;

	@:keep
	public static inline function json(key:String, ?mods:Array<Mod>):Dynamic
		return TJSON.parse(File.getContent(find(key, ['json'], mods).path ?? ''));

	@:keep
	public static inline function xml(key:String, ?mods:Array<Mod>):Null<String>
		return find(key, ['xml'], mods, true).path;

	@:keep
	public static inline function txt(key:String, ?mods:Array<Mod>):Null<String>
		return File.getContent(find(key, ['txt'], mods).path ?? '');

	@:keep
	public static inline function sparrow(key:String, ?mods:Array<Mod>):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key, mods), xml(key, mods));

	@:keep
	public static inline function combine(paths:Array<String>):String
		return HaxePath.removeTrailingSlashes(HaxePath.normalize(HaxePath.join(paths)));
}
