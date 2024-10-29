package horizon.objects.game;

class StrumNote extends NoteSprite
{
	var activeTimer:FlxTimer;

	public function new(data:Int = 2)
	{
		super(data);
		animation.play('strum');
		rgb = new RGBEffect();
		rgb.r = Settings.noteRGB[data][0];
		rgb.g = Settings.noteRGB[data][1];
		rgb.b = Settings.noteRGB[data][2];
		rgb.enabled = false;
		shader = rgb.shader;
		centerOffsets();
		updateHitbox();
		activeTimer = new FlxTimer();
		activeTimer.loops = 1;
		activeTimer.onComplete = timer -> unconfirm();
	}

	public function confirm(unconfirm:Bool = true):Void
	{
		playAnim('confirm');
		rgb.enabled = true;
		if (unconfirm)
			activeTimer.reset(Conductor.beatLength * 0.00125);
	}

	public function unconfirm():Void
	{
		playAnim('strum');
		rgb.enabled = false;
		activeTimer.cancel();
	}

	public function playAnim(animName:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
	{
		animation.play(animName, force, reversed, frame);
		centerOrigin();
		centerOffsets();
	}
}
