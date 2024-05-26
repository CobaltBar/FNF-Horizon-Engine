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
			var strum:StrumNote;
			add(strum = new StrumNote(i, mod));
			strum.angle = strum.angleOffset = angles[i];
			strum.x = x + ((strum.width * i) + 5);
			strum.rgb.set(Settings.data.noteRGB[i].base, Settings.data.noteRGB[i].highlight, Settings.data.noteRGB[i].outline);
		}
	}
}
