package backend;

import flixel.util.FlxSignal;

@:publicFields
class Conductor extends FlxBasic
{
	static var bpm(default, set):Float = 100;
	static var beatLength:Float = 0;
	static var stepLength:Float = 0;
	static var offset:Float = 0;
	static var time:Float = 0;
	static var song(default, set):FlxSound;

	static var curStep:Int = 0;
	static var curBeat:Int = -1;
	static var switchToMusic:Bool = true;

	private static var stepTracker:Float = 0;
	private static var beatTracker:Float = 0;

	private static var stepSignal:FlxSignal;
	private static var beatSignal:FlxSignal;

	public function new()
	{
		super();
		stepSignal = new FlxSignal();
		beatSignal = new FlxSignal();
		if (Main.verbose)
			Log.info('Conductor Initialized');
	}

	override function update(elapsed:Float):Void
	{
		if (song != null)
		{
			time = FlxMath.lerp(time, song.time + offset, FlxMath.bound(elapsed * 20, 0, 1));

			if (time > stepTracker + stepLength)
			{
				stepTracker += stepLength;
				curStep++;
				stepSignal.dispatch();
			}

			if (time > beatTracker + beatLength)
			{
				beatTracker += beatLength;
				curBeat++;
				beatSignal.dispatch();
			}
		}
		else
		{
			if (FlxG.sound.music != null && switchToMusic)
			{
				if (Main.verbose)
					Log.info('Song is null, setting to FlxG.sound.music');
				song = FlxG.sound.music;
			}
		}
		super.update(elapsed);
	}

	@:noCompletion public static function reset():Void
	{
		switchToMusic = true;
		bpm = 100;
		curBeat = -1;
		stepTracker = beatTracker = time = curStep = 0;
	}

	@:noCompletion static function set_song(val:FlxSound):FlxSound
	{
		val.onComplete = () -> Conductor.reset();

		return song = val;
	}

	@:noCompletion static function set_bpm(val:Float):Float
	{
		beatLength = 60 / val * 1000;
		stepLength = beatLength * .25;
		return bpm = val;
	}
}
