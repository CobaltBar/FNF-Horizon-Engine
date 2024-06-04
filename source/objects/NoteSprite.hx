package objects;

class NoteSprite extends FlxCopySprite
{
	public var rgb:RGBPalette = new RGBPalette();
	public var angleOffset(default, set):Float = 0;
	public var realAngle(default, set):Float = 0;

	@:noCompletion function set_angleOffset(val:Float):Float
	{
		realAngle = realAngle;
		return angleOffset = val;
	}

	@:noCompletion function set_realAngle(val:Float):Float
	{
		angle = realAngle + angleOffset;
		return realAngle = val;
	}

	public function new(noteData:Int = 2)
	{
		super();
		frames = Path.sparrow('note', PlayState.config.mods);
		animation.addByPrefix('idle', 'idle', 24, true);
		animation.play('idle', true);
		scale.set(1.1, 1.1);
		updateHitbox();
		antialiasing = Settings.data.antialiasing;
		moves = false;

		shader = rgb.shader;
		rgb.set(0x717171, -0x000001, 0x333333);
	}
}
