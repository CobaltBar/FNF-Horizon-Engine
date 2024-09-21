package horizon.states;

class StoryMenuState extends MusicMenuState
{
	var difficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekInfo:FlxText;
	var songsText:FlxText;
	var curDifficulty:Int = 0;
	var tracks:FlxSprite;

	var menuChars:Map<String, MenuCharacter> = [];
	var optionToData:Array<StoryMenuData> = [];

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		bop = false;

		// TODO make an actual preloading system based on a macro
		for (diff in ['easy', 'normal', 'hard', 'erect', 'nightmare'])
			Path.image('difficulty-$diff');

		add(bg = Create.graphic(0, 60, FlxG.width, 340, 0xFFF9CF51, [menuCam], 1.1));

		add(weekInfo = Create.text(FlxG.width * .5, 5, '000000', 32, Path.font('vcr'), 0xFFE55777, CENTER, [menuCam]));
		weekInfo.screenCenter(X);

		add(tracks = Create.sprite(0, bg.y + bg.height + 25, Path.image('tracks'), [menuCam]));
		tracks.screenCenter(X);
		tracks.x -= FlxG.width * .35;

		add(songsText = Create.text(0, bg.y + bg.height + 75, 'Song 1\nSong 2\nSong 3', 32, Path.font('vcr'), 0xFFE55777, CENTER, [menuCam]));
		songsText.screenCenter(X);
		songsText.x -= FlxG.width * .35;

		add(difficulty = Create.sprite(0, bg.y + bg.height + 25, Path.image('difficulty-normal'), [menuCam]));
		difficulty.screenCenter(X);
		difficulty.x += FlxG.width * .3;

		add(leftArrow = Create.atlas(0, 0, Path.sparrow('arrows'), [menuCam]));
		leftArrow.animation.addByPrefix('idle', 'leftIdle', 24);
		leftArrow.animation.addByPrefix('press', 'leftConfirm', 24);
		leftArrow.animation.play('idle');
		leftArrow.x = difficulty.x - leftArrow.width - 10;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;

		add(rightArrow = Create.atlas(0, 0, Path.sparrow('arrows'), [menuCam]));
		rightArrow.animation.addByPrefix('idle', 'rightIdle', 24);
		rightArrow.animation.addByPrefix('press', 'rightConfirm', 24);
		rightArrow.animation.play('idle');
		rightArrow.x = difficulty.x + difficulty.width + 5;
		rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;

		changeSelection(0);
		Path.clearUnusedMemory();
	}
}

// This replaces the anon struct from the previous impl

@:structInit @:publicFields
private class StoryMenuData
{
	var mod:Mod;
	var week:Week;
	var songs:Array<String>;
}
