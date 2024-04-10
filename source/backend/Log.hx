package backend;

import flash.utils.Function;
import haxe.PosInfos;

class Log
{
	// https://gist.github.com/martinwells/5980517
	// https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124
	private static final ansiColors:Map<String, String> = [
		'black' => '\033[;30m',
		'red' => '\033[;31m',
		'green' => '\033[;32m',
		'yellow' => '\033[;33m',
		'blue' => '\033[;34m',
		'purple' => '\033[;35m',
		'cyan' => '\033[;36m',
		'white' => '\033[;37m',
		'bold_black' => '\033[1;30m',
		'bold_red' => '\033[1;31m',
		'bold_green' => '\033[1;32m',
		'bold_yellow' => '\033[1;33m',
		'bold_blue' => '\033[1;34m',
		'bold_purple' => '\033[1;35m',
		'bold_cyan' => '\033[1;36m',
		'bold_white' => '\033[1;37m',
		'high_intensity_black' => '\033[;90m',
		'high_intensity_red' => '\033[;91m',
		'high_intensity_green' => '\033[;92m',
		'high_intensity_yellow' => '\033[;93m',
		'high_intensity_blue' => '\033[;94m',
		'high_intensity_purple' => '\033[;95m',
		'high_intensity_cyan' => '\033[;96m',
		'high_intensity_white' => '\033[;97m',
		'bold_high_intensity_black' => '\033[1;90m',
		'bold_high_intensity_red' => '\033[1;91m',
		'bold_high_intensity_green' => '\033[1;92m',
		'bold_high_intensity_yellow' => '\033[1;93m',
		'bold_high_intensity_blue' => '\033[1;94m',
		'bold_high_intensity_purple' => '\033[1;95m',
		'bold_high_intensity_cyan' => '\033[1;96m',
		'bold_high_intensity_white' => '\033[1;97m',
		'reset' => '\033[0m'
	];
	private static var ogTrace:Function;

	public static function init():Void
	{
		ogTrace = haxe.Log.trace;
		haxe.Log.trace = haxeTrace;
	}

	public static function error(value:Dynamic, ?pos:PosInfos)
		print(value, "high_intensity_red", "ERROR", false, pos);

	public static function warn(value:Dynamic, ?pos:PosInfos)
		print(value, "high_intensity_yellow", "WARN", true, pos);

	static function haxeTrace(value:Dynamic, ?pos:PosInfos)
		print(value, "high_intensity_cyan", "INFO", true, pos);

	static inline function print(value:Dynamic, color:String, word:String, space:Bool, ?pos:PosInfos)
		Sys.println('${ansiColors.get('purple')}[${ansiColors.get('yellow')}${DateTools.format(Date.now(), '%T')}${ansiColors.get('purple')}]${ansiColors.get('reset')}-${ansiColors.get('purple')}[${ansiColors.get(color)}${word}${ansiColors.get("purple")}] ${space ? ' ' : ''}[${ansiColors.get("bold_high_intensity_white")}${pos.fileName}:${pos.lineNumber}${ansiColors.get("purple")}]${ansiColors.get(color)}: $value${ansiColors.get("reset")}');
}
