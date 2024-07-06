package util;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;

@:publicFields
class Create
{
	static function backdrop(path:FlxGraphicAsset, scale:Float = 1):FlxBackdrop
	{
		var bg:FlxBackdrop = new FlxBackdrop(path);
		bg.scale.set(scale, scale);
		bg.antialiasing = Settings.data.antialiasing;
		bg.updateHitbox();
		bg.centerOffsets(true);
		bg.screenCenter();
		return bg;
	}

	static function sparrow(x:Float, y:Float, frames:FlxAtlasFrames, scale:Float = 1):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.frames = frames;
		spr.scale.set(scale, scale);
		spr.antialiasing = Settings.data.antialiasing;
		spr.updateHitbox();
		spr.centerOffsets(true);
		return spr;
	}

	static function sprite(x:Float, y:Float, path:FlxGraphicAsset, scale:Float = 1):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.loadGraphic(path);
		spr.scale.set(scale, scale);
		spr.antialiasing = Settings.data.antialiasing;
		spr.updateHitbox();
		spr.centerOffsets(true);
		return spr;
	}

	static function graphic(x:Float, y:Float, width:Int, height:Int, color:FlxColor, scale:Float = 1):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.makeGraphic(width, height, color);
		spr.scale.set(scale, scale);
		spr.antialiasing = Settings.data.antialiasing;
		spr.updateHitbox();
		spr.centerOffsets(true);
		return spr;
	}

	static function camera():FlxCamera
	{
		var cam:FlxCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam, false);
		cam.bgColor = 0x00000000;
		return cam;
	}

	static function text(x:Float, y:Float, text:String, size:Int, font:String, color:FlxColor, alignment:FlxTextAlign):FlxText
		return new FlxText(x, y, 0, text, size).setFormat(font, size, color, alignment);
}
