package horizon.objects.game;

class NoteSprite extends FlxSprite
{
	public static var angleOffsets = [-90, -180, 0, 90];
	public static var desatColors:Array<Array<FlxColor>>;

	public var angleOffset(default, set):Float = 0;
	public var rgb:RGBEffect;

	@:noCompletion public function set_angleOffset(val:Float):Float
	{
		angleOffset = val;
		angle = 0;
		return val;
	}

	public override function set_angle(val:Float):Float
		return super.set_angle(val + angleOffset);

	@:inheritDoc(FlxSprite.updateMotion)
	override function updateMotion(elapsed:Float):Void
	{
		var velocityDelta = 0.5 * (flixel.math.FlxVelocity.computeVelocity(angularVelocity, angularAcceleration, angularDrag, maxAngular, elapsed)
			- angularVelocity);
		angularVelocity += velocityDelta;
		angle += angularVelocity * elapsed - angleOffset;
		angularVelocity += velocityDelta;

		velocityDelta = 0.5 * (flixel.math.FlxVelocity.computeVelocity(velocity.x, acceleration.x, drag.x, maxVelocity.x, elapsed) - velocity.x);
		velocity.x += velocityDelta;
		var delta = velocity.x * elapsed;
		velocity.x += velocityDelta;
		x += delta;

		velocityDelta = 0.5 * (flixel.math.FlxVelocity.computeVelocity(velocity.y, acceleration.y, drag.y, maxVelocity.y, elapsed) - velocity.y);
		velocity.y += velocityDelta;
		delta = velocity.y * elapsed;
		velocity.y += velocityDelta;
		y += delta;
	}

	public function new(data:Int = 2)
	{
		super();
		angleOffset = angleOffsets[data];
		frames = Path.atlas('note', PlayState.mods);
		animation.addByPrefix('strum', 'strum', 24);
		animation.addByPrefix('note', 'note', 24);
		animation.addByPrefix('tail', 'tail', 24);
		animation.addByPrefix('hold', 'hold', 24);
		animation.addByPrefix('confirm', 'confirm', 24, false);
		animation.addByPrefix('press', 'press', 24, false);
		animation.play('note');
		scale.set(.75, .75);
		updateHitbox();
	}

	function setRGB(colors:Array<FlxColor>):Void
	{
		rgb = RGBEffect.get(colors, 1);
		shader = rgb.shader;
	}
}
