package backend;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import haxe.io.Path as HaxePath;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.system.System;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

// Based off PsychEngine's Paths.hx
class Path
{
	static var assets:Map<Mod, Map<String, String>> = [];

	static var localAssets:Array<String> = [];
	static var trackedImages:Map<String, FlxGraphic> = [];
	static var trackedSounds:Map<String, Sound> = [];

	static final exclusionRegexes:Array<EReg> = [~/\d{1,}x\d{1,}:.*/, ~/text\d{0,}/, ~/pixels/, ~/assets\/songs\/menuSong\.ogg/];

	public static function clearUnusedMemory():Void
	{
		for (key in trackedImages.keys())
			if (!localAssets.contains(key) && trackedImages.get(key) != null)
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

	public static function clearStoredMemory():Void @:privateAccess {
		for (key in FlxG.bitmap._cache.keys())
		{
			if (FlxG.bitmap._cache.get(key) == null)
				continue;
			if (exclusionRegexes[0].match(key))
				continue;
			if (exclusionRegexes[1].match(key))
				continue;
			if (exclusionRegexes[2].match(key))
				continue;
			if (!trackedImages.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				FlxG.bitmap._cache[key]?.destroy();
			}
		}

		for (key in trackedSounds.keys())
			if (!localAssets.contains(key) && !exclusionRegexes[3].match(key))
			{
				Assets.cache.clear(key);
				trackedSounds.remove(key);
			}
		// Thanks Sword
		for (key in cast(openfl.utils.Assets.cache, openfl.utils.AssetCache).font.keys())
			cast(openfl.utils.Assets.cache, openfl.utils.AssetCache).font.remove(key);
		localAssets = [];
	}

	public static function find(key:String, exts:Array<String>, ?mods:Array<Mod>, mustFind:Bool = false):{path:String, mod:Mod}
	{
		for (ext in exts)
		{
			if (mods != null)
				for (mod in mods)
					if (assets[mod].exists('$key.$ext'))
						return {path: assets[mod].get('$key.$ext'), mod: mod};
			if (assets[Mods.all['assets']].exists('$key.$ext'))
				return {path: assets[Mods.all['assets']].get('$key.$ext'), mod: Mods.all['assets']}
			Log.warn('Asset \'$key.$ext\' not found.');
		}
		return null;
	}

	public static function cacheBitmap(key:String, ?mods:Array<Mod>, keyAsPath:Bool = false):FlxGraphic
	{
		var found = keyAsPath ? {path: key, mod: null} : find(key, ['png'], mods, false);
		var realKey = found?.mod != null ? found?.mod?.folderName == 'assets' ? key : '${found?.mod?.folderName}-$key' : key;
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(found?.path) ?? FlxAssets.getBitmapData('flixel/images/logo/default.png'),
			false, realKey);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		trackedImages.set(realKey, graphic);
		localAssets.push(realKey);
		Log.info('Caching image $key (${found?.mod != null ? found?.mod?.name : 'Path'})');
		return graphic;
	}

	public static function image(key:String, ?mods:Array<Mod>):FlxGraphic
	{
		if (mods != null)
			for (mod in mods)
				if (trackedImages.exists('${mod.folderName}-$key'))
				{
					localAssets.push('${mod.folderName}-$key');
					return trackedImages.get('${mod.folderName}-$key');
				}
		if (trackedImages.exists(key))
		{
			localAssets.push(key);
			return trackedImages.get(key);
		}
		return cacheBitmap(key, mods);
	}

	public static function audio(key:String, ?mods:Array<Mod>):Sound
	{
		if (!trackedSounds.exists(key))
			if (find(key, ['ogg'], mods) == null)
			{
				Log.warn('Audio \'$key\' not found. Playing beep');
				return FlxAssets.getSound('flixel/sounds/beep');
			}
			else
				trackedSounds.set(key, Sound.fromFile(find(key, ['ogg'], mods).path));
		localAssets.push(key);
		return trackedSounds.get(key);
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

	public static function loadAssets():Void
	{
		assets.clear();

		assets.set(Mods.all['assets'], []);
		recursiveSearch('assets', path ->
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

			if (assets[Mods.all['assets']].exists(key))
			{
				var i:Int = 1;
				while (assets[Mods.all['assets']].exists('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}'))
					i++;
				Log.warn('Asset \'$key\' already exists, renaming to \'${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}\' (${Mods.all['assets'].name})');
				trace('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}');
				assets[Mods.all['assets']].set('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}', path);
			}
			else
				assets[Mods.all['assets']].set(key, path);
		},
			path -> path.contains('songs') && HaxePath.extension(path) == 'ogg' && HaxePath.withoutDirectory(path) != 'menuSong.ogg');

		if (Main.verbose)
			Log.info('Assets Loaded');

		for (mod in Mods.enabled)
		{
			assets.set(mod, []);
			recursiveSearch(combine(['mods', mod.folderName]), path ->
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

				if (assets[mod].exists(key))
				{
					var i:Int = 1;
					while (assets[mod].exists('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}'))
						i++;
					Log.warn('Asset \'$key\' already exists, renaming to \'${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}\' (${mod.name})');
					assets[mod].set('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}', path);
				}
				else
					assets[mod].set(key, path);
			},
				path -> path.contains('songs') && HaxePath.extension(path) == 'ogg' && HaxePath.withoutDirectory(path) != 'menuSong.ogg');
		}

		if (Main.verbose && Mods.enabled.length > 0)
			Log.info('Assets Loaded for Mods ${[for (mod in Mods.enabled) mod.name].join(', ')}');
	}

	private static function recursiveSearch(path:String, callback:String->Void, ?exclude:String->Bool)
		if (FileSystem.isDirectory(path))
			for (entry in FileSystem.readDirectory(path))
			{
				var realPath = combine([path, entry]);
				if (FileSystem.isDirectory(realPath))
					recursiveSearch(realPath, callback, exclude);
				else
				{
					if (exclude != null)
					{
						if (!exclude(realPath))
							callback(realPath);
					}
					else
						callback(realPath);
				}
			}

	@:keep
	public static inline function combine(paths:Array<String>):String
		return HaxePath.removeTrailingSlashes(HaxePath.normalize(HaxePath.join(paths)));
}
