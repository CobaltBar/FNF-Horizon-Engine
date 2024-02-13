package backend;

import flixel.graphics.frames.FlxAtlasFrames;

class Util
{
	public static function createSparrowSprite(x:Float, y:Float, path:String, scale:Float = 1, ?antiAliasing:Bool):FlxSprite
	{
		var spr:FlxSprite = sprCreate(x, y, scale, antiAliasing);
		spr.frames = Path.sparrow(path);
		spr.updateHitbox();
		spr.centerOffsets(true);
		return spr;
	}

	public static function createGraphicSprite(x:Float, y:Float, path:String, scale:Float = 1, ?antiAliasing:Bool):FlxSprite
	{
		var spr:FlxSprite = sprCreate(x, y, scale, antiAliasing);
		spr.loadGraphic(path);
		spr.updateHitbox();
		spr.centerOffsets(true);
		return spr;
	}

	public static function makeSprite(x:Float, y:Float, width:Int, height:Int, color:FlxColor, scale:Float = 1, ?antiAliasing:Bool):FlxSprite
	{
		var spr:FlxSprite = sprCreate(x, y, scale, antiAliasing);
		spr.makeGraphic(width, height, color);
		spr.updateHitbox();
		spr.centerOffsets(true);
		return spr;
	}

	public static function createCamera(?transparent:Bool):FlxCamera
	{
		var cam:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam);
		cam.bgColor = (transparent ? 0x00000000 : 0xFF000000) ?? 0xFF000000;
		return cam;
	}

	public static function createIcon(x:Float, y:Float, path:String, winning:Bool = false, scale:Float = 1, ?antiAliasing:Bool):FlxSprite
	{
		var icon:FlxSprite = sprCreate(x, y, scale, antiAliasing);
		icon.loadGraphic(path, false, cast 450 / (winning ? 3 : 2), 150); // what is haxe yapping about, none of this is a float
		icon.updateHitbox();
		icon.centerOffsets(true);
		return icon;
	}

	public static function createText(x:Float, y:Float, text:String, size:Int, font:String, color:FlxColor, alignment:FlxTextAlign):FlxText
		return new FlxText(x, y, 0, text, size).setFormat(font, size, color, alignment);

	public static inline function browserLoad(site:String):Void // yoinked from PsychEngine's CoolUtil
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function error(error:String)
	{
		trace(error);
		ErrorState.errorText = error;
		MusicState.switchState(new ErrorState());
	}

	private static function sprCreate(x, y, scale:Float = 1, ?antiAliasing:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.antialiasing = antiAliasing ?? Settings.data.antialiasing;
		spr.scale.set(scale, scale);
		return spr;
	}
}
