package objects;

class Note extends FlxAttachedSprite
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

	public function new(noteData:Int = 2, ?mod:Mod)
	{
		super();
		frames = Path.sparrow('note', mod);
		animation.addByPrefix('idle', 'idle', 24, true);
		animation.play('idle', true);
		scale.set(1.2, 1.2);
		updateHitbox();
		antialiasing = Settings.data.antialiasing;
		moves = false;

		shader = rgb.shader;
		rgb.set(0x717171, -0x000001, 0x333333);
	}
}
