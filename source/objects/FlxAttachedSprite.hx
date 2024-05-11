package objects;

class FlxAttachedSprite extends FlxSprite
{
	public var targetSprite:FlxSprite;
	public var offsetX:Float = 0;
	public var offsetY:Float = 0;
	public var copyAlpha:Bool = false;

	public override function update(elapsed:Float)
	{
		if (targetSprite != null)
		{
			setPosition(targetSprite.x + offsetX, targetSprite.y - offsetY);
			if (copyAlpha)
				alpha = targetSprite.alpha;
		}
		super.update(elapsed);
	}
}
