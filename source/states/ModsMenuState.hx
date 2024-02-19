package states;

import modding.Mod;
import modding.ModManager;

class ModsMenuState extends MusicMenuState
{
	var enabledModBG:FlxSprite;
	var allModBG:FlxSprite;
	var modDescBG:FlxSprite;

	public override function create()
	{
		setupMenu();
		createMenuBG();
		createModUI();
		createModOptions(ModManager.discoveredMods, ModManager.enabledMods);
		changeSelection(0, false);
		super.create();
	}

	public override function returnState()
	{
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false) {}

	public override function exitState() {}

	public function createModOptions(allMods:Array<Mod>, enabledMods:Array<Mod>):Void
	{
		for (i in 0...allMods.length)
		{
			if (enabledMods.contains(allMods[i]))
			{
				allMods.remove(allMods[i]);
				continue;
			}
			var option = new Alphabet(FlxG.width - 50 - allModBG.width / 2, 250, allMods[i].name, true, CENTER, 1.2);
			option.cameras = [optionsCam];
			option.alpha = 0.6;
			add(option);
			menuOptions.push(option);
		}
	}

	public function createMenuBG():Void
	{
		bg = Util.createBackdrop(Path.image("menuBGDesat"), 1.7);
		bg.cameras = [menuCam];
		add(bg);
	}

	public function createModUI():Void
	{
		enabledModBG = Util.makeSprite(50, 50, Std.int(FlxG.width / 2 - 80), Std.int(FlxG.height - 320), 0xBB000000);
		enabledModBG.cameras = [otherCam];
		add(enabledModBG);

		allModBG = Util.makeSprite(50, 50, Std.int(FlxG.width / 2 - 80), Std.int(FlxG.height - 320), 0xBB000000);
		allModBG.cameras = [otherCam];
		allModBG.x = FlxG.width - 50 - allModBG.width;
		add(allModBG);

		modDescBG = Util.makeSprite(50, 50, Std.int(FlxG.width - 100), 180, 0xBB000000);
		modDescBG.cameras = [otherCam];
		modDescBG.y = FlxG.height - 50 - modDescBG.height;
		add(modDescBG);

		add(new Alphabet(50 + (enabledModBG.width / 2), 150, "Enabled Mods", true, CENTER));
		add(new Alphabet(FlxG.width - 50 - (allModBG.width / 2), 150, "All Mods", true, CENTER));
	}
}
