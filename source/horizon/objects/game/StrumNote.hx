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

	public function new(data:Int = 2, confSpr:NoteSprite, pressSpr:NoteSprite)
	{
		confirm = confSpr;
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
	}

	public override function update(elapsed:Float):Void
	{
		if (confirm != null && confirm.exists && confirm.visible)
			if (confirm.x != x - (confirm.width - width) * .5 || confirm.y != y - (confirm.height - height) * .5)
				confirm.setPosition(x - (confirm.width - width) * .5, y - (confirm.height - height) * .5);

		if (press != null && press.exists && press.visible)
			if (press.x != x || press.y != y)
				press.setPosition(x, y);
	}

	@:noCompletion override function set_angle(val:Float):Float
	{
		if (confirm != null)
			confirm.angle = val;
		if (press != null)
			press.angle = val;
		return super.set_angle(val);
	}

	@:noCompletion override function set_cameras(val:Array<FlxCamera>):Array<FlxCamera>
	{
		if (confirm != null)
			confirm.cameras = val;
		if (press != null)
			press.cameras = val;
		return super.set_cameras(val);
	}
}
