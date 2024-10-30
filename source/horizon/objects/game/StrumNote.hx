package horizon.objects.game;

class StrumNote extends NoteSprite
{
	var activeTimer:FlxTimer;

	public function new(data:Int = 2)
	{
		super(data);
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
			activeTimer.reset(Conductor.beatLength * 0.00125);
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

	public inline function playAnim(animName:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
	{
		animation.play(animName, force, reversed, frame);
		centerOrigin();
		centerOffsets();
	}
}
