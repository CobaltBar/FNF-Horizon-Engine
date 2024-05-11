package objects;

class FlxTargetSprite extends FlxSprite
{
	public var targetX:Float;
	public var targetY:Float;
	public var elapsedMultiplier:Float = 5;

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (targetX != null)
			x = FlxMath.lerp(x, targetX, FlxMath.bound(elapsed * elapsedMultiplier, 0, 1));
		if (targetY != null)
			y = FlxMath.lerp(y, targetY, FlxMath.bound(elapsed * elapsedMultiplier, 0, 1));
	}
}
