package states;

class StoryMenuState extends MusicMenuState
{
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var difficulty:FlxSprite;
	var curDifficulty:Int = 0;

	var scoreTxt:FlxText;
	var songsText:FlxText;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		DiscordRPC.changePresence("Menu: Story Mode");
		createUI();
		createMenuOptions();
		shouldBop = false;
		changeSelection(0);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
	}

	public override function returnState():Void
	{
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public inline function createUI():Void
	{
		bg = Util.makeSprite(50, 100, FlxG.width - 100, 400, 0xFFF9CF51);
		bg.cameras = [menuCam];
		add(bg);

		scoreTxt = Util.createText(50, 50, "000000", 48, Path.font("vcr"), 0xFFe55777, LEFT);
		scoreTxt.cameras = [menuCam];
		add(scoreTxt);

		var tracks = Util.createGraphicSprite(0, 600, Path.image("tracks"), 1.5);
		tracks.screenCenter(X);
		tracks.x -= 500;
		tracks.cameras = [menuCam];
		add(tracks);

		songsText = Util.createText(0, 680, "", 48, Path.font("vcr"), 0xFFe55777, CENTER);
		songsText.screenCenter(X);
		songsText.x -= 500;
		songsText.cameras = [menuCam];
		add(songsText);

		difficulty = Util.createGraphicSprite(0, 680, Path.image("difficulty-normal"), 1.4);
		difficulty.screenCenter(X);
		difficulty.x += 550;
		difficulty.y -= difficulty.height * .5;
		difficulty.cameras = [menuCam];
		add(difficulty);

		leftArrow = Util.createSparrowSprite(0, difficulty.y, "storyModeAssets", 1.5);
		leftArrow.animation.addByPrefix("push", "arrow push left", 24);
		leftArrow.animation.addByPrefix("idle", "arrow left", 24);
		leftArrow.animation.play("idle");
		leftArrow.screenCenter(X);
		leftArrow.x = difficulty.x - (leftArrow.width + 25);
		leftArrow.cameras = [menuCam];
		add(leftArrow);

		rightArrow = Util.createSparrowSprite(0, difficulty.y, "storyModeAssets", 1.5);
		rightArrow.animation.addByPrefix("push", "arrow push right", 24);
		rightArrow.animation.addByPrefix("idle", "arrow right", 24);
		rightArrow.animation.play("idle");
		rightArrow.screenCenter(X);
		rightArrow.x = difficulty.x + difficulty.width + 25;
		rightArrow.cameras = [menuCam];
		add(rightArrow);
	}

	public inline function createMenuOptions():Void {}
}
