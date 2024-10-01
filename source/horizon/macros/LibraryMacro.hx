package horizon.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.io.Process;
#end

class LibraryMacro
{
	public static macro function getLibVersion(lib:String):ExprOf<String>
	{
		#if macro
		#if !display
		var proc = new Process('haxelib libpath $lib');
		if (proc.exitCode() == 0)
		{
			var ver = proc.stdout.readAll().toString().trim();
			if (ver.indexOf('git') != -1)
			{
				var commitProc = new Process('git -C $ver rev-parse --short=8 HEAD');
				if (commitProc.exitCode() == 0)
					return macro $v{'${Context.definedValue(lib)}@${commitProc.stdout.readAll().toString().trim()}'};

				commitProc.close();
			}
		}
		proc.close();

		return macro $v{Context.definedValue(lib)};
		#else
		return macro $v{""};
		#end
		#end
	}
}
