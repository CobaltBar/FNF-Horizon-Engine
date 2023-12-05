package states;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;

class MainMenuState extends MusicState
{
	var menuBG:FlxSprite;
	var menuBGFlash:FlxSprite;
	var menuBGCam:FlxCamera;

	var menuOptions:FlxSpriteGroup;
	var menuOptionsCam:FlxCamera;

	public override function create():Void
	{
		menuBGCam = new FlxCamera(0, 0, FlxG.width, FlxG.height);
		FlxG.cameras.add(menuBGCam, false);

		menuBG = Util.createSprite(200, 200, "assets/images/menuBG.png");
		menuBG.screenCenter(X);
		menuBG.cameras = [menuBGCam];
		add(menuBG);

		super.create();
	}
}
