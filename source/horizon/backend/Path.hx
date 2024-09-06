package horizon.backend;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.system.System;

// Based off of PsychEngine's Paths.hx

@:publicFields
class Path
{
	private static var assets:Map<Mod, Map<String, String>> = [];

	private static var localAssets:Array<String> = [];
	private static var trackedImages:Map<String, FlxGraphic> = [];
	private static var trackedSounds:Map<String, Sound> = [];

	private static var exclusions:Array<String> = ["AUDIO-menuSong.ogg"];

	static function clearUnusedMemory():Void
	{
		for (key in trackedImages.keys())
			if (!localAssets.contains('IMAGE-$key') && !exclusions.contains('IMAGE-$key') && trackedImages.get('IMAGE-$key') != null)
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

	static function clearStoredMemory():Void @:privateAccess {
		for (key in FlxG.bitmap._cache.keys())
		{
			if (FlxG.bitmap._cache.get(key) == null || exclusions.contains('IMAGE-$key'))
				continue;
			if (!trackedImages.exists(key))
			{
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				FlxG.bitmap._cache[key].destroy();
			}
		}

		for (key in trackedSounds.keys())
			if (!localAssets.contains(key) && !exclusions.contains('AUDIO-$key'))
			{
				Assets.cache.clear(key);
				trackedSounds.remove(key);
			}
		// Thanks Sword
		for (key in cast(openfl.utils.Assets.cache, openfl.utils.AssetCache).font.keys())
			cast(openfl.utils.Assets.cache, openfl.utils.AssetCache).font.remove(key);
		localAssets = [];
	}

	static function addClearExclusion(key:String):Void
	{
		switch (HaxePath.extension(key))
		{
			case 'png':
				key = 'IMAGE-$key';
			case 'xml':
				key = 'XML-$key';
			case 'json':
				if (!key.startsWith('SONG-'))
					key = 'JSON-$key';
			case 'ogg':
				key = 'AUDIO-$key';
			case 'ttf' | 'otf':
				key = 'FONT-$key';
			case 'lua' | 'hx':
				key = 'SCRIPT-$key';
			case 'txt':
				key = 'TXT-$key';
		}

		exclusions.push(key);
	}

	static function find(key:String, exts:Array<String>, ?mods:Array<Mod>, mustFind:Bool = false):PathInfo
	{
		for (ext in exts)
		{
			for (mod in (mods ?? []).concat([Mods.assets]))
				if (assets.exists(mod) && assets[mod].exists('$key.$ext'))
					return {path: assets[mod].get('$key.$ext'), mod: mod};
			Log.warn('Asset \'$key.$ext\' not found.');
		}
		return null;
	}

	static function cacheBitmap(key:String, ?mods:Array<Mod>, keyAsPath:Bool = false):FlxGraphic
	{
		var found:PathInfo = keyAsPath ? {path: key} : find('IMAGE-$key', ['png'], mods, false);
		var realKey = found?.mod != null ? '${HaxePath.withoutDirectory(found.mod.path)}-$key' : key;
		var graphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(found.path) ?? FlxAssets.getBitmapData('flixel/images/logo/default.png'), false, realKey);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;
		trackedImages.set(realKey, graphic);
		localAssets.push(realKey);
		Log.info('Caching image \'$key\' (${found.mod != null ? found.mod.name : 'Path'})');
		return graphic;
	}

	static function image(key:String, ?mods:Array<Mod>):FlxGraphic
	{
		for (mod in (mods ?? []).concat([Mods.assets]))
			if (trackedImages.exists('${HaxePath.withoutDirectory(mod.path)}-$key'))
			{
				localAssets.push('${HaxePath.withoutDirectory(mod.path)}-$key');
				return trackedImages.get('${HaxePath.withoutDirectory(mod.path)}-$key');
			}

		return cacheBitmap(key, mods);
	}

