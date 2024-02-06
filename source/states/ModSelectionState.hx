package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import modding.Mod;
import modding.ModManager;

class ModSelectionState extends MusicMenuState
{
	var backdrop:FlxBackdrop;
	var hue:Float = 0;

	public override function create():Void
	{
		setupMenu();
		createMenuBackdrop();
		createMenuOptions(ModManager.discoveredMods);
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		hue += elapsed * 15;
		hue %= 359;
		backdrop.color = FlxColor.fromHSB(hue, 1, 1);
	}

	public function createMenuOptions(mods:Array<Mod>):Void
	{
		for (i in 0...mods.length)
		{
			var option = new Alphabet(FlxG.width / 2, 200 + (i * 100), mods[i].name, true, CENTER, 1.2);
			option.cameras = [optionsCam];
			add(option);
		}
	}

	public function createMenuBackdrop():Void
	{
		backdrop = new FlxBackdrop(FlxGridOverlay.create(128, 128, 256, 256, true, 0xffffffff, 0xffcccccc).graphic);
		backdrop.velocity.set(50, 30);
		backdrop.screenCenter();
		backdrop.cameras = [menuCam];
		add(backdrop);
	}
}
