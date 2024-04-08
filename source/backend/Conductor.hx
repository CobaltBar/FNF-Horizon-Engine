package backend;

import flixel.FlxBasic;
import flixel.sound.FlxSound;

class Conductor extends FlxBasic
{
	public static var bpm(default, set):Float = 100;
	public static var crochet:Float = 0;
	public static var stepCrochet:Float = 0;
	public static var offset(default, set):Float = 0;
	public static var song(default, set):FlxSound;

	public static var curStep:Int = 0;
	public static var curBeat:Int = 0;
	public static var curDecBeat:Float = 0;

	private static var curCrochetStep:Float = 0;
	private static var curCrochetBeat:Float = 0;

	public override function update(elapsed:Float)
	{
		if (song != null)
		{
			if (song.time > curCrochetStep + stepCrochet)
			{
				curCrochetStep += stepCrochet;
				curStep++;
				curDecBeat = curStep * 0.25;
			}
			if (song.time > curCrochetBeat + crochet)
			{
				curCrochetBeat += crochet;
				curBeat++;
			}
		}
		else
		{
			if (FlxG.sound.music != null)
				Conductor.song = FlxG.sound.music;
		}
		super.update(elapsed);
	}

	public static function set_song(val:FlxSound):FlxSound
	{
		val.onComplete = () ->
		{
			curStep = curBeat = 0;
			curDecBeat = curCrochetStep = curCrochetBeat = 0;
		}
		return song = val;
	}

	public static function set_bpm(val:Float):Float
	{
		crochet = 60 / val * 1000;
		stepCrochet = crochet * 0.25;
		return bpm = val;
	}

	public static function set_offset(val:Float):Float
		return song.offset = offset = val;
}
