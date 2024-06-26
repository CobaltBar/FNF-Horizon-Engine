package backend;

import flixel.util.FlxSignal;

@:publicFields
class Conductor extends FlxBasic
{
	static var bpm(default, set):Float = 100;
	static var beatLength:Float = 0;
	static var stepLength:Float = 0;
	static var offset:Float = 0;
	static var time(get, null):Float = 0;
	static var song(default, set):FlxSound;

	static var curStep:Int = 0;
	static var curBeat:Int = -1;
	static var curDecBeat:Float = -1;
	static var switchToMusic:Bool = true;

	@:noCompletion private static var crochetStep:Float = 0;
	@:noCompletion private static var crochetBeat:Float = 0;

	@:noCompletion private static var stepSignal:FlxSignal;
	@:noCompletion private static var beatSignal:FlxSignal;

	public function new()
	{
		super();
		stepSignal = new FlxSignal();
		beatSignal = new FlxSignal();
		if (Main.verboseLogging)
			Log.info('Conductor Initialized');
	}

	override function update(elapsed:Float)
	{
		if (song != null)
		{
			if (time > crochetStep + stepLength)
			{
				crochetStep += stepLength;
				curStep++;
				curDecBeat = curStep * .25;
				stepSignal.dispatch();
			}

			if (time > crochetBeat + beatLength)
			{
				crochetBeat += beatLength;
				curBeat++;
				beatSignal.dispatch();
			}
		}
		else
		{
			if (FlxG.sound.music != null && switchToMusic)
			{
				song = FlxG.sound.music;
				if (Main.verboseLogging)
					Log.info('Song is null, setting to FlxG.sound.music');
			}
		}
		super.update(elapsed);
	}

	@:noCompletion public static function reset():Void
	{
		switchToMusic = true;
		bpm = 100;
		curStep = curBeat = -1;
		curDecBeat = crochetStep = crochetBeat = 0;
	}

	@:noCompletion static function set_song(val:FlxSound):FlxSound
	{
		val.onComplete = () -> Conductor.reset();

		return song = val;
	}

	@:noCompletion static function set_bpm(val:Float):Float
	{
		beatLength = 60 / val * 1000;
		stepLength = crochetBeat * .25;
		return bpm = val;
	}

	@:noCompletion static function get_time():Float
		return song.time + offset;
}
