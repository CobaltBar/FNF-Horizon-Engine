package util;

import openfl.events.KeyboardEvent;

class PlayerInput
{
	static var strum:Strumline;
	static var keys:Map<Int, Bool> = [];
	static var safeFrames:Float = 0;
	static var keyToData:Map<Int, Int> = [];

	public static function init():Void
	{
		strum = PlayState.instance.playerStrum;

		keyToData.set(Settings.data.keybinds['notes'][0], 0);
		keyToData.set(Settings.data.keybinds['notes'][1], 1);
		keyToData.set(Settings.data.keybinds['notes'][2], 2);
		keyToData.set(Settings.data.keybinds['notes'][3], 3);
		keyToData.set(Settings.data.keybinds['notes'][4], 0);
		keyToData.set(Settings.data.keybinds['notes'][5], 1);
		keyToData.set(Settings.data.keybinds['notes'][6], 2);
		keyToData.set(Settings.data.keybinds['notes'][7], 3);
		safeFrames = (10 / FlxG.updateFramerate) * 1000;

		for (setting in Settings.data.keybinds['notes'])
			keys.set(setting, false);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onOpenFLPress);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onOpenFLRelease);
	}

	static function onPress(data:Int):Void
	{
		for (note in strum.notes[data].members)
		{
			if (!note.alive)
				continue;
			if (Math.abs(Conductor.time - note.time) <= (45 + safeFrames)) // Sick
			{
				note.kill();
				strum.strums.members[data].confirm(false);
				return;
			}
			else if (Math.abs(Conductor.time - note.time) <= (90 + safeFrames)) // Good
			{
				note.kill();
				strum.strums.members[data].confirm(false);
				return;
			}
			if (Math.abs(Conductor.time - note.time) <= (135 + safeFrames)) // Bad
			{
				note.kill();
				strum.strums.members[data].confirm(false);
				return;
			}
			if (Math.abs(Conductor.time - note.time) <= (180 + safeFrames)) // Shit
			{
				note.kill();
				strum.strums.members[data].confirm(false);
				return;
			}
			else
			{
				strum.strums.members[data].press(false);
				return;
			}
		}
		strum.strums.members[data].press(false); // It returns in all other cases, so i can just run this :3
	}

	static function onRelease(data:Int):Void
	{
		@:privateAccess
		strum.strums.members[data].confirmAlphaTarget = strum.strums.members[data].pressedAlphaTarget = 0;
	}

	@:noCompletion static function onOpenFLPress(event:KeyboardEvent)
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
			if (!keys[event.keyCode])
			{
				keys.set(event.keyCode, true);
				onPress(keyToData[event.keyCode]);
			}

	@:noCompletion static function onOpenFLRelease(event:KeyboardEvent)
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
		{
			keys.set(event.keyCode, false);
			onRelease(keyToData[event.keyCode]);
		}

	public static function destroy():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onOpenFLPress);

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, onOpenFLRelease);
	}
}
