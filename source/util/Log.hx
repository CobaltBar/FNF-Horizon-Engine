package util;

import haxe.Constraints.Function;
import haxe.PosInfos;
import lime.app.Application;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;

using StringTools;

class Log
{
	// https://gist.github.com/martinwells/5980517
	// https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
	public static var format(default, set):String = '';

	private static var ogTrace:Function;
	private static var logFileOutput:FileOutput;
	private static var preformatted:String = '\033[38;5;63m[\033[38;5;39mTIME \033[38;5;178mFILE\033[38;5;63m] LEVEL: MSG\033[0;0m';

	private static var log:Array<String> = [];

	public static function init():Void
	{
		ogTrace = haxe.Log.trace;
		haxe.Log.trace = hxTrace;
		format = '[TIME FILE] LEVEL: MSG';

		if (Main.verbose)
			info('Logger Initialized');
	}

	@:keep static inline function ansi(color:Int):String
		return '\033[38;5;${color}m';

	static function hxTrace(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'TRACE', 49, pos);

	public static function error(value:Dynamic, ?pos:PosInfos):Void
	{
		ErrorState.errs.push('ERROR: $value');
		print(value, 'ERROR', 160, pos);
	}

	public static function warn(value:Dynamic, ?pos:PosInfos):Void
	{
		ErrorState.errs.push('WARN: $value');
		print(value, 'WARN', 221, pos);
	}

	public static function info(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'INFO', 111, pos);

	static inline function print(value:Dynamic, level:String, color:Int, ?pos:PosInfos):Void
	{
		var msg = preformatted.replace('TIME', DateTools.format(Date.now(), '%H:%M:%S')).replace('FILE', '${pos.fileName}:${pos.lineNumber}');
		msg = msg.replace('LEVEL:', '${[for (i in 0...FlxMath.absInt(105 - msg.length)) ' '].join('')}${ansi(color)}${(level + ':').rpad(' ', 6)}')
			.replace('MSG', value);
		Sys.println(msg);

		log.push('${format.replace('TIME', DateTools.format(Date.now(), '%H:%M:%S')).replace('FILE', '${pos.fileName}:${pos.lineNumber}').replace('LEVEL', level).replace('MSG', value)}');
	}

	@:keep static inline function set_format(val:String):String
	{
		preformatted = val.replace('[', '${ansi(63)}[')
			.replace(']', '${ansi(63)}]')
			.replace('TIME', '${ansi(39)}TIME')
			.replace('FILE', '${ansi(178)}FILE')
			.replace('MSG', 'MSG\033[0;0m');
		return format = val;
	}
}
