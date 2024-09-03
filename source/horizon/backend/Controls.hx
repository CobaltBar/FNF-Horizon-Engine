package horizon.backend;

import flixel.input.keyboard.FlxKey;
import flixel.util.typeLimit.OneOfTwo;
import openfl.events.KeyboardEvent;

@:publicFields
class Controls
{
	private static var keyTracker:Map<FlxKey, Bool> = [];

	static var pressed:Array<FlxKey> = [];
	static var pressSignals:Map<FlxKey, FlxSignal> = [];
	static var releaseSignals:Map<FlxKey, FlxSignal> = [];

	static function onPress(key:Array<FlxKey>, callback:Void->Void):Void
		for (key in key)
		{
			if (!pressSignals.exists(key))
				pressSignals.set(key, new FlxSignal());
			if (!keyTracker.exists(key))
				keyTracker.set(key, false);
			pressSignals[key].add(callback);
		}

	static function onRelease(key:Array<FlxKey>, callback:Void->Void):Void
		for (key in key)
		{
			if (!releaseSignals.exists(key))
				releaseSignals.set(key, new FlxSignal());
			if (!keyTracker.exists(key))
				keyTracker.set(key, false);
			releaseSignals[key].add(callback);
		}

	static function init():Void
	{
		FlxG.signals.preStateSwitch.add(() ->
		{
			for (signal in pressSignals)
				signal.destroy();
			for (signal in releaseSignals)
				signal.destroy();
			pressSignals.clear();
			releaseSignals.clear();
		});
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, press);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, release);
		if (Main.verbose)
			Log.info('Controls Initialized');
	}

	@:noCompletion static function press(event:KeyboardEvent):Void
	{
		var key:FlxKey = event.keyCode;
		if (pressSignals.exists(key))
			if (!keyTracker[key])
			{
				keyTracker.set(key, true);
				pressSignals[key].dispatch();
				pressed.push(key);
			}
	}

	@:noCompletion static function release(event:KeyboardEvent):Void
	{
		var key:FlxKey = event.keyCode;
		keyTracker.set(key, false);
		pressed.remove(key);
		if (releaseSignals.exists(key))
			releaseSignals[key].dispatch();
	}
}
