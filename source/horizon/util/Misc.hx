package horizon.util;

import haxe.Exception;

@:publicFields
class Misc
{
	// Stolen from PsychEngine's CoolUtil
	@:keep static inline function openURL(site:String):Void #if linux Sys.command('/usr/bin/xdg-open', [site]); #else FlxG.openURL(site); #end

	static inline function error(desc:String, fatal:Bool = false, ?err:Exception):Void
	{
		Log.error(err == null ? desc : '$desc\n${err.details()}');
		if (fatal)
			FlxG.switchState(() -> new ErrorState());
	}

	@:keep static inline function quadBezier(a:FlxPoint, b:FlxPoint, c:FlxPoint, p:Float):FlxPoint
		return FlxPoint.weak(FlxMath.lerp(FlxMath.lerp(a.x, b.x, p), FlxMath.lerp(b.x, c.x, p), p),
			FlxMath.lerp(FlxMath.lerp(a.y, b.y, p), FlxMath.lerp(b.y, c.y, p), p));
}
