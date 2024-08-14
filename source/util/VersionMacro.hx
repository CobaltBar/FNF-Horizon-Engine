package util;

import haxe.macro.Expr;

class VersionMacro
{
	// I think there might be a bug with this number increasing
	#if (macro && !display_details && !display)
	public static function run():Void
	{
		if (sys.FileSystem.exists('.build'))
			sys.io.File.saveContent('.build', '${Std.parseInt(sys.io.File.getContent('.build')) + 1}');
		else
			sys.io.File.saveContent('.build', '0');
	}
	#end

	public static macro function getVersion():ExprOf<Int>
	{
		var ver = Std.parseInt(sys.io.File.getContent('.build'));

		return macro $v{ver};
	}
}
