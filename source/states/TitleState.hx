package states;

import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;

class TitleState extends FlxState
{
	var gf:FlxSprite;
	var titleEnter:FlxSprite;
	var logo:FlxSprite;
	var curBeat:Int = 0;

	public override function create()
	{
		super.create();

		gf = new FlxSprite(500, 100);
		gf.antialiasing = true;
		gf.frames = FlxAtlasFrames.fromSparrow("assets/images/gfDanceTitle.png", "assets/images/gfDanceTitle.xml");
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		add(gf);
		titleEnter = new FlxSprite(500, 500);
		titleEnter.antialiasing = true;
		titleEnter.frames = FlxAtlasFrames.fromSparrow("assets/images/titleEnter.png", "assets/images/titleEnter.xml");
		titleEnter.animation.addByPrefix("Idle", "ENTER IDLE", 24, true);
		titleEnter.animation.addByPrefix("Pressed", "ENTER PRESSED", 24, true);
		add(titleEnter);
		logo = new FlxSprite(500, 500);
		logo.antialiasing = true;
		logo.frames = FlxAtlasFrames.fromSparrow("assets/images/titleEnter.png", "assets/images/titleEnter.xml");
		logo.animation.addByPrefix("Bop", "logo bumpin", 24, true);
		add(logo);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