	static function audio(key:String, ?mods:Array<Mod>):Sound
	{
		for (mod in (mods ?? []).concat([Mods.assets]))
			if (trackedSounds.exists('${HaxePath.withoutDirectory(mod.path)}-$key'))
			{
				localAssets.push('${HaxePath.withoutDirectory(mod.path)}-$key');
				return trackedSounds.get('${HaxePath.withoutDirectory(mod.path)}-$key');
			}

		var found:PathInfo = find('AUDIO-$key', ['ogg'], mods);
		var realKey = found?.mod != null ? '${HaxePath.withoutDirectory(found.mod.path)}-$key' : key;

		if (found == null)
		{
			Log.warn('Audio \'$key\' not found. Playing beep');
			return FlxAssets.getSound('flixel/sounds/beep');
		}
		else
		{
			Log.info('Loading sound \'$key\' (${found.mod != null ? found.mod.name : 'Path'})');
			trackedSounds.set(realKey, Sound.fromFile(found.path));
		}

		localAssets.push(realKey);
		return trackedSounds.get(realKey);
	}

	@:keep
	static inline function font(key:String, ?mods:Array<Mod>):Null<String>
		return find('FONT-$key', ['ttf', 'otf'], mods).path;

	@:keep
	static inline function json(key:String, ?mods:Array<Mod>):Dynamic
		return TJSON.parse(File.getContent(find('JSON-$key', ['json'], mods).path ?? ''));

	@:keep
	static inline function xml(key:String, ?mods:Array<Mod>):Null<String>
		return find('XML-$key', ['xml'], mods, true).path;

	@:keep
	static inline function txt(key:String, ?mods:Array<Mod>):Null<String>
		return File.getContent(find('TXT-$key', ['txt'], mods).path ?? '');

	@:keep
	static inline function sparrow(key:String, ?mods:Array<Mod>):FlxAtlasFrames
		return FlxAtlasFrames.fromSparrow(image(key, mods), xml(key, mods));

	@:keep
	static inline function songJSON(key:String, ?mods:Array<Mod>):Dynamic
		return TJSON.parse(File.getContent(find('SONG-$key', ['json'], mods).path ?? ''));

	static function loadAssets():Void
	{
		assets.clear();

		assets.set(Mods.assets, []);
		recursiveSearch('assets', path ->
		{
			var key = HaxePath.withoutDirectory(path);

			switch (HaxePath.extension(key))
			{
				case 'png':
					key = 'IMAGE-$key';
				case 'xml':
					key = 'XML-$key';
				case 'json':
					if (path.contains('songs')) key = 'SONG-${HaxePath.withoutDirectory(HaxePath.directory(path))}-$key'; else key = 'JSON-$key';
				case 'ogg':
					key = 'AUDIO-$key';
				case 'ttf' | 'otf':
					key = 'FONT-$key';
				case 'lua' | 'hx':
					key = 'SCRIPT-$key';
				case 'txt':
					key = 'TXT-$key';
			}

			if (assets[Mods.assets].exists(key))
			{
				var i:Int = 1;
				while (assets[Mods.assets].exists('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}'))
					i++;
				Log.warn('Asset \'$key\' already exists, renaming to \'${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}\' (${Mods.assets.name})');
				trace('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}');
				assets[Mods.assets].set('${HaxePath.withoutExtension(key)}-$i.${HaxePath.extension(key)}', path);
			}
			else
				assets[Mods.assets].set(key, path);
		},
			path -> path.contains('songs') && HaxePath.extension(path) == 'ogg' && HaxePath.withoutDirectory(path) != 'menuSong.ogg');

		if (Main.verbose)
			Log.info('Assets Loaded');

		for (mod in Mods.enabled)
		{
			assets.set(mod, []);
			recursiveSearch(mod.path, path ->
			{
				var key = HaxePath.withoutDirectory(path);

				switch (HaxePath.extension(key))
				{
					case 'png':
						key = 'IMAGE-$key';
					case 'xml':
						key = 'XML-$key';
					case 'json':
						if (path.contains('songs')) key = 'SONG-${HaxePath.withoutDirectory(HaxePath.directory(path))}-$key'; else key = 'JSON-$key';
					case 'ogg':
						key = 'AUDIO-$key';
					case 'ttf' | 'otf':
						key = 'FONT-$key';
					case 'lua' | 'hx':
						key = 'SCRIPT-$key';
					case 'txt':
						key = 'TXT-$key';
				}

				if (assets[mod].exists(key))
				{
					var i = 1;
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
		else
			callback(path);

	@:keep
	static inline function combine(paths:Array<String>):String
		return HaxePath.normalize(HaxePath.join(paths));
}

@:structInit
@:publicFields
class PathInfo
{
	var path:String;
	@:optional var mod:Mod;
}
