package backend;

import flixel.sound.FlxSound;

class Conductor
{
	public static var bpm(default, set):Float = 100;
	public static var crochet:Float = 0;
	public static var stepCrochet:Float = 0;
	public static var song:FlxSound;

	public static function set_bpm(val:Float):Float
	{
		crochet = 60 / val * 1000;
		stepCrochet = crochet * 0.25;
		return bpm = val;
	}
}
