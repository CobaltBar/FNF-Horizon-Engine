package util;

import openfl.events.KeyboardEvent;

class PlayerInput
{
	public static function init():Void
	{
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, event -> {});

		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, event -> {});
	}
}
