package util;

import haxe.macro.Expr;

class VersionMacro
{
	#if macro
	public static function run():Void
	{
		// ok wtf lime
		#if (!display_details && !display)
		if (sys.FileSystem.exists('.build'))
			sys.io.File.saveContent('.build', '${Std.parseInt(sys.io.File.getContent('.build')) + 1}');
		else
			sys.io.File.saveContent('.build', '0');
		#end
	}
	#end

	public static macro function getVersion():ExprOf<Int>
	{
		var ver = Std.parseInt(sys.io.File.getContent('.build'));

		return macro $v{ver};
	}
}
