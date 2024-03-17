package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import haxe.io.Path as HaxePath;
import modding.Mod;
import modding.ModManager;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class Path
{
	static var assets:Map<String, String> = [];
	static var modAssets:Map<Mod, Map<String, String>> = [];

	@:keep
	public static inline function image(key:String, ?mod:Mod):String
	{
		if (mod != null && modAssets[mod].exists('$key.png'))
			return modAssets[mod].get('$key.png');
		if (assets.exists('$key.png'))
			return assets.get('$key.png');

		ErrorState.error(null, 'Image $key not found.');
		return null;
	}

	@:keep
	public static inline function sound(key:String, ?mod:Mod):String
	{
		if (mod != null && modAssets[mod].exists('$key.ogg'))
			return modAssets[mod].get('$key.ogg');
		if (assets.exists('$key.ogg'))
			return assets.get('$key.ogg');
		ErrorState.error(null, 'Sound $key not found.');
		return null;
	}

	@:keep
	public static inline function font(key:String, ?mod:Mod):String
	{
		if (mod != null && modAssets[mod].exists('$key.ttf'))
			return modAssets[mod].get('$key.ttf');
		if (assets.exists('$key.ttf'))
			return assets.get('$key.ttf');
		ErrorState.error(null, 'Font $key not found.');
		return null;
	}

	@:keep
	public static inline function json(key:String, ?mod:Mod):Dynamic
	{
		if (mod != null && modAssets[mod].exists('$key.json'))
			return TJSON.parse(File.getContent(modAssets[mod].get('$key.json')));
		if (assets.exists('$key.json'))
			return TJSON.parse(File.getContent(assets.get('$key.json')));
		ErrorState.error(null, 'JSON $key not found.');
		return null;
	}

	@:keep
	public static inline function xml(key:String, ?mod:Mod):String
	{
		if (mod != null && modAssets[mod].exists('$key.xml'))
			return modAssets[mod].get('$key.xml');
		if (assets.exists('$key.xml'))
			return assets.get('$key.xml');
		ErrorState.error(null, 'XML $key not found.');
		return null;
	}

	@:keep
	public static inline function txt(key:String, ?mod:Mod):String
	{
		if (mod != null && modAssets[mod].exists('$key.txt'))
			return File.getContent(modAssets[mod].get('$key.txt'));
		if (assets.exists('$key.txt'))
			return File.getContent(assets.get('$key.txt'));
		ErrorState.error(null, 'TXT $key not found.');
		return null;
	}

	@:keep
	public static function sparrow(key:String, ?mod:Mod):FlxAtlasFrames
	{
		if (mod != null)
		{
			if (modAssets[mod].exists('$key.png') && modAssets[mod].exists('$key.xml'))
				return FlxAtlasFrames.fromSparrow(modAssets[mod].get('$key.png'), modAssets[mod].get('$key.xml'));
			else
			{
				if (!modAssets[mod].exists('$key.png'))
					ErrorState.error(null, 'MOD SPARROW PNG $key not found.');
				if (!modAssets[mod].exists('$key.xml'))
					ErrorState.error(null, 'MOD SPARROW XML $key not found.');
			}
		}

		if (assets.exists('$key.png') && assets.exists('$key.xml'))
			return FlxAtlasFrames.fromSparrow(assets.get('$key.png'), assets.get('$key.xml'));
		else
		{
			if (!assets.exists('$key.png'))
				ErrorState.error(null, 'SPARROW PNG $key not found.');
			if (!assets.exists('$key.xml'))
				ErrorState.error(null, 'SPARROW XML $key not found.');
		}

		return null;
	}

	public static function loadAssets():Void
	{
		assets.clear();
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

	// Only I knew how this function worked
	// Now nobody knows.
	public static function reloadEnabledMods():Void
	{
		modAssets.clear();
		for (mod in ModManager.enabledMods)
			for (asset in FileSystem.readDirectory(mod.path))
				if (FileSystem.isDirectory(combine([mod.path, asset]))
					&& asset != "custom_events"
					&& asset != "custom_notetypes"
					&& asset != "menu_scripts"
					&& asset != "scripts"
					&& asset != "stages")
					for (asset2 in FileSystem.readDirectory(combine([mod.path, asset])))
						if (!FileSystem.isDirectory(combine([mod.path, asset, asset2])))
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

	private static function addAsset(key:String, path:String, ?mod:Mod):Void
		mod == null ? assets.set(assets.exists(key) ? '${HaxePath.withoutExtension(key)}-1${HaxePath.extension(key)}' : key,
			path) : modAssets[mod].set(modAssets[mod].exists(key) ? '${HaxePath.withoutExtension(key)}-1${HaxePath.extension(key)}' : key, path);

	@:keep
	public static inline function combine(paths:Array<String>):String
		return HaxePath.removeTrailingSlashes(HaxePath.normalize(HaxePath.join(paths)));
}
