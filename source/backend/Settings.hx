package backend;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import modding.Mod;

class SaveVars
{
	public var downscroll = false;
	public var middleScroll = false;
	public var ghostTapping:Bool = true;
	public var antialiasing:Bool = true;
	public var framerate:Int = 60;
	public var autoPause:Bool = true;
	public var showFPS:Bool = true;
	public var opponentStrums:Bool = true;
	public var flashing:Bool = true;
	public var safeMS:Float = 10;
	public var hitWindows:Array<Float> = [30, 80, 125, 140];
	public var keybinds:Map<String, Array<FlxKey>> = [
		'notes' => [A, S, W, D, LEFT, DOWN, UP, RIGHT],
		'ui' => [A, S, W, D, LEFT, DOWN, UP, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume' => [PLUS, MINUS, LBRACKET, NUMPADPLUS, NUMPADMINUS, NUMPADNINE],
		'debug' => [NUMPADSEVEN, NUMPADEIGHT],
	];
	public var savedMods:Map<Mod, ModSaveData> = [];
	public var fullscreen:Bool = false;
	public var resyncThreshold:Int = 30;

	public function new() {};
}

class Settings
{
	public static var data:SaveVars = null;

	public static function save()
	{
		for (setting in Reflect.fields(data))
		{
			Reflect.setField(FlxG.save.data, setting, Reflect.field(data, setting));
		}
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

		FlxG.drawFramerate = FlxG.updateFramerate = data.framerate;
		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;
	}
}
