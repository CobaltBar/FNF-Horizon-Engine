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
	static var debug(get, null):Bool;

	static var ui_left_released(get, null):Bool;
	static var ui_right_released(get, null):Bool;
	static var ui_up_released(get, null):Bool;
	static var ui_down_released(get, null):Bool;
	static var accept_released(get, null):Bool;
	static var back_released(get, null):Bool;
	static var pause_released(get, null):Bool;
	static var reset_released(get, null):Bool;
	static var debug_released(get, null):Bool;

	@:noCompletion @:keep inline static function get_ui_left():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[0], Settings.data.keybinds.get('ui')[4]]) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_ui_right():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[3], Settings.data.keybinds.get('ui')[7]]) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_ui_up():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[2], Settings.data.keybinds.get('ui')[6]]) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_ui_down():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[1], Settings.data.keybinds.get('ui')[5]]) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_accept():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('accept')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_back():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('back')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_pause():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('pause')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_reset():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('reset')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_debug():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('debug')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_ui_left_released():Bool
		return FlxG.keys.anyJustReleased([Settings.data.keybinds.get('ui')[0], Settings.data.keybinds.get('ui')[4]]) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_ui_right_released():Bool
		return FlxG.keys.anyJustReleased([Settings.data.keybinds.get('ui')[3], Settings.data.keybinds.get('ui')[7]]) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_ui_up_released():Bool
		return FlxG.keys.anyJustReleased([Settings.data.keybinds.get('ui')[2], Settings.data.keybinds.get('ui')[6]]) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_ui_down_released():Bool
		return FlxG.keys.anyJustReleased([Settings.data.keybinds.get('ui')[1], Settings.data.keybinds.get('ui')[5]]) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_accept_released():Bool
		return FlxG.keys.anyJustReleased(Settings.data.keybinds.get('accept')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_back_released():Bool
		return FlxG.keys.anyJustReleased(Settings.data.keybinds.get('back')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_pause_released():Bool
		return FlxG.keys.anyJustReleased(Settings.data.keybinds.get('pause')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_reset_released():Bool
		return FlxG.keys.anyJustReleased(Settings.data.keybinds.get('reset')) && Main.inputEnabled;

	@:noCompletion @:keep inline static function get_debug_released():Bool
		return FlxG.keys.anyJustReleased(Settings.data.keybinds.get('debug')) && Main.inputEnabled;
}
