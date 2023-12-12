package objects;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class Util
{
	public static function createSparrowSprite(x:Float = 0, y:Float = 0, path:String, ?antiAliasing:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.antialiasing = Settings.data.antialiasing ?? antiAliasing;
		spr.frames = FlxAtlasFrames.fromSparrow(path + ".png", path + ".xml");
		spr.updateHitbox();
		spr.centerOffsets();
		return spr;
	}

	public static function createSprite(x:Float = 0, y:Float = 0, path:String, ?antiAliasing:Bool = true):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.antialiasing = (Settings.data.antialiasing ? antiAliasing : false);
		spr.loadGraphic(path);
		spr.updateHitbox();
		spr.centerOffsets();
		return spr;
	}

	public static function scale(spr:FlxSprite, xFac:Float, ?yFac:Float):Void
	{
		spr.scale.x = xFac;
		spr.scale.y = yFac ?? xFac;
		spr.updateHitbox();
		spr.centerOffsets(true);
	}

	public static function createCamera(?transparent:Bool):FlxCamera
	{
		var cam:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam);
		cam.bgColor = (transparent ? 0x00000000 : 0xFF000000) ?? 0xFF000000;
		return cam;
	}

	public static function createText(x:Float, y:Float, text:String, size:Int, font:String, color:FlxColor, alignment:FlxTextAlign):FlxText
	{
		return new FlxText(x, y, 0, text, size).setFormat(font, size, color, alignment);
	}

	public static inline function browserLoad(site:String) // yoinked from PsychEngine's CoolUtil
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}
}
