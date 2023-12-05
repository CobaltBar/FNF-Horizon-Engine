package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;

class MusicState extends FlxUIState
{
	var curStep:Int = 0;
	var curBeat:Int = 0;
	var bpm:Int = 100;

	static var stepTimer:FlxTimer;

	public override function create():Void
	{
		stepTimer = new FlxTimer().start(60 / bpm / 4, onStep, 0);
		setupTransitions();
		super.create();
	}

	public function onStep(timer:FlxTimer):Void
	{
		if (curStep % 4 == 0)
			onBeat(timer);
		curStep++;
	}

	public function onBeat(timer:FlxTimer):Void
	{
		curBeat++;
	}

	public static function switchState(state:FlxState, skipTransition:Bool = false)
	{
		// FlxTransitionableState.skipNextTransIn = FlxTransitionableState.skipNextTransOut = skipTransition;
		FlxG.switchState(state);
	}

	private function setupTransitions():Void
	{
		// transIn = FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xff000000, 1, new FlxPoint(0, -1));
		// transOut = FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xff000000, 1, new FlxPoint(0, 1));
	}
}
