package states;

import flixel.math.FlxRect;
import modding.Mod;
import modding.ModManager;

class ModsMenuState extends MusicMenuState
{
	var enabledModBG:FlxSprite;
	var allModBG:FlxSprite;
	var modDescBG:FlxSprite;
	var allModsText:Alphabet;
	var enabledModsText:Alphabet;

	var curEnabled:Int = 0;
	var enabledOptions:Array<FlxSprite> = [];
	var enableSelected:Bool = false;

	public override function create()
	{
		setupMenu();
		createMenuBG();
		createModUI();
		shouldBop = false;
		createModOptions(ModManager.discoveredMods, ModManager.enabledMods);
		changeSelection(0, false);
		changeSection(false);
		changeSection(false);
		super.create();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([
			Settings.data.keybinds.get("ui")[0],
			Settings.data.keybinds.get("ui")[4],
			Settings.data.keybinds.get("ui")[3],
			Settings.data.keybinds.get("ui")[7]
		]) && !transitioningOut)
			changeSection();

		// TODO FIX THE DAMN BOTTOM CLIP (maybe with a key to change the val :3)
		for (i in 0...menuOptions.length)
		{
			menuOptions[i].x = FlxMath.lerp(menuOptions[i].x, FlxG.width - 50 - (allModBG.width + menuOptions[i].width) / 2, elapsed * 5);
			menuOptions[i].y = FlxMath.lerp(menuOptions[i].y, 250 - (curSelected - i) * 100, elapsed * 5);
			menuOptions[i].clipRect = FlxRect.weak(0,
				Math.floor(menuOptions[i].y < 250 ? -menuOptions[i].height - 10 - (menuOptions[i].y - 250) : -menuOptions[i].height - 10),
				menuOptions[i].width, Math.floor(menuOptions[i].y > 789 ? menuOptions[i].height - (menuOptions[i].y - 789) : menuOptions[i].height));
			menuOptions[i].clipRect = menuOptions[i].clipRect;
		}
		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].x = FlxMath.lerp(enabledOptions[i].x, 50 + (enabledModBG.width - enabledOptions[i].width) / 2, elapsed * 5);
			enabledOptions[i].y = FlxMath.lerp(enabledOptions[i].y, 250 - (curEnabled - i) * 100, elapsed * 5);
			enabledOptions[i].clipRect = FlxRect.weak(0,
				Math.floor(enabledOptions[i].y < 250 ? -enabledOptions[i].height - 10 - (enabledOptions[i].y - 250) : -enabledOptions[i].height - 10),
				enabledOptions[i].width,
				Math.floor(enabledOptions[i].y > 789 ? enabledOptions[i].height - (enabledOptions[i].y - 789) : enabledOptions[i].height));
			enabledOptions[i].clipRect = enabledOptions[i].clipRect;
		}
	}

	public override function returnState()
	{
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false)
	{
		if (enableSelected)
		{
			if (enabledOptions.length <= 0)
				return;
			enabledOptions[curEnabled].alpha = 0.6;
			if (sound)
				FlxG.sound.play(Path.sound("Scroll"), 0.7);

			set ? curEnabled = change : curEnabled += change;

			if (curEnabled < 0)
				curEnabled = enabledOptions.length - 1;
			if (curEnabled >= enabledOptions.length)
				curEnabled = 0;
			enabledOptions[curEnabled].alpha = 1;
		}
		else
		{
			menuOptions[curSelected].alpha = 0.6;
			super.changeSelection(change, sound, set);
			menuOptions[curSelected].alpha = 1;
		}
	}

	public function changeSection(sound:Bool = true):Void
	{
		if (sound)
			FlxG.sound.play(Path.sound("Scroll"), 0.7);

		enableSelected = !enableSelected;

		if (enableSelected)
		{
			enabledModsText.alpha = 1;
			allModsText.alpha = 0.6;
		}
		else
		{
			enabledModsText.alpha = 0.6;
			allModsText.alpha = 1;
		}
	}

	public override function exitState()
	{
		if (!enableSelected)
		{
			enabledOptions.push(menuOptions[curSelected]);
			menuOptions.remove(menuOptions[curSelected]);
			changeSelection(0, false);
		}
		else {}
	}

	public function createModOptions(allMods:Array<Mod>, enabledMods:Array<Mod>):Void
	{
		for (i in 0...allMods.length)
		{
			if (enabledMods.contains(allMods[i]))
			{
				allMods.remove(allMods[i]);
				continue;
			}
			var option = new Alphabet(FlxG.width - 50 - allModBG.width / 2, 250 + (i * 100), allMods[i].name, true, CENTER, 1.2);
			option.cameras = [optionsCam];
			option.clipRect = FlxRect.weak(0, -option.height - 10, option.width, option.height);
			option.clipRect = option.clipRect;
			option.alpha = 0.6;
			add(option);
			menuOptions.push(option);
		}

		for (i in 0...enabledMods.length)
		{
			var option = new Alphabet(50 + enabledModBG.width / 2, 250 + (i * 100), enabledMods[i].name, true, CENTER, 1.2);
			option.cameras = [optionsCam];
			option.clipRect = FlxRect.weak(0, -option.height - 10, option.width, option.height);
			option.clipRect = option.clipRect;
			option.alpha = 0.6;
			add(option);
			enabledOptions.push(option);
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
		enabledModBG.cameras = [menuCam];
		add(enabledModBG);

		allModBG = Util.makeSprite(50, 50, Std.int(FlxG.width / 2 - 80), Std.int(FlxG.height - 320), 0xBB000000);
		allModBG.cameras = [menuCam];
		allModBG.x = FlxG.width - 50 - allModBG.width;
		add(allModBG);

		modDescBG = Util.makeSprite(50, 50, Std.int(FlxG.width - 100), 180, 0xBB000000);
		modDescBG.cameras = [menuCam];
		modDescBG.y = FlxG.height - 50 - modDescBG.height;
		add(modDescBG);

		enabledModsText = new Alphabet(50 + (enabledModBG.width / 2), 150, "Enabled Mods", true, CENTER);
		enabledModsText.cameras = [menuCam];
		enabledModsText.alpha = 0.6;
		add(enabledModsText);
		allModsText = new Alphabet(FlxG.width - 50 - (allModBG.width / 2), 150, "All Mods", true, CENTER);
		allModsText.alpha = 0.6;
		allModsText.cameras = [menuCam];
		add(allModsText);
	}
}
