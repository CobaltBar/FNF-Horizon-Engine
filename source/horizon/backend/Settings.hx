package horizon.backend;

import flixel.input.keyboard.FlxKey;

@:publicFields
class Settings
{
	static var noteRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]
	];

	static var downScroll:Bool = false;
	static var middleScroll:Bool = false;
	static var ghostTapping:Bool = true;
	static var safeFrames:Int = 10;
	static var hitWindows:Array<Float> = [30, 90, 135, 160];
	static var autoPause:Bool = true;

	static var opponentStrums:Bool = true;
	static var comboOffsets:Array<Float> = [0, 0];
	static var showFPS:Bool = true;
	static var showMemory:Bool = true;

	static var antialiasing:Bool = true;
	static var framerate:Int = 0;
	static var gpuTextures:Bool = true;
	static var shaders:Bool = true;

	static var accessibilityConfirmed:Bool = false;
	static var flashingLights:Bool = true;
	static var reducedMotion:Bool = false;
	static var lowQuality:Bool = false;

	static var keybinds:Map<String, Array<FlxKey>> = [
		'note_left' => [A, LEFT],
		'note_down' => [S, DOWN],
		'note_up' => [W, UP],
		'note_right' => [D, RIGHT],
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

	static var savedMods:Map<String, SavedModData> = [];
	static var fullscreen:Bool = false;
}

@:structInit @:publicFields private class SavedModData
{
	var enabled:Bool;
	var ID:Int;
	var weeks:Map<String, {score:Int, accuracy:Float, locked:Bool}>;
	var songs:Map<String, {score:Int, accuracy:Float}>;
}
