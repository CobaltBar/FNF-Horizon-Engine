package backend;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

class MusicState extends FlxTransitionableState
{
	var transitioningOut:Bool = false;

	var bopCameras:Array<FlxCamera> = [];
	var bop:Bool = true;
	var zoom:Bool = true;
	var targetZoom:Float = 1;

	var curStep(get, set):Int;
	var curBeat(get, set):Int;
	var curMeasure(get, set):Int;

	private function onStep():Void {}

	private function onBeat():Void
		if (!transitioningOut && bop)
			for (cam in bopCameras)
				if (cam != null)
					cam.zoom = 1.035;

	public override function create():Void
	{
		super.create();
		@:privateAccess {
			Conductor.stepSignal.add(onStep);
			Conductor.beatSignal.add(onBeat);
		}
		bopCameras.push(FlxG.camera);
	}

	public override function update(elapsed:Float):Void
	{
		if (zoom)
			for (cam in bopCameras)
				if (cam != null)
					cam.zoom = FlxMath.lerp(cam.zoom, targetZoom, FlxMath.bound(elapsed * 3.25, 0, 1));

		if (Controls.debug)
			if (Main._console.hidden)
				Main._console.show();
			else
				Main._console.hide();

		super.update(elapsed);
	}

	public override function destroy():Void
	{
		@:privateAccess {
			Conductor.stepSignal.remove(onStep);
			Conductor.beatSignal.remove(onBeat);
		}
		super.destroy();
	}

	public static function switchState(state:FlxState, skipTransitionIn:Bool = false, skipTransitionOut:Bool = false):Void
	{
		FlxTransitionableState.skipNextTransIn = skipTransitionIn;
		FlxTransitionableState.skipNextTransOut = skipTransitionOut;
		FlxG.switchState(() -> state);
		if (Main.verbose)
			Log.info('State Switch: \'${Type.getClassName(Type.getClass(state))}\'');
	}

	@:noCompletion @:keep inline function get_curStep():Int
		return Conductor.curStep;

	@:noCompletion @:keep inline function get_curBeat():Int
		return Conductor.curBeat;

	@:noCompletion @:keep inline function get_curMeasure():Int
		return Conductor.curMeasure;

	@:noCompletion @:keep inline function set_curStep(val:Int):Int
		return Conductor.curStep = val;

	@:noCompletion @:keep inline function set_curBeat(val:Int):Int
		return Conductor.curBeat = val;

	@:noCompletion @:keep inline function set_curMeasure(val:Int):Int
		return Conductor.curMeasure = val;
}
