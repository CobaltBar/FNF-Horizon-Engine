package backend;

import openfl.events.KeyboardEvent;

// todo make this macro'd
@:publicFields
class Controls
{
	private static var keys:Map<Int, Bool> = [];

	static var note_left(get, null):Bool;
	static var note_down(get, null):Bool;
	static var note_up(get, null):Bool;
	static var note_right(get, null):Bool;

	static var ui_left(get, null):Bool;
	static var ui_down(get, null):Bool;
	static var ui_up(get, null):Bool;
	static var ui_right(get, null):Bool;

	static var accept(get, null):Bool;
	static var back(get, null):Bool;
	static var pause(get, null):Bool;
	static var reset(get, null):Bool;

	static var debug(get, null):Bool;

	static function init():Void
	{
		for (keybind in Settings.data.keybinds)
			for (key in keybind)
				keys.set(key, false);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, event -> if (!keys[event.keyCode]) keys.set(event.keyCode, true));

		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, event -> keys.set(event.keyCode, false));
	}

	@:noCompletion @:keep static inline function get_note_left():Bool
		return get(Settings.data.keybinds['notes'][0]) || get(Settings.data.keybinds['notes'][4]);

	@:noCompletion @:keep static inline function get_note_down():Bool
		return get(Settings.data.keybinds['notes'][1]) || get(Settings.data.keybinds['notes'][5]);

	@:noCompletion @:keep static inline function get_note_up():Bool
		return get(Settings.data.keybinds['notes'][2]) || get(Settings.data.keybinds['notes'][6]);

	@:noCompletion @:keep static inline function get_note_right():Bool
		return get(Settings.data.keybinds['notes'][3]) || get(Settings.data.keybinds['notes'][7]);

	@:noCompletion @:keep static inline function get_ui_left():Bool
		return get(Settings.data.keybinds['ui'][0]) || get(Settings.data.keybinds['ui'][4]);

	@:noCompletion @:keep static inline function get_ui_down():Bool
		return get(Settings.data.keybinds['ui'][1]) || get(Settings.data.keybinds['ui'][5]);

	@:noCompletion @:keep static inline function get_ui_up():Bool
		return get(Settings.data.keybinds['ui'][2]) || get(Settings.data.keybinds['ui'][6]);

	@:noCompletion @:keep static inline function get_ui_right():Bool
		return get(Settings.data.keybinds['ui'][3]) || get(Settings.data.keybinds['ui'][7]);

	@:noCompletion @:keep static inline function get_accept():Bool
		return get(Settings.data.keybinds['accept'][0]) || get(Settings.data.keybinds['accept'][1]);

	@:noCompletion @:keep static inline function get_back():Bool
		return get(Settings.data.keybinds['back'][0]) || get(Settings.data.keybinds['back'][1]);

	@:noCompletion @:keep static inline function get_pause():Bool
		return get(Settings.data.keybinds['pause'][0]) || get(Settings.data.keybinds['pause'][1]);

	@:noCompletion @:keep static inline function get_reset():Bool
		return get(Settings.data.keybinds['reset'][0]);

	@:noCompletion @:keep static inline function get_debug():Bool
		return get(Settings.data.keybinds['debug'][0]);

	@:noCompletion static inline function get(key:Int):Bool
	{
		if (keys[key])
		{
			keys[key] = false;
			return true;
		}
		return false;
	}
}
