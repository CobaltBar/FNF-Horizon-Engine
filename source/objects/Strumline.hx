package objects;

class Strumline extends FlxTypedSpriteGroup<FlxCopySprite>
{
	static final angles = [270, 180, 0, 90];

	public var notes:Array<FlxTypedSpriteGroup<Note>> = [];
	public var covers:Array<FlxCopySprite> = [];
	public var splashes:FlxTypedSpriteGroup<FlxCopySprite>;

	public function new(x:Float, y:Float, ?mod:Mod)
	{
		super(x, y);

		splashes = new FlxTypedSpriteGroup<FlxCopySprite>(x, y);

		for (i in 0...4)
		{
			var strum:StrumNote;
			add(strum = new StrumNote(i));
			strum.angle = strum.angleOffset = angles[i];
			strum.x = x + ((strum.width * i) + 5);
		}
	}
}
