package horizon.objects.game;

class NoteSprite extends FlxSprite
{
	public static var angleOffsets = [-90, -180, 0, 90];

	public var angleOffset(default, set):Float = 0;
	public var rgb:RGBEffect;

	@:noCompletion public function set_angleOffset(val:Float):Float
	{
		angleOffset = val;
		set_angle(angle);
		return val;
	}

	public override function set_angle(val:Float):Float
		return super.set_angle(val + angleOffset);

	public function new(data:Int = 2)
	{
		super();
		angleOffset = angleOffsets[data];
		frames = Path.atlas('note', PlayState.mods);
		animation.addByNames('note', ['note'], 24);
		animation.addByNames('hold', ['hold'], 24);
		animation.addByNames('tail', ['tail'], 24);
		animation.addByNames('confirm', ['confirm'], 24);
		animation.play('note');
		scale.set(.8, .8);
		updateHitbox();
	}

	inline function setRGB(colors:Array<FlxColor>):Void
	{
		rgb = RGBEffect.get(colors);
		shader = rgb.shader;
	}
}
