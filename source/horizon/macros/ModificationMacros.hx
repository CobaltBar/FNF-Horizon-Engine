package horizon.macros;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

@:publicFields
class ModificationMacros
{
	// Based on Funkin's FlxMacro
	static function FlxBasic()
	{
		#if macro
		var fields = Context.getBuildFields();

		fields.push({
			name: "zIndex",
			pos: Context.currentPos(),
			access: [APublic],
			kind: FVar(macro :Int, macro $v{0}),
		});

		return fields;
		#end
	}

	static function FlxSprite()
	{
		#if macro
		var fields = Context.getBuildFields();

		var set_clipRect:Field = [for (field in fields) if (field.name == 'set_clipRect') field][0];
		switch (set_clipRect.kind)
		{
			case FFun(f):
				set_clipRect.kind = FFun({
					args: f.args,
					params: f.params,
					ret: f.ret,
					expr: macro
					{
						clipRect = rect;

						if (frames != null)
							frame = frames.frames[animation.frameIndex];

						return rect;
					}
				});
			default:
		}

		return fields;
		#end
	}

	static function LocaleManager()
	{
		#if macro
		var fields = Context.getBuildFields();

		var init:Field = [for (field in fields) if (field.name == 'init') field][0];
		switch (init.kind)
		{
			case FFun(f):
				init.kind = FFun({
					args: f.args,
					params: f.params,
					ret: f.ret,
					expr: macro
					{
						#if !haxeui_dont_detect_locale
						var autoDetectedLocale = Platform.instance.getSystemLocale();
						if (!_localeSet && autoSetLocale && autoDetectedLocale != null && hasLocale(autoDetectedLocale))
						{
							#if debug
							horizon.util.Log.info("System locale detected as: " + autoDetectedLocale, {
								methodName: 'init',
								lineNumber: 46,
								fileName: 'haxe.ui.locale.LocaleManager.hx',
								className: 'LocaleManager'
							});
							#end
							_language = autoDetectedLocale;
							applyLocale(_language);
						}
						#end
					}
				});
			default:
		}

		return fields;
		#end
	}
}
