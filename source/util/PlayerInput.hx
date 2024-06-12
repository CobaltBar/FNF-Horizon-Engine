package util;

import openfl.events.KeyboardEvent;

class PlayerInput
{
	static var keyTracker:Map<Int, Bool> = [];
	static var safeFrames:Float = 0;
	static var keyToData:Map<Int, Int> = [];

	public static function init():Void
	{
		for (i in 0...Settings.data.keybinds['notes'].length)
		{
			keyToData.set(Settings.data.keybinds['notes'][i], i % 4);
			keyTracker.set(Settings.data.keybinds['notes'][i], false);
		}
		safeFrames = (10 / FlxG.updateFramerate) * 1000;
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onRelease);
	}

	@:noCompletion public static function onPress(event:KeyboardEvent):Void
	{
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
			if (!keyTracker[event.keyCode])
			{
				for (note in PlayState.instance.playerStrum.notes[keyToData[event.keyCode]].members)
				{
					if (!note.alive)
						continue;
					if (Math.abs(Conductor.time - note.time) <= (180 + safeFrames))
					{
						note.kill();
						PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].confirm(false);
						judge(Math.abs(Conductor.time - note.time));
						return;
					}
				}
				PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].press(false);
			}
	}

	@:noCompletion public static function onRelease(event:KeyboardEvent):Void
	{
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
		{
			keyTracker.set(event.keyCode, false);
			@:privateAccess
			PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].confirmAlphaTarget = PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].pressedAlphaTarget = 0;
		}
	}

	static inline function judge(time:Float):Void
	{
		// 45, 90, 135, 180
	}
}
