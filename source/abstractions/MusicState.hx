package abstractions;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;

class MusicState extends FlxTransitionableState
{
	var curBeat:Int = 0;
	var curStep:Int = 0;
	var curDecBeat:Float = 0;
	var curDecStep:Float = 0;

	var transitioningOut:Bool = false;
	var transitionFromPoint:FlxPoint;
	var transitionToPoint:FlxPoint;

	var camerasToBop:Array<FlxCamera> = [];
	var shouldBop:Bool = true;
	var shouldZoom:Bool = true;
	var targetZoom:Float = 1;

	public static var erroring:Bool = false;
	public static var errorText:String = "";

	public override function create():Void
	{
		transitionFromPoint = new FlxPoint(-1, 0);
		transitionToPoint = new FlxPoint(1, 0);
		transIn = FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xff000000, 0.5, transitionFromPoint);
		transOut = FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xff000000, 0.5, transitionToPoint);

		camerasToBop.push(FlxG.camera);

		super.create();
		if (errorText.length > 0 && !erroring)
		{
			erroring = true;
			MusicState.switchState(new ErrorState());
		}
	}

	public override function update(elapsed:Float):Void
	{
		updateConductor();
		if (shouldZoom)
			for (cam in camerasToBop)
			{
				if (cam == null)
					continue;
				cam.zoom = FlxMath.lerp(cam.zoom, targetZoom, elapsed * 3.25);
			}
		super.update(elapsed);
	}

	private function updateConductor():Void
	{
		if (Conductor.song != null)
		{
			if (Conductor.song.time > curDecBeat + Conductor.crochet)
			{
				curDecBeat += Conductor.crochet;
				onBeat();
			}
			if (Conductor.song.time > curDecStep + Conductor.stepCrochet)
			{
				curDecStep += Conductor.stepCrochet;
				onStep();
			}
		}
		else if (FlxG.sound.music != null)
			Conductor.song = FlxG.sound.music;
	}

	public function onStep():Void
		curStep++;

	public function onBeat():Void
	{
		if (!transitioningOut && shouldBop)
			for (cam in camerasToBop)
			{
				if (cam == null)
					continue;
				cam.zoom = 1.05;
			}
		curBeat++;
	}

	public static function switchState(state:FlxState, skipTransitionIn:Bool = false, skipTransitionOut:Bool = false):Void
	{
		FlxTransitionableState.skipNextTransIn = skipTransitionIn;
		FlxTransitionableState.skipNextTransOut = skipTransitionOut;
		FlxG.switchState(() -> state);
	}
}
