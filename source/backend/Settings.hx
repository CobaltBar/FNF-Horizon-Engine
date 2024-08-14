package backend;

import flixel.input.keyboard.FlxKey;

@:publicFields
class SaveVars
{
	var noteRGB:
		{
			strum:Array<{base:FlxColor, highlight:FlxColor, outline:FlxColor}>,
			notes:Array<{base:FlxColor, highlight:FlxColor, outline:FlxColor}>,
			press:Array<{base:FlxColor, highlight:FlxColor, outline:FlxColor}>,
		} = {
			strum: [
				{base: 0xFF87A3AD, highlight: 0xFFFFFFFF, outline: 0xFF000000},
				{base: 0xFF87A3AD, highlight: 0xFFFFFFFF, outline: 0xFF000000},
				{base: 0xFF87A3AD, highlight: 0xFFFFFFFF, outline: 0xFF000000},
				{base: 0xFF87A3AD, highlight: 0xFFFFFFFF, outline: 0xFF000000}
			],
			notes: [
				{base: 0xFFC24B99, highlight: 0xFFFFFFFF, outline: 0xFF3C1F56},
				{base: 0xFF00FFFF, highlight: 0xFFFFFFFF, outline: 0xFF1542B7},
				{base: 0xFF12FA05, highlight: 0xFFFFFFFF, outline: 0xFF0A4447},
				{base: 0xFFF9393F, highlight: 0xFFFFFFFF, outline: 0xFF651038}
			],
			press: [
				{base: 0xFF8B78BC, highlight: 0xFFFFFFFF, outline: 0xFF201E31},
				{base: 0xFF6DC0C7, highlight: 0xFFFFFFFF, outline: 0xFF201E31},
				{base: 0xFF6DC782, highlight: 0xFFFFFFFF, outline: 0xFF201E31},
				{base: 0xFFBE7683, highlight: 0xFFFFFFFF, outline: 0xFF201E31},
			]
		};

	var downScroll:Bool = false;
	var middleScroll:Bool = false;
	var ghostTapping:Bool = true;
	var safeFrames:Int = 10;
	var hitWindows:Array<Float> = [30, 60, 90, 120];
	var autoPause:Bool = true;

	var opponentStrums:Bool = true;
	var showFPS:Bool = true;
	var showMemory:Bool = true;

	var antialiasing:Bool = true;
	var framerate:Int = 0;
	var shaders:Bool = true;

	var accessibilityConfirmed:Bool = false;
	var flashingLights:Bool = true;
	var reducedMotion:Bool = false;
	var lowQuality:Bool = false;

	var keybinds:Map<String, Array<FlxKey>> = [
		'notes' => [A, S, W, D, LEFT, DOWN, UP, RIGHT],
		'ui' => [A, S, W, D, LEFT, DOWN, UP, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume' => [PLUS, MINUS, P, NUMPADPLUS, NUMPADMINUS, NUMPADMULTIPLY],
		'debug' => [LBRACKET, RBRACKET],
	];

	var savedMods:Map<String,
		{
			enabled:Bool,
			ID:Int,
			weeks:Map<String, {score:Int}>,
			songs:Map<String, {score:Int, accuracy:Float}>
		}> = [];
	var fullscreen:Bool = false;

	function new() {};
}

class Settings
{
	public static var data:SaveVars = null;

	public static function save():Void
	{
		if (data == null)
			data = new SaveVars();
		data.fullscreen = FlxG.fullscreen;
		for (setting in Reflect.fields(data))
			Reflect.setField(FlxG.save.data, setting, Reflect.field(data, setting));
		FlxG.save.flush();
		if (Main.verbose)
			Log.info('Settings saved');
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

		FlxG.sound.volumeUpKeys = [data.keybinds.get('volume')[0], data.keybinds.get('volume')[3]];
		FlxG.sound.volumeDownKeys = [data.keybinds.get('volume')[1], data.keybinds.get('volume')[4]];
		FlxG.sound.muteKeys = [data.keybinds.get('volume')[2], data.keybinds.get('volume')[5]];

		if (FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		if (Main.verbose)
			Log.info('Settings Loaded');
	}
}
