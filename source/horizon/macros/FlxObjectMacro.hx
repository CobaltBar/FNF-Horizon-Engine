package horizon.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Function;
#end

// Adds angle getter to FlxObject
class FlxObjectMacro
{
	public static function run()
	{
		#if macro
		var fields = Context.getBuildFields();

		var angleGetter:Function = {expr: macro return angle, ret: (macro :Float), args: []}
		var angle:Field = [for (field in fields) if (field.name == 'angle') field][0];

		angle.kind = FProp("get", "set", angleGetter.ret);
		angle.meta.push({name: ":isVar", pos: Context.currentPos()});
		fields.push({
			name: "get_angle",
			kind: FFun(angleGetter),
			access: [APublic],
			meta: [{name: ":noCompletion", pos: Context.currentPos()}],
			pos: Context.currentPos()
		});

		return fields;
		#end
	}
}
