package horizon.backend;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;
import flxanimate.frames.FlxAnimateFrames;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.media.Sound;
import openfl.system.System;

@:structInit
@:publicFields
private class PathInfo
{
	var path:String;
	@:optional var mod:Mod;
}

// Based off of PsychEngine's Paths.hx
@:publicFields class Path
{
	private static var assets:Map<Mod, Map<String, String>> = [];

	private static var localAssets:Array<String> = [];
	private static var trackedImages:Map<String, FlxGraphic> = [];
	private static var trackedAudio:Map<String, Sound> = [];

	private static var exclusions:Array<String> = [];
	private static var modSearch:Array<Mod> = [Mods.assets];

	static function init():Void
	{
		for (key in ['gettinFreaky.ogg', 'cancel.ogg', 'confirm.ogg', 'scroll.ogg'])
			addExclusion(key);
		FlxG.signals.preStateCreate.add(state -> modSearch = Mods.enabled.concat([Mods.assets]));
	}

	static function clearUnusedMemory():Void
	{
		for (key in trackedImages.keys())
			if (!localAssets.contains(key) && !exclusions.contains(key))
			{
				destroyGraphic(trackedImages[key]);
				trackedImages.remove(key);
			}
		System.gc();
	}

	static function clearStoredMemory():Void @:privateAccess {
		for (key in FlxG.bitmap._cache.keys())
			if (!trackedImages.exists(key) && !exclusions.contains(key))
				destroyGraphic(FlxG.bitmap.get(key));

		for (key in trackedAudio.keys())
			if (!localAssets.contains(key) && !exclusions.contains(key))
			{
				Assets.cache.clear(key);
				trackedAudio.remove(key);
			}

		localAssets = [];
	}

	static function addExclusion(key:String):Void
	{
		var modPath = find(PathUtil.withoutExtension(key), [PathUtil.extension(key)]).mod.path;
		switch (PathUtil.extension(key))
		{
			case 'png':
				exclusions.push('IMAGE-$modPath-${PathUtil.withoutExtension(key)}');
			case 'ogg':
				exclusions.push('AUDIO-$modPath-${PathUtil.withoutExtension(key)}');
			case 'ttf' | 'otf':
				exclusions.push('FONT-$modPath-${PathUtil.withoutExtension(key)}');
		}
	}

	static function find(key:String, exts:Array<String>, ?mods:Array<Mod>, mustFind:Bool = false):PathInfo
	{
		if (mods != null)
			mods.push(Mods.assets);
		for (ext in exts)
		{
			for (mod in (mods == null ? modSearch : mods))
				if (assets.exists(mod) && assets[mod].exists('$key.$ext'))
					return {path: assets[mod]['$key.$ext'], mod: mod};
			Log.warn('Asset \'$key.$ext\' not found.');
		}
		return null;
	}

	static function cacheImage(key:String, ?mods:Array<Mod>, path:Bool = false):FlxGraphic
	{
		var found = path ? {path: key, mod: Mods.assets} : find(key, ['png'], mods);
		var bitmap = BitmapData.fromFile(found?.path) ?? FlxAssets.getBitmapData('flixel/images/logo/default.png');
		var cacheKey = 'IMAGE-${(found?.mod ?? Mods.assets).folder}-$key';

		if (Settings.gpuTextures)
		{
			bitmap.disposeImage();
			@:privateAccess bitmap.readable = true;
		}

		var graphic = FlxGraphic.fromBitmapData(bitmap, false, cacheKey);
		graphic.persist = true;
		graphic.destroyOnNoUse = false;

		trackedImages.set(cacheKey, graphic);
		localAssets.push(cacheKey);
		if (found != null)
			Log.info('Caching image \'$key\' (${path ? 'Path' : found?.mod?.name ?? 'Unknown'})');

		return graphic;
	}

	static function image(key:String, ?mods:Array<Mod>):FlxGraphic
	{
		if (mods != null)
			mods.push(Mods.assets);
		for (mod in (mods == null ? modSearch : mods))
		{
			var cacheKey = 'IMAGE-${mod.folder}-$key';
			if (trackedImages.exists(cacheKey))
			{
				localAssets.push(cacheKey);
				return trackedImages[cacheKey];
			}
		}

		return cacheImage(key, mods);
	}

	static function audio(key:String, ?mods:Array<Mod>):Sound
	{
		if (mods != null)
			mods.push(Mods.assets);
		for (mod in (mods == null ? modSearch : mods))
		{
			var cacheKey = 'AUDIO-${mod.folder}-$key';
			if (trackedAudio.exists(cacheKey))
			{
				localAssets.push(cacheKey);
				return trackedAudio[cacheKey];
			}
		}

		var found = find(key, ['ogg'], mods);

		if (found == null)
		{
			Log.warn('Audio \'$key\' not found. Playing beep');
			return FlxAssets.getSound('flixel/sounds/beep');
		}

		var cacheKey = 'AUDIO-${found.mod.path}-$key';
		trackedAudio.set(cacheKey, Sound.fromFile(found.path));
		localAssets.push(cacheKey);
		return trackedAudio[cacheKey];
	}

	@:keep static inline function font(key:String, ?mods:Array<Mod>):String
		return find(key, ['ttf', 'otf'], mods).path;

	@:keep static inline function json(key:String, ?mods:Array<Mod>):Dynamic
		return TJSON.parse(File.getContent(find(key, ['json'], mods).path ?? ''));

	@:keep static inline function xml(key:String, ?mods:Array<Mod>):String
		return find(key, ['xml'], mods, true).path;

	@:keep static inline function txt(key:String, ?mods:Array<Mod>):String
		return File.getContent(find(key, ['txt'], mods).path ?? '');

	static function atlas(key:String, ?mods:Array<Mod>):FlxAtlasFrames
	{
		var xmlPath = xml(key, mods);
		if (xmlPath != null)
			return FlxAnimateFrames.fromSparrow(xmlPath, image(key, mods));

		var txtPath = txt(key, mods);
		if (txtPath != null)
			return FlxAtlasFrames.fromSpriteSheetPacker(image(key, mods), txtPath);

		var jsonPath = json(key, mods);
		if (jsonPath != null)
			return FlxAtlasFrames.fromAseprite(image(key, mods), jsonPath);

		return null;
	}

	static inline function songJSON(song:String, difficulty:String, ?mods:Array<Mod>):Dynamic
		return TJSON.parse(File.getContent(find('SONG-$song-$difficulty', ['json'], mods).path ?? ''));

	static function loadAssets():Void
	{
		assets.clear();
		loadAssetsFromPath(Mods.assets);

		if (Constants.verbose)
			Log.info('Assets Loaded');

		for (mod in Mods.enabled)
			loadAssetsFromPath(mod);

		if (Constants.verbose && Mods.enabled.length > 0)
			Log.info('Assets Loaded for Mods \'${[for (mod in Mods.enabled) mod.name].join("', '")}\'');
	}

	private static inline function loadAssetsFromPath(mod:Mod):Void
	{
		assets.set(mod, []);

		recurse(mod.path, path ->
		{
			var key = PathUtil.withoutDirectory(path);

			if (PathUtil.extension(key) == 'json' && path.contains('songs'))
				key = 'SONG-${PathUtil.withoutDirectory(PathUtil.directory(path))}-$key';

			if (assets[mod].exists(key))
			{
				var i = 1;
				var newKey = '${PathUtil.withoutExtension(key)}-$i.${PathUtil.extension(key)}';

				while (assets[mod].exists(newKey))
				{
					i++;
					newKey = '${PathUtil.withoutExtension(key)} -$i.${PathUtil.extension(key)}';
				}

				Log.warn('Asset \'$key\' already exists, renaming to \'$newKey\' (${mod.name})');
				assets[mod].set(newKey, path);
			}
			else
				assets[mod].set(key, path);
		},
			path -> path.contains('songs') && PathUtil.extension(path) == 'ogg' && PathUtil.withoutDirectory(path) != 'gettinFreaky.ogg');
	}

	private static inline function destroyGraphic(graphic:FlxGraphic)
	{
		@:privateAccess if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

	private static function recurse(path:String, callback:String->Void, ?exclude:String->Bool)
		if (FileSystem.isDirectory(path))
			for (entry in FileSystem.readDirectory(path))
			{
				var realPath = PathUtil.combine(path, entry);
				if (FileSystem.isDirectory(realPath))
					recurse(realPath, callback, exclude);
				else if (exclude != null)
				{
					if (!exclude(realPath))
						callback(realPath);
				}
				else
					callback(realPath);
			}
}
