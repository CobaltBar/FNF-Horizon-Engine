package backend;

import flixel.util.FlxSignal;

@:publicFields
class Conductor extends FlxBasic
{
	static var bpm(default, set):Float;

	static var beatLength:Float = 0;
	static var stepLength:Float = 0;
	static var measureLength:Float = 0;

	static var offset:Float = 0;
	static var time:Float = 0;
	static var song(default, set):FlxSound;

	static var curStep:Int = 0;
	static var curBeat:Int = 0;
	static var curMeasure:Int = 0;
	static var switchToMusic:Bool = true;

	static var stepSignal:FlxSignal;
	static var beatSignal:FlxSignal;
	static var measureSignal:FlxSignal;

	private static var stepTracker:Float = 0;
	private static var beatTracker:Float = 0;
	private static var measureTracker:Float = 0;

	function new()
	{
		super();
		stepSignal = new FlxSignal();
		beatSignal = new FlxSignal();
		measureSignal = new FlxSignal();
		if (Main.verbose)
			Log.info('Conductor Initialized');
	}

	override function update(elapsed:Float):Void
	{
		if (song != null)
			time = song.time + offset;
		else
		{
			if (FlxG.sound.music != null && switchToMusic)
			{
				if (Main.verbose)
					Log.info('Song is null, setting to FlxG.sound.music');
				song = FlxG.sound.music;
			}
		}

		if (time > measureTracker + measureLength)
		{
			measureTracker += measureLength;
			curMeasure++;
			measureSignal.dispatch();
		}

		if (time > beatTracker + beatLength)
		{
			beatTracker += beatLength;
			curBeat++;
			beatSignal.dispatch();
		}

		if (time > stepTracker + stepLength)
		{
			stepTracker += stepLength;
			curStep++;
			stepSignal.dispatch();
		}

		super.update(elapsed);
	}

	@:noCompletion static function reset():Void
	{
		bpm = 100;
		switchToMusic = true;
		stepTracker = beatTracker = measureTracker = time = 0;
		curMeasure = curBeat = curStep = 0;
		song = null;
	}

	@:noCompletion static function set_song(val:FlxSound):FlxSound
	{
		if (val != null)
			val.onComplete = () -> Conductor.reset();

		return song = val;
	}

	@:noCompletion static function set_bpm(val:Float):Float
	{
		beatLength = 60 / val * 1000;
		stepLength = beatLength * .25;
		measureLength = beatLength * 4;
		return bpm = val;
	}
}
