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

	// TODO change to $b{expr {}, f.expr}
	static function LogFrontEnd()
	{
		#if macro
		var fields = Context.getBuildFields();

		var add:Field = [for (field in fields) if (field.name == 'add') field][0];
		switch (add.kind)
		{
			case FFun(f):
				add.kind = FFun({
					args: f.args,
					params: f.params,
					ret: f.ret,
					expr: macro
					{
						horizon.util.Log.print(data, 'FLIXEL WARN', 214, {
							methodName: 'add',
							lineNumber: 22,
							fileName: 'FlxG.Log/LogFrontEnd.hx',
							className: 'LogFrontEnd'
						});
						advanced(data, LogStyle.NORMAL);
					}
				});
			default:
		}

		var warn:Field = [for (field in fields) if (field.name == 'warn') field][0];
		switch (warn.kind)
		{
			case FFun(f):
				warn.kind = FFun({
					args: f.args,
					params: f.params,
					ret: f.ret,
					expr: macro
					{
						horizon.states.ErrorState.errs.push('FLIXEL WARN: $data');
						horizon.util.Log.print(data, 'FLIXEL WARN', 214, {
							methodName: 'warn',
							lineNumber: 28,
							fileName: 'FlxG.Log/LogFrontEnd.hx',
							className: 'LogFrontEnd'
						});
						advanced(data, LogStyle.WARNING, true);
					}
				});
			default:
		}

		var error:Field = [for (field in fields) if (field.name == 'error') field][0];
		switch (error.kind)
		{
			case FFun(f):
				error.kind = FFun({
					args: f.args,
					params: f.params,
					ret: f.ret,
					expr: macro
					{
						horizon.states.ErrorState.errs.push('FLIXEL ERROR: $data');
						horizon.util.Log.print(data, 'FLIXEL ERROR', 196, {
							methodName: 'error',
							lineNumber: 33,
							fileName: 'FlxG.Log/LogFrontEnd.hx',
							className: 'LogFrontEnd'
						});
						advanced(data, LogStyle.ERROR, true);
					}
				});
			default:
		}

		return fields;
		#end
	}
}
