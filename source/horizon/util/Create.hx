package horizon.util;

import flixel.addons.display.FlxBackdrop;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;

@:publicFields
class Create
{
	static function backdrop(path:FlxGraphicAsset, ?cameras:Array<FlxCamera>, scale:Float = 1):FlxBackdrop
	{
		var bg = new FlxBackdrop(path);
		bg.scale.set(scale, scale);
		bg.updateHitbox();
		bg.screenCenter();
		if (cameras != null)
			bg.cameras = cameras;
		return bg;
	}

	static function atlas(x:Float, y:Float, frames:FlxAtlasFrames, ?cameras:Array<FlxCamera>, scale:Float = 1):FlxSprite
	{
		var spr = new FlxSprite(x, y);
		spr.frames = frames;
		spr.scale.set(scale, scale);
		spr.updateHitbox();
		if (cameras != null)
			spr.cameras = cameras;
		return spr;
	}

	static function sprite(x:Float, y:Float, path:FlxGraphicAsset, ?cameras:Array<FlxCamera>, scale:Float = 1):FlxSprite
	{
		var spr = new FlxSprite(x, y);
		spr.loadGraphic(path);
		spr.scale.set(scale, scale);
		spr.updateHitbox();
		if (cameras != null)
			spr.cameras = cameras;
		return spr;
	}

	static function graphic(x:Float, y:Float, width:Int, height:Int, color:FlxColor, ?cameras:Array<FlxCamera>, scale:Float = 1):FlxSprite
	{
		var spr = new FlxSprite(x, y);
		spr.makeGraphic(width, height, color);
		spr.scale.set(scale, scale);
		spr.updateHitbox();
		if (cameras != null)
			spr.cameras = cameras;
		return spr;
	}

	static function camera():FlxCamera
	{
		var cam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(cam, false);
		cam.bgColor = 0x00000000;
		return cam;
	}

	static function text(x:Float, y:Float, text:String, size:Int, font:String, color:FlxColor, alignment:FlxTextAlign, ?cameras:Array<FlxCamera>):FlxText
	{
		var text = new FlxText(x, y, 0, text, size);
		if (cameras != null)
			text.cameras = cameras;
		return text.setFormat(font, size, color, alignment);
	}
}
