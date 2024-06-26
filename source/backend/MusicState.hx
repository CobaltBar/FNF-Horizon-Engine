package backend;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

class MusicState extends FlxTransitionableState
{
	var transitioningOut:Bool = false;

	var camerasToBop:Array<FlxCamera> = [];
	var shouldBop:Bool = true;
	var shouldZoom:Bool = true;
	var targetZoom:Float = 1;

	var curStep(get, set):Int;
	var curBeat(get, set):Int;
	var curDecBeat(get, set):Float;

	private function onStep():Void {}

	private function onBeat():Void
		if (!transitioningOut && shouldBop)
			for (cam in camerasToBop)
			{
				if (cam == null)
					continue;
				cam.zoom = 1.035;
			}

	public override function create()
	{
		super.create();
		@:privateAccess Conductor.beatSignal.add(onBeat);
		@:privateAccess Conductor.stepSignal.add(onStep);
		camerasToBop.push(FlxG.camera);
	}

	public override function update(elapsed:Float)
	{
		if (shouldZoom)
			for (cam in camerasToBop)
			{
				if (cam == null)
					continue;
				cam.zoom = FlxMath.lerp(cam.zoom, targetZoom, FlxMath.bound(elapsed * 3.25, 0, 1));
			}
		super.update(elapsed);
	}

	public override function destroy()
	{
		@:privateAccess Conductor.beatSignal.remove(onBeat);
		@:privateAccess Conductor.stepSignal.remove(onStep);
		super.destroy();
	}

	public static function switchState(state:FlxState, skipTransitionIn:Bool = false, skipTransitionOut:Bool = false):Void
	{
		FlxTransitionableState.skipNextTransIn = skipTransitionIn;
		FlxTransitionableState.skipNextTransOut = skipTransitionOut;
		FlxG.switchState(() -> state);
		if (Main.verboseLogging)
			Log.info('State Switch: \'${Type.getClassName(Type.getClass(state))}\'');
	}

	@:noCompletion @:keep inline function get_curStep():Int
		return Conductor.curStep;

	@:noCompletion @:keep inline function get_curBeat():Int
		return Conductor.curBeat;

	@:noCompletion @:keep inline function get_curDecBeat():Float
		return Conductor.curDecBeat;

	@:noCompletion @:keep inline function set_curStep(val:Int):Int
		return Conductor.curStep = curStep;

	@:noCompletion @:keep inline function set_curBeat(val:Int):Int
		return Conductor.curBeat = curStep;

	@:noCompletion @:keep inline function set_curDecBeat(val:Float):Float
		return Conductor.curDecBeat = val;
}
