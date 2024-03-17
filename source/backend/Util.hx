package backend;

import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import haxe.ui.components.Label;

class Util
{
	public static function createBackdrop(path:String, scale:Float = 1, ?antiAliasing:Bool):FlxBackdrop
	{
		var bg:FlxBackdrop = new FlxBackdrop(path);
		bg.scale.set(scale, scale);
		bg.updateHitbox();
		bg.centerOffsets(true);
		bg.screenCenter();
		return bg;
	}

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

	public static function createCamera(main:Bool, ?transparent:Bool):FlxCamera
	{
		var cam:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam, main);
		cam.bgColor = (transparent ? 0x00000000 : 0xFF000000) ?? 0xFF000000;
		return cam;
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

	private static function sprCreate(x, y, scale:Float = 1, ?antiAliasing:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.antialiasing = antiAliasing ?? Settings.data.antialiasing;
		spr.scale.set(scale, scale);
		return spr;
	}
}
