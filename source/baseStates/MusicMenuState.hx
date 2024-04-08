package baseStates;

import flixel.FlxObject;

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

	var handleInput:Bool = true;

	public function setupMenu():Void
	{
		menuCam = Util.createCamera(false, true);
		optionsCam = Util.createCamera(false, true);
		otherCam = Util.createCamera(true, true);
		menuFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
		optionsFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
		menuCam.follow(menuFollow, LOCKON, 0.1);
		optionsCam.follow(optionsFollow, LOCKON, 0.15);
		camerasToBop.push(menuCam);
		camerasToBop.push(optionsCam);
	}

	public override function update(elapsed:Float):Void
	{
		if (FlxG.sound.music != null && FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[1], Settings.data.keybinds.get("ui")[5]])
			&& !transitioningOut
			&& handleInput)
			changeSelection(1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[2], Settings.data.keybinds.get("ui")[6]])
			&& !transitioningOut
			&& handleInput)
			changeSelection(-1);

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")) && !transitioningOut && handleInput)
			exitState();

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("back")) && !transitioningOut && handleInput)
			returnState();

		super.update(elapsed);
	}

	public function changeSelection(change:Int, sound:Bool = true, set:Bool = false):Void
	{
		if (sound)
			FlxG.sound.play(Path.sound("Scroll"), 0.7);

		set ? curSelected = change : curSelected += change;

		if (curSelected < 0)
			curSelected = menuOptions.length - 1;
		if (curSelected >= menuOptions.length)
			curSelected = 0;
	}

	public function exitState():Void
	{
		transitioningOut = true;
		FlxG.sound.play(Path.sound("Confirm"), 0.7);
	}

	public function returnState():Void
	{
		transitioningOut = true;
		FlxG.sound.play(Path.sound("Cancel"), 0.7);
	}
}
