package util;

import haxe.Constraints.Function;
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
	private static var log:String = "";

	public static function init():Void
	{
		ogTrace = haxe.Log.trace;
		haxe.Log.trace = haxeTrace;
		if (Main.verboseLogging)
			info('Logger Initialized');
	}

	@:keep public static inline function ansi(mode:AnsiMode, color:AnsiColor):String
		return '\033[${mode};${color}m';

	@:keep static inline function haxeTrace(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'TRACE', BOLD, GREEN, pos);

	@:keep public static inline function error(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'ERROR', BOLD, RED, pos);

	@:keep public static inline function warn(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'WARN', BOLD, YELLOW, pos);

	@:keep public static inline function info(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'INFO', BOLD, MAGENTA, pos);

	@:keep static inline function print(value:Dynamic, level:String, mode:AnsiMode, color:AnsiColor, ?pos:PosInfos):Void
	{
		var msg:String = '${ansi(RESET, HIGHINTENSITY_BLUE)}[${ansi(RESET, YELLOW)}${DateTools.format(Date.now(), '%H:%M:%S')}';
		if (pos != null)
			msg += '${ansi(RESET, HIGHINTENSITY_BLUE)} - ${ansi(RESET, HIGHINTENSITY_CYAN)}${pos.fileName}:${pos.lineNumber}';
		msg += '${ansi(RESET, HIGHINTENSITY_BLUE)}]';
		msg = (msg.rpad(' ', 80) + '${ansi(mode, color)}${level}: ').rpad(' ', 95) + '${ansi(RESET, color)}$value${ansi(RESET, RESET)}';
		Sys.println(msg);

		var logMsg:String = '[${DateTools.format(Date.now(), '%H:%M:%S')}';
		if (pos != null)
			logMsg += ' - ${pos.fileName}:${pos.lineNumber}';
		logMsg += '] ${level}: $value\n';
		log += logMsg;
	}
}
