package backend;

@:publicFields
class Controls
{
	static var accept(get, null):Bool;

	@:noCompletion @:keep inline static function get_accept():Bool
		return FlxG.keys.anyJustPressed(Settings.data.keybinds.get('accept'));
}
