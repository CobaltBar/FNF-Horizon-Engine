package abstractions;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;

class MusicState extends FlxTransitionableState
{
	var curStep:Int = 0;
	var curBeat:Int = 0;
	var curDecBeat:Float = 0;

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
		Path.clearUnusedMemory();
		if (errorText.length > 0 && !erroring)
		{
			erroring = true;
			MusicState.switchState(new ErrorState());
		}
	}

	public override function update(elapsed:Float):Void
	{
		if (curBeat != Conductor.curBeat && curStep > 0)
			onBeat();
		if (curStep != Conductor.curStep)
			onStep();
		if (shouldZoom)
			for (cam in camerasToBop)
			{
				if (cam == null)
					continue;
				cam.zoom = FlxMath.lerp(cam.zoom, targetZoom, FlxMath.bound(elapsed * 3.25, 0, 1));
			}
		super.update(elapsed);
	}

	public function onStep():Void
		curStep = Conductor.curStep;

	public function onBeat():Void
	{
		curBeat = Conductor.curBeat;
		if (!transitioningOut && shouldBop)
			for (cam in camerasToBop)
			{
				if (cam == null)
					continue;
				cam.zoom = 1.05;
			}
	}

	public static function switchState(state:FlxState, skipTransitionIn:Bool = false, skipTransitionOut:Bool = false):Void
	{
		FlxTransitionableState.skipNextTransIn = skipTransitionIn;
		FlxTransitionableState.skipNextTransOut = skipTransitionOut;
		FlxG.switchState(() -> state);
	}
}
