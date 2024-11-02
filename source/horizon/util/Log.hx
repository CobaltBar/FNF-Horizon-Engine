package horizon.util;

import flixel.system.debug.log.LogStyle;
import haxe.Constraints.Function;
import haxe.PosInfos;

// https://gist.github.com/martinwells/5980517
// https://gist.github.com/fnky/458719343aabd01cfb17a3a4f7296797
class Log
{
	static var ogTrace:Function;
	static var log:Array<String> = [];

	public static function init():Void
	{
		ogTrace = haxe.Log.trace;
		haxe.Log.trace = hxTrace;

		LogStyle.NORMAL.callback = (data) -> print(data, 'FLIXEL', 214);
		LogStyle.WARNING.callback = (data) ->
		{
			ErrorState.errs.push('FLIXEL WARN: $data');
			print(data, 'FLIXEL WARN', 214);
		}
		LogStyle.ERROR.callback = (data) ->
		{
			ErrorState.errs.push('FLIXEL ERROR: $data');
			print(data, 'FLIXEL ERROR', 196);
		}

		if (Constants.verbose)
			info('Logger Initialized');
	}

	@:keep static inline function ansi(color:Int):String
		return '\033[38;5;${color}m';

	static function hxTrace(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'TRACE', 47, pos);

	public static function error(value:Dynamic, ?pos:PosInfos):Void
	{
		ErrorState.errs.push('ERROR: $value');
		print(value, 'ERROR', 196, pos);
	}

	public static function warn(value:Dynamic, ?pos:PosInfos):Void
	{
		ErrorState.errs.push('WARN: $value');
		print(value, 'WARN', 220, pos);
	}

	public static function info(value:Dynamic, ?pos:PosInfos):Void
		print(value, 'INFO', 111, pos);

	@:noCompletion public static inline function print(value:Dynamic, level:String, color:Int, ?pos:PosInfos):Void
	{
		var msg = '${ansi(69)}[${ansi(39)}${DateTools.format(Date.now(), '%H:%M:%S')} ${ansi(178)}${pos.fileName.replace('source/', '').replace('horizon/', '')}:${pos.lineNumber}${ansi(69)}]';
		Sys.println(msg = '${msg.rpad(' ', 90)}${ansi(color)}$level: $value\033[0;0m');
		log.push('[${DateTools.format(Date.now(), '%H:%M:%S')} ${pos.fileName.replace('source/', '').replace('horizon/', '')}:${pos.lineNumber}] $level: $value');
	}
}
