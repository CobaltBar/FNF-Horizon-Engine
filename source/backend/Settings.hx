package backend;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import modding.Mod;

@:publicFields
class SaveVars
{
	var downscroll = false;
	var middleScroll = false;
	var ghostTapping:Bool = true;
	var antialiasing:Bool = true;
	var framerate:Int = 0;
	var autoPause:Bool = true;
	var showFPS:Bool = true;
	var opponentStrums:Bool = true;
	var flashing:Bool = true;
	var safeMS:Float = 10;
	var hitWindows:Array<Float> = [30, 80, 125, 140];
	var keybinds:Map<String, Array<FlxKey>> = [
		'notes' => [A, S, W, D, LEFT, DOWN, UP, RIGHT],
		'ui' => [A, S, W, D, LEFT, DOWN, UP, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume' => [PLUS, MINUS, LBRACKET, NUMPADPLUS, NUMPADMINUS, NUMPADNINE],
		'debug' => [NUMPADSEVEN, NUMPADEIGHT],
	];
	var savedMods:Map<String, Mod> = [];
	var fullscreen:Bool = false;

	function new() {};
}

class Settings
{
	public static var data:SaveVars = null;

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
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}
}
