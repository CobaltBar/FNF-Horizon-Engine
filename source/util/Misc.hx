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
}
