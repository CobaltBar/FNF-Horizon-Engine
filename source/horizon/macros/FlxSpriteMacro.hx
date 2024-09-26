package horizon.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Field;
import haxe.macro.Expr.Function;
#end

// Adds Unrounds clipRect in FlxSprite
class FlxSpriteMacro
{
	public static function run()
	{
		#if macro
		var fields = Context.getBuildFields();

		var set_clipRect:Field = [for (field in fields) if (field.name == 'set_clipRect') field][0];
		set_clipRect.kind = FFun({
			args: [
				{
					name: "rect",
					opt: false,
					meta: [],
					type: TPath({name: "FlxRect", params: [], pack: []})
				}
			],
			ret: (macro :FlxRect),
			expr: macro
			{
				clipRect = rect;

				if (frames != null)
					frame = frames.frames[animation.frameIndex];

				return rect;
			}
		});

		return fields;
		#end
	}
}
