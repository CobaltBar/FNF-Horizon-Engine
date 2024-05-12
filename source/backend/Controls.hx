package backend;

@:publicFields
class Controls
{
	static var accept(get, null):Bool;
	static var back(get, null):Bool;
	static var ui_up(get, null):Bool;
	static var ui_down(get, null):Bool;

	@:noCompletion inline static function get_accept():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('accept'));

	@:noCompletion inline static function get_back():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('back'));

	@:noCompletion inline static function get_ui_up():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[2], Settings.data.keybinds.get('ui')[6]]);

	@:noCompletion inline static function get_ui_down():Bool
		return FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[1], Settings.data.keybinds.get('ui')[5]]);
}
