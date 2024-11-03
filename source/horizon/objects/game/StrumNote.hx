package horizon.objects.game;

import flixel.math.FlxAngle;

class StrumNote extends NoteSprite
{
	public var direction(default, set):Float;
	@:noCompletion public var sinDir(default, null):Float;
	@:noCompletion public var cosDir(default, null):Float;

	var activeTimer:FlxTimer;

	public function new(data:Int = 2)
	{
		super(data);
		direction = 90;
		animation.play('strum');
		rgb = RGBEffect.get(Settings.noteRGB[data], 1);
		centerOffsets();
		updateHitbox();
		activeTimer = new FlxTimer();
		activeTimer.loops = 1;
		activeTimer.onComplete = timer -> unconfirm();
	}

	public function confirm(unconfirm:Bool = true):Void
	{
		shader = rgb.shader;
		playAnim('confirm');
		if (unconfirm)
			activeTimer.reset(Conductor.beatLength * 0.001);
	}

	public function press():Void
	{
		shader = rgb.shader;
		playAnim('press');
	}

	public function unpress():Void
	{
		shader = null;
		playAnim('strum');
	}

	public function unconfirm():Void
	{
		shader = null;
		playAnim('strum');
		activeTimer.cancel();
	}

	public function playAnim(animName:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
	{
		animation.play(animName, force, reversed, frame);
		centerOrigin();
		centerOffsets();
	}

	@:noCompletion function set_direction(val:Float):Float
	{
		sinDir = Math.sin(val * FlxAngle.TO_RAD);
		cosDir = Math.cos(val * FlxAngle.TO_RAD);
		return direction = val;
	}
}
