package objects;

import flixel.group.FlxSpriteContainer.FlxTypedSpriteContainer;

class Strumline extends FlxTypedSpriteContainer<StrumNote>
{
	static final angles = [270, 180, 0, 90];

	public function new(x:Float, y:Float, ?mod:Mod)
	{
		super(x, y);

		for (i in 0...4)
		{
			add(new StrumNote(i, mod));
			members[i].angle = members[i].angleOffset = angles[i];
			members[i].x = x + ((members[i].width * i) + 5);
		}
	}
}
