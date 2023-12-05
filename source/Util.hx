package;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class Util
{
	public static function createSparrowSprite(x:Float = 0, y:Float = 0, path:String, ?antiAliasing:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.antialiasing = (antiAliasing == null) ? Settings.data.antialiasing : antiAliasing;
		spr.frames = FlxAtlasFrames.fromSparrow(path + ".png", path + ".xml");
		spr.updateHitbox();
		spr.centerOffsets();
		return spr;
	}

	public static function createSprite(x:Float = 0, y:Float = 0, path:String, ?antiAliasing:Bool):FlxSprite
	{
		var spr:FlxSprite = new FlxSprite(x, y);
		spr.antialiasing = (antiAliasing == null) ? Settings.data.antialiasing : antiAliasing;
		spr.loadGraphic(path);
		spr.updateHitbox();
		spr.centerOffsets();
		return spr;
	}

	public static function scale(spr:FlxSprite, xFac:Float, ?yFac:Float):Void
	{
		spr.scale.x = xFac;
		spr.scale.y = (yFac == null) ? xFac : yFac;
		spr.updateHitbox();
		spr.centerOffsets(true);
	}
}
