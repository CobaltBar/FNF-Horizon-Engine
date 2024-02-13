package states;

class ErrorState extends MusicState
{
	public static var errorText:String;

	var errorTitle:FlxText;
	var errorInfo:FlxText;

	public override function create()
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.resume();
			FlxG.sound.music.volume = 1;
		}
		bpm = TitleState.titleData.bpm ?? 0;
		errorTitle = Util.createText(FlxG.width / 2, -100, "ERROR", 96, "assets/fonts/vcr.ttf", 0xFFFF0000, CENTER);
		errorTitle.x -= errorTitle.width / 2;
		add(errorTitle);
		FlxTween.tween(errorTitle, {y: 100}, 1, {
			type: ONESHOT,
			ease: FlxEase.expoOut
		});
		errorInfo = Util.createText(FlxG.width / 2, -100, errorText, 36, "assets/fonts/vcr.ttf", 0xFFFF0000, CENTER);
		errorInfo.x -= errorInfo.width / 2;
		add(errorInfo);
		FlxTween.tween(errorInfo, {y: 500}, 1, {
			type: ONESHOT,
			ease: FlxEase.expoOut
		});

		super.create();
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("back")))
		{
			@:privateAccess TitleState.comingBack = false;
			MusicState.switchState(new TitleState());
		}
		super.update(elapsed);
	}
}
