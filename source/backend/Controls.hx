package backend;

@:publicFields
class Controls
{
	static var ui_left(get, null):Bool;
	static var ui_right(get, null):Bool;
	static var ui_up(get, null):Bool;
	static var ui_down(get, null):Bool;
	static var accept(get, null):Bool;
	static var back(get, null):Bool;
	static var pause(get, null):Bool;
	static var reset(get, null):Bool;

	@:noCompletion @:keep inline static function get_ui_left():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[0], Settings.data.keybinds.get('ui')[4]]);

	@:noCompletion @:keep inline static function get_ui_right():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[3], Settings.data.keybinds.get('ui')[7]]);

	@:noCompletion @:keep inline static function get_ui_up():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[2], Settings.data.keybinds.get('ui')[6]]);

	@:noCompletion @:keep inline static function get_ui_down():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[1], Settings.data.keybinds.get('ui')[5]]);

	@:noCompletion @:keep inline static function get_accept():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('accept'));

	@:noCompletion @:keep inline static function get_back():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('back'));

	@:noCompletion @:keep inline static function get_pause():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('pause'));

	@:noCompletion @:keep inline static function get_reset():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('reset'));
}
