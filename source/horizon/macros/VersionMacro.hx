package horizon.macros;

class VersionMacro
{
	public static macro function get():haxe.macro.Expr.ExprOf<String>
	{
		#if macro
		#if !display
		if (!sys.FileSystem.exists('.build'))
			return macro $v{'N/A'};
		else
			return macro $v{sys.io.File.getContent('.build')};
		#else
		return macro $v{""};
		#end
		#end
	}
}
