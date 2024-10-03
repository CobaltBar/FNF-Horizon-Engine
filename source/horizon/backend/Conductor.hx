package horizon.backend;

@:structInit @:publicFields class TimeSignature
{
	var beatsPerMeasure:Float;
	var stepsPerBeat:Float;

	static function fromString(sig:String):TimeSignature
	{
		if (!sig.contains('/'))
			return {beatsPerMeasure: 4, stepsPerBeat: 4}

		var split = sig.trim().split('/');
		return {beatsPerMeasure: Std.parseFloat(split[0].trim()), stepsPerBeat: Std.parseFloat(split[1].trim())}
	}
}

@:publicFields
class Conductor extends FlxBasic
{
	static var bpm(default, set):Float;

	static var beatLength:Float = -1;
	static var stepLength:Float = -1;
	static var measureLength:Float = -1;

	static var offset:Float = 0;
	static var time:Float = 0;
	static var lerpedTime:Float = 0;
	static var song(default, set):FlxSound;
	static var timeSignature(default, set):TimeSignature = {beatsPerMeasure: 4, stepsPerBeat: 4}

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

		if (Constants.verbose)
			Log.info('Conductor Initialized');
	}

	override function update(elapsed:Float):Void
	{
		if (song != null)
		{
			time = song.time + offset;
			lerpedTime = FlxMath.lerp(lerpedTime, song.time + offset, FlxMath.bound(elapsed * 20, 0, 1));
		}
		else if (FlxG.sound.music != null && switchToMusic)
		{
			if (Constants.verbose)
				Log.info('Song is null, setting to FlxG.sound.music');
			song = FlxG.sound.music;
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
		timeSignature = {beatsPerMeasure: 4, stepsPerBeat: 4}
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
		recalculateLengths(val);
		return bpm = val;
	}

	@:noCompletion static function set_timeSignature(val:TimeSignature):TimeSignature
	{
		timeSignature = val;
		recalculateLengths(bpm);
		return val;
	}

	@:noCompletion static inline function recalculateLengths(val:Float):Void
	{
		beatLength = 60 / val * 1000;
		stepLength = beatLength / timeSignature.stepsPerBeat;
		measureLength = beatLength * timeSignature.beatsPerMeasure;
	}
}
