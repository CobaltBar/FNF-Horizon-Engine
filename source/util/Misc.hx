package util;

import haxe.Exception;

@:publicFields
class Misc
{
	// Stolen from PsychEngine's CoolUtil
	@:keep static inline function openURL(site:String):Void #if linux Sys.command('/usr/bin/xdg-open', [site]); #else FlxG.openURL(site); #end

	static function error(desc:String, fatal:Bool = false, ?err:Exception)
	{
		Log.error(err == null ? desc : '$desc\n${err.details()}');
		if (fatal)
			FlxG.switchState(() -> new ErrorState());
	}

	// Stolen from BezierUtil.hx (FunkinCrew/Funkin)
	public static function quadBezier(p:Float, a:FlxPoint, b:FlxPoint, c:FlxPoint):FlxPoint
	{
		return FlxPoint.weak(mix3(p, a.x, b.x, c.x), mix3(p, a.y, b.y, c.y));
	}

	static inline function mix3(p:Float, a:Float, b:Float, c:Float):Float
	{
		return mix2(p, mix2(p, a, b), mix2(p, b, c));
	}

	static inline function mix2(p:Float, a:Float, b:Float):Float
	{
		return a * (1 - p) + (b * p);
	}
}
