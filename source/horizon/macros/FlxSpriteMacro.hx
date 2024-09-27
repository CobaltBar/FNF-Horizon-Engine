package horizon.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr.Field;
#end

// Adds Unrounds clipRect in FlxSprite
class FlxSpriteMacro
{
	public static function run()
	{
		#if macro
		var fields = Context.getBuildFields();

		var set_clipRect:Field = [for (field in fields) if (field.name == 'set_clipRect') field][0];
		switch (set_clipRect.kind)
		{
			case FFun(f):
				f.expr = macro
					{
						clipRect = rect;

						if (frames != null)
							frame = frames.frames[animation.frameIndex];

						return rect;
					}
			default:
		}

		return fields;
		#end
	}
}
