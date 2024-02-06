package abstractions;

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

	public function setupMenu():Void
	{
		menuCam = Util.createCamera(true);
		optionsCam = Util.createCamera(true);
		otherCam = Util.createCamera(true);
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

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[1], Settings.data.keybinds.get("ui")[5]]) && !transitioningOut)
			changeSelection(1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[2], Settings.data.keybinds.get("ui")[6]]) && !transitioningOut)
			changeSelection(-1);

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")) && !transitioningOut)
			exitState();

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("back")) && !transitioningOut)
			returnState();

		super.update(elapsed);
	}

	public function changeSelection(change:Int, set:Bool = false):Void
	{
		FlxG.sound.play("assets/sounds/Scroll.ogg", 0.7);
	}

	public function exitState():Void
	{
		transitioningOut = true;
		FlxG.sound.play("assets/sounds/Confirm.ogg", 0.7);
	}

	public function returnState():Void
	{
		transitioningOut = true;
		FlxG.sound.play("assets/sounds/Cancel.ogg", 0.7);
	}
}
