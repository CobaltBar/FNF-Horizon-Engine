package objects;

class FlxCopySprite extends FlxSprite
{
	public var targetSpr:FlxSprite;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var copyAlpha:Bool = false;
	public var copyScale:Bool = false;

	public override function update(elapsed:Float)
	{
		if (targetSpr != null)
		{
			setPosition(targetSpr.x + offsetX, targetSpr.y - offsetY);
			if (copyAlpha)
				if (alpha != targetSpr.alpha)
					alpha = targetSpr.alpha;
			if (copyScale)
				if (scale != targetSpr.scale)
				{
					scale = targetSpr.scale;
					updateHitbox();
				}
		}
		super.update(elapsed);
	}
}
