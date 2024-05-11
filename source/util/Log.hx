package util;

import flash.utils.Function;
import haxe.PosInfos;

using StringTools;

enum abstract AnsiMode(Int)
{
	var RESET = 0;
	var BOLD = 1;
	var DIM = 2;
	var ITALIC = 3;
	var UNDERLINE = 4;
	var BLINKING = 5;
	var INVERT = 7;
	var INVISIBLE = 8;
	var STRIKETHROUGH = 9;
}

enum abstract AnsiColor(Int)
{
	var BLACK = 30;
	var RED = 31;
	var GREEN = 32;
	var YELLOW = 33;
	var BLUE = 34;
	var MAGENTA = 35;
	var CYAN = 36;
	var WHITE = 37;
	var HIGHINTENSITY_BLACK = 90;
	var HIGHINTENSITY_RED = 91;
	var HIGHINTENSITY_GREEN = 92;
	var HIGHINTENSITY_YELLOW = 93;
	var HIGHINTENSITY_BLUE = 94;
	var HIGHINTENSITY_MAGENTA = 95;
	var HIGHINTENSITY_CYAN = 96;
	var HIGHINTENSITY_WHITE = 97;
	var RESET = 0;
}

class Log
{
	// https://gist.github.com/martinwells/5980517
	// https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
	private static var ogTrace:Function;

	public static function init():Void
	{
		ogTrace = haxe.Log.trace;
		haxe.Log.trace = haxeTrace;
		if (Main.verboseLogging)
			info('Logger Initialized');
	}

	@:keep public static inline function ansiColor(mode:AnsiMode, color:AnsiColor):String
		return '\033[${mode};${color}m';

	static function haxeTrace(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'TRACE', BOLD, GREEN, pos);

	public static function error(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'ERROR', BOLD, RED, pos);

	public static function warn(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'WARN', BOLD, YELLOW, pos);

	public static function info(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'INFO', BOLD, CYAN, pos);

	static function print(value:Dynamic, level:String, mode:AnsiMode, color:AnsiColor, ?pos:PosInfos):Void
	{
		var msg:String = '${ansiColor(RESET, MAGENTA)}[${ansiColor(RESET, YELLOW)}${DateTools.format(Date.now(), '%H:%M:%S')}${ansiColor(RESET, MAGENTA)}]';
		if (pos != null)
			msg += '[${ansiColor(BOLD, WHITE)}${pos.fileName}:${pos.lineNumber}${ansiColor(RESET, MAGENTA)}]';
		msg += [for (i in 0...82 - msg.length) ' '].join('');
		msg += '[${ansiColor(mode, color)}${level}${ansiColor(RESET, MAGENTA)}]${ansiColor(mode, color)}:   ';
		msg += '${ansiColor(RESET, color)}$value${ansiColor(RESET, RESET)}';
		Sys.println(msg);
	}
}
