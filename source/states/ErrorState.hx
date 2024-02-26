package states;

import haxe.Exception;

class ErrorState extends MusicState
{
	var errorTitle:FlxText;
	var errorInfo:FlxText;

	public override function create()
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.resume();
			FlxG.sound.music.volume = 1;
		}

		errorTitle = Util.createText(FlxG.width / 2, -100, "ERROR", 96, "assets/fonts/vcr.ttf", 0xFFFF0000, CENTER);
		errorTitle.x -= errorTitle.width / 2;
		add(errorTitle);
		FlxTween.tween(errorTitle, {y: 100}, 1, {
			type: ONESHOT,
			ease: FlxEase.expoOut
		});
		errorInfo = Util.createText(FlxG.width / 2, -100, MusicState.errorText, 36, "assets/fonts/vcr.ttf", 0xFFFF0000, CENTER);
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

	public static function error(?err:Exception, description:String, errorState:Bool = false):Void
	{
		MusicState.errorText += '$description\n' + err == null ? '' : err.details();
		if (errorState)
			MusicState.switchState(new ErrorState());
	}
}
