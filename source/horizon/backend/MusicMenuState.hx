package horizon.backend;

class MusicMenuState extends MusicState
{
	var curSelected:Int = 0;
	var menuOptions:Array<FlxSprite> = [];

	var menuCam:FlxCamera;
	var optionsCam:FlxCamera;
	var otherCam:FlxCamera;

	var menuFollow:FlxObject;
	var optionsFollow:FlxObject;

	var bg:FlxSprite;

	var customInput:Bool = false;
	var setupCams:Bool = true;

	public override function create():Void
	{
		if (setupCams)
		{
			menuCam = Create.camera();
			optionsCam = Create.camera();
			otherCam = Create.camera();
			menuFollow = new FlxObject(FlxG.width * .5, FlxG.height * .5);
			optionsFollow = new FlxObject(FlxG.width * .5, FlxG.height * .5);
			menuCam.follow(menuFollow, LOCKON, .1);
			optionsCam.follow(optionsFollow, LOCKON, .15);
			bopCams.push(menuCam);
			bopCams.push(optionsCam);
		}

		super.create();

		if (!customInput)
		{
			Controls.onPress(Settings.keybinds['ui_down'], () -> if (!transitioningOut) changeSelection(1));
			Controls.onPress(Settings.keybinds['ui_up'], () -> if (!transitioningOut) changeSelection(-1));
			Controls.onPress(Settings.keybinds['accept'], () -> if (!transitioningOut) exitState());
			Controls.onPress(Settings.keybinds['back'], () -> if (!transitioningOut) returnState());
		}
	}

	public override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < .8)
			FlxG.sound.music.volume += .5 * elapsed;
		super.update(elapsed);
	}

	public override function destroy():Void
	{
		menuFollow.destroy();
		optionsFollow.destroy();
		super.destroy();
	}

	public function changeSelection(change:Int):Void
	{
		if (change != 0)
			FlxG.sound.play(Path.audio('scroll'), .7);

		curSelected = FlxMath.wrap(curSelected + change, 0, menuOptions.length - 1);
	}

	public function exitState():Void
	{
		transitioningOut = true;
		FlxG.sound.play(Path.audio('confirm'), .7);
	}

	public function returnState():Void
	{
		transitioningOut = true;
		FlxG.sound.play(Path.audio('cancel'), .7);
	}
}
