package backend;

import flixel.input.keyboard.FlxKey;

@:publicFields
class SaveVars
{
	var downScroll:Bool = false;
	var middleScroll:Bool = false;
	var ghostTapping:Bool = true;
	var safeMS:Float = 10;
	var hitWindows:Array<Float> = [30, 80, 125, 140];
	var autoPause:Bool = true;

	var opponentStrums:Bool = true;
	var showFPS:Bool = true;
	var showMemory:Bool = true;
	var flashingLights:Bool = true;

	var antialiasing:Bool = true;
	var framerate:Int = 0;
	var shaders:Bool = true;
	var lowQuality:Bool = false;

	var confirmedOptions:Bool = false;

	var keybinds:Map<String, Array<FlxKey>> = [
		'notes' => [A, S, W, D, LEFT, DOWN, UP, RIGHT],
		'ui' => [A, S, W, D, LEFT, DOWN, UP, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume' => [PLUS, MINUS, BACKSLASH, NUMPADPLUS, NUMPADMINUS, NUMPADNINE],
		'debug' => [NUMPADSEVEN, NUMPADEIGHT],
	];

	var savedMods:Map<String, Mod> = [];
	var fullscreen:Bool = false;

	function new() {};
}

class Settings
{
	public static var data:SaveVars;

	public static function save()
	{
		if (data == null)
			data = new SaveVars();
		data.fullscreen = FlxG.fullscreen;
		for (setting in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, setting, Reflect.field(data, setting));
		FlxG.save.flush();
	}

	public static function load()
	{
		if (data == null)
			data = new SaveVars();
		for (key in Reflect.fields(data))
			if (Reflect.hasField(FlxG.save.data, key))
				Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));

		FlxG.fullscreen = data.fullscreen;

		FlxG.drawFramerate = data.framerate;
		FlxG.updateFramerate = Std.int(data.framerate * 1.5);

		FlxG.sound.volumeUpKeys = [data.keybinds.get("volume")[0], data.keybinds.get("volume")[3]];
		FlxG.sound.volumeDownKeys = [data.keybinds.get("volume")[1], data.keybinds.get("volume")[4]];
		FlxG.sound.muteKeys = [data.keybinds.get("volume")[2], data.keybinds.get("volume")[5]];

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		if (Main.verboseLogging)
			Log.info("Settings Loaded.");
	}
}
