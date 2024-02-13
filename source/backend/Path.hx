package backend;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.sound.FlxSound;
import haxe.io.Path as HaxePath;
import modding.ModManager;
import sys.FileSystem;
import sys.io.File;
import tjson.TJSON;

class Path
{
	

	public static inline function combine(paths:Array<String>):String
		return HaxePath.removeTrailingSlashes(HaxePath.normalize(HaxePath.join(paths)));
}
