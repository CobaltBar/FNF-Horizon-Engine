package states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;

class TitleState extends FlxState
{
	var GF:FlxSprite;
	var TitleEnter:FlxSprite;
	var Logo:FlxSprite;

	public override function create()
	{
		super.create();

		GF = new FlxSprite(500, 100);
		GF.antialiasing = true;
		GF.frames = FlxAtlasFrames.fromSparrow("assets/images/gfDanceTitle.png", "assets/images/gfDanceTitle.xml");
		GF.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		GF.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		add(GF);
		TitleEnter = new FlxSprite(500, 500);
		Logo = new FlxSprite(0, 0);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
