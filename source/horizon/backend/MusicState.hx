package horizon.backend;

import flixel.addons.transition.FlxTransitionableState;

class MusicState extends FlxTransitionableState
{
	var transitioningOut:Bool = false;

	var bopCams:Array<FlxCamera> = [];
	var bopZoom:Float = 1.035;
	var bop:Bool = true;
	var zoom:Bool = true;
	var targetZoom:Float = 1;

	var curStep(get, set):Int;
	var curBeat(get, set):Int;
	var curMeasure(get, set):Int;

	function onStep():Void {}

	function onBeat():Void
		if (!transitioningOut && bop)
			for (cam in bopCams)
				cam.zoom = bopZoom;

	public override function create():Void
	{
		super.create();
		Conductor.stepSignal.add(onStep);
		Conductor.beatSignal.add(onBeat);
		bopCams.push(FlxG.camera);
	}

	public override function update(elapsed:Float):Void
	{
		if (zoom)
			for (cam in bopCams)
				cam.zoom = FlxMath.lerp(cam.zoom, targetZoom, FlxMath.bound(elapsed * 3.25, 0, 1));
		super.update(elapsed);
	}

	public override function destroy():Void
	{
		bopCams = [];
		Conductor.stepSignal.remove(onStep);
		Conductor.beatSignal.remove(onBeat);
		FlxG.cameras.reset();

		super.destroy();
	}

	public static function switchState(state:FlxState, skipTransIn:Bool = false, skipTransOut:Bool = false):Void
	{
		FlxTransitionableState.skipNextTransIn = skipTransIn;
		FlxTransitionableState.skipNextTransOut = skipTransOut;
		FlxG.switchState(() -> state);
		if (Main.verbose)
			Log.info('State Switch: \'${Type.getClassName(Type.getClass(state)).replace('horizon.', '')}\'');
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
