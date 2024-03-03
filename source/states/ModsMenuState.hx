package states;

import flixel.math.FlxRect;
import haxe.ui.components.Button;
import haxe.ui.containers.menus.Menu;
import modding.Mod;
import modding.ModManager;

class ModsMenuState extends MusicMenuState
{
	public override function create()
	{
		setupMenu();
		shouldBop = false;
		createMenuBG();

		var hbox = new Menu();
		hbox.cameras = [optionsCam];
		hbox.screenCenter();
		var button = new Button();

		button.text = "hi chat";
		button.fontSize = 24;
		button.cameras = [optionsCam];
		hbox.addComponent(button);
		add(hbox);
		super.create();
	}

	public override function returnState()
	{
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public inline function createMenuBG():Void
	{
		bg = Util.createBackdrop(Path.image("menuBGDesat"), 1.7);
		bg.cameras = [menuCam];
		add(bg);
	}
}
