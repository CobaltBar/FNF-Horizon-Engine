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
	}

	public function confirm(unconfirm:Bool = true):Void
	{
		activeTimer.reset(Conductor.stepLength * 0.00125);
	}

	public function playAnim(animName:String, ?force:Bool, ?reversed:Bool, ?frame:Int)
	{
		animation.play(animName, force, reversed, frame);
		if (animName == 'confirm')
			offset.set(13, 13);
		centerOrigin();
		centerOffsets();
	}
}
