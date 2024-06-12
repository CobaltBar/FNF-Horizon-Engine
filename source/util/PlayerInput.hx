package util;

import openfl.events.KeyboardEvent;

class PlayerInput
{
	static var strum:Strumline;

	public static function init():Void
	{
		strum = PlayState.instance.playerStrum;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, event -> {});

		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, event -> {});
	}
}
