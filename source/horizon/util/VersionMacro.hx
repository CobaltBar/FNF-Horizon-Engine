package horizon.util;

import haxe.macro.Expr.ExprOf;
import sys.FileSystem;
import sys.io.File;

class VersionMacro
{
	public static macro function get():ExprOf<String>
	{
		#if macro
		if (!FileSystem.exists('.build'))
			return macro $v{'N/A'};
		else
			return macro $v{File.getContent('.build')};
		#end
	}
}
