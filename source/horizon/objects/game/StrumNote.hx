package horizon.objects.game;

class StrumNote extends NoteSprite
{
	var confirm:NoteSprite;
	var press:NoteSprite;

	var confirmTarget:Float = 0;
	var pressTarget:Float = 0;
	var targetScaleX:Float = 1.0;
	var targetScaleY:Float = 1.0;
	var restoreScaleX:Float = 1.0;
	var restoreScaleY:Float = 1.0;
	var lerpMultiplier:Float = 25;
	var playingAnim:Bool = false;

	public function new(data:Int = 2, confirmSpr:NoteSprite, pressSpr:NoteSprite)
	{
		confirm = confirmSpr;
		press = pressSpr;
		super(data);
		setRGB(Settings.noteRGB.strum[data]);

		confirm.animation.play('confirm');
		confirm.updateHitbox();
		confirm.setRGB(Settings.noteRGB.notes[data]);
		confirm.blend = ADD;
		confirm.alpha = 0.0001;

		press.setRGB(Settings.noteRGB.press[data]);
		press.alpha = 0.0001;
		updateHitbox();

		confirm.offset.x = (confirm.width - width) * .5;
		confirm.offset.y = (confirm.height - height) * .5;
	}

	public override function update(elapsed:Float):Void
	{
		if (confirm != null && confirm.exists && confirm.visible)
			if (confirm.x != x || confirm.y != y)
				confirm.setPosition(x, y);
		if (press != null && press.exists && press.visible)
			if (press.x != x || press.y != y)
				press.setPosition(x, y);
		super.update(elapsed);
	}

	@:noCompletion override function set_angle(val:Float):Float
	{
		if (confirm != null)
			confirm.angle = val;
		if (press != null)
			press.angle = val;
		return super.set_angle(val);
	}
}
