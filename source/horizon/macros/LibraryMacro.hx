package horizon.macros;

class LibraryMacro
{
	public static macro function getLibVersion(lib:String):haxe.macro.Expr.ExprOf<String>
	{
		#if macro
		return macro $v{haxe.macro.Context.definedValue(lib.toLowerCase())};
		#end
	}
}
