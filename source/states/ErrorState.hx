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

		errorTitle = Util.createText(FlxG.width / 2, -100, "ERROR", 96, Path.font("vcr"), 0xFFFF0000, CENTER);
		errorTitle.x -= errorTitle.width / 2;
		add(errorTitle);
		FlxTween.tween(errorTitle, {y: 100}, 1, {
			type: ONESHOT,
			ease: FlxEase.expoOut
		});
		errorInfo = Util.createText(100, -100, MusicState.errorText, 24, Path.font("vcr"), 0xFFFF0000, LEFT);
		add(errorInfo);
		FlxTween.tween(errorInfo, {y: 300}, 1, {
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
			TitleState.titleData = null;
			MusicState.errorText = "";
			MusicState.erroring = false;
			Conductor.bpm = 100;
			Conductor.song = null;
			FlxG.sound.music.destroy();
			FlxG.sound.music = null;
			MusicState.switchState(new TitleState());
		}
		super.update(elapsed);
	}

	public static function error(?err:Exception, description:String, errorState:Bool = false):Void
	{
		MusicState.errorText += '$description\n' + (err == null ? '' : err.details()) + '\n';
		trace('$description\n' + (err == null ? '' : err.details()) + '\n');
		if (errorState)
		{
			MusicState.erroring = true;
			MusicState.switchState(new ErrorState());
		}
	}
}
