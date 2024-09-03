package horizon.backend;

import flixel.input.keyboard.FlxKey;

@:publicFields
class Settings
{
	static var noteRGB:
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

	static var downScroll:Bool = false;
	static var middleScroll:Bool = false;
	static var ghostTapping:Bool = true;
	static var safeFrames:Int = 10;
	static var hitWindows:Array<Float> = [30, 60, 90, 120];
	static var autoPause:Bool = true;

	static var opponentStrums:Bool = true;
	static var showFPS:Bool = true;
	static var showMemory:Bool = true;

	static var antialiasing:Bool = true;
	static var framerate:Int = 0;
	static var shaders:Bool = true;

	static var accessibilityConfirmed:Bool = false;
	static var flashingLights:Bool = true;
	static var reducedMotion:Bool = false;
	static var lowQuality:Bool = false;

	static var keybinds:Map<String, Array<FlxKey>> = [
		'notes_left' => [A, LEFT],
		'notes_down' => [S, DOWN],
		'notes_up' => [W, UP],
		'notes_right' => [D, RIGHT],
		'ui_left' => [A, LEFT],
		'ui_down' => [S, DOWN],
		'ui_up' => [W, UP],
		'ui_right' => [D, RIGHT],
		'accept' => [SPACE, ENTER],
		'back' => [BACKSPACE, ESCAPE],
		'pause' => [ENTER, ESCAPE],
		'reset' => [R],
		'volume_increase' => [PLUS, NUMPADPLUS],
		'volume_decrease' => [MINUS, NUMPADMINUS],
		'volume_mute' => [P, NUMPADMULTIPLY],
		'debug' => [LBRACKET, RBRACKET],
	];

	static var savedMods:Map<String,
		{
			enabled:Bool,
			ID:Int,
			weeks:Map<String, {score:Int, accuracy:Float, locked:Bool}>,
			songs:Map<String, {score:Int, accuracy:Float}>
		}> = [];
	static var fullscreen:Bool = false;
}
