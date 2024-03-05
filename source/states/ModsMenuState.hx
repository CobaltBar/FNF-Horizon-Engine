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
	var modOption:Map<Alphabet, Mod> = [];
	var curEnabled:Int = 0;
	var enabledOptions:Array<FlxSprite> = [];
	var enabled:Bool = false;

	public override function create():Void
	{
		setupMenu();
		createMenuBG();
		createModUI();
		shouldBop = false;
		createModOptions(ModManager.allMods, ModManager.enabledMods);
		changeSelection(0, false);
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if (FlxG.keys.anyJustPressed([
			Settings.data.keybinds.get("ui")[0],
			Settings.data.keybinds.get("ui")[4],
			Settings.data.keybinds.get("ui")[3],
			Settings.data.keybinds.get("ui")[7]
		]) && !transitioningOut)
			changeSection();

		for (i in 0...menuOptions.length)
		{
			menuOptions[i].x = FlxMath.lerp(menuOptions[i].x, FlxG.width - 50 - (allModBG.width + menuOptions[i].width) / 2, elapsed * 5);
			menuOptions[i].y = FlxMath.lerp(menuOptions[i].y, 250 - (curSelected - i) * 100, elapsed * 5);
			menuOptions[i].clipRect = FlxRect.weak(0,
				Std.int(menuOptions[i].y < 250 ? -menuOptions[i].height - 10 - (menuOptions[i].y - 250) : -menuOptions[i].height - 10), menuOptions[i].width,
				Std.int(menuOptions[i].y > 800 ? menuOptions[i].height - (menuOptions[i].y - 800) : menuOptions[i].height));
			menuOptions[i].clipRect = menuOptions[i].clipRect;
		}
		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].x = FlxMath.lerp(enabledOptions[i].x, 50 + (enabledModBG.width - enabledOptions[i].width) / 2, elapsed * 5);
			enabledOptions[i].y = FlxMath.lerp(enabledOptions[i].y, 250 - (curEnabled - i) * 100, elapsed * 5);
			enabledOptions[i].clipRect = FlxRect.weak(0,
				Std.int(enabledOptions[i].y < 250 ? -enabledOptions[i].height - 10 - (enabledOptions[i].y - 250) : -enabledOptions[i].height - 10),
				enabledOptions[i].width,
				Std.int(enabledOptions[i].y > 789 ? enabledOptions[i].height - (enabledOptions[i].y - 789) : enabledOptions[i].height));
			enabledOptions[i].clipRect = enabledOptions[i].clipRect;
		}
	}

	public override function returnState():Void
	{
		for (val in modOption)
			ModManager.enabledMods.push(val);
		haxe.ds.ArraySort.sort(ModManager.enabledMods, (a, b) ->
		{
			if (a.ID < b.ID)
				return -1;
			else if (a.ID > b.ID)
				return 1;
			else
				return 0;
		});
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false):Void
	{
		if (enabled)
		{
			if (enabledOptions.length <= 0)
				return;
			if (enabledOptions[curEnabled] != null)
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
			if (menuOptions.length <= 0)
				return;
			if (menuOptions[curSelected] != null)
				menuOptions[curSelected].alpha = 0.6;
			super.changeSelection(change, sound, set);
			menuOptions[curSelected].alpha = 1;
		}
	}

	public function changeSection(sound:Bool = true):Void
	{
		if (sound)
			FlxG.sound.play(Path.sound("Scroll"), 0.7);
		enabled = !enabled;

		if (enabled)
		{
			if (menuOptions.length > 0)
				menuOptions[curSelected].alpha = 0.6;
			if (enabledOptions.length > 0)
				enabledOptions[curEnabled].alpha = 1;
			enabledModsText.alpha = 1;
			allModsText.alpha = 0.6;
		}
		else
		{
			if (enabledOptions.length > 0)
				enabledOptions[curEnabled].alpha = 0.6;
			if (menuOptions.length > 0)
				menuOptions[curSelected].alpha = 1;
			enabledModsText.alpha = 0.6;
			allModsText.alpha = 1;
		}
	}

	public override function exitState():Void
	{
		if (enabled)
		{
			if (enabledOptions.length <= 0)
				return;
			enabledOptions[curEnabled].alpha = 0.6;
			menuOptions.push(enabledOptions[curEnabled]);
			enabledOptions.remove(enabledOptions[curEnabled]);
		}
		else
		{
			if (menuOptions.length <= 0)
				return;
			menuOptions[curSelected].alpha = 0.6;
			enabledOptions.push(menuOptions[curSelected]);
			menuOptions.remove(menuOptions[curSelected]);
		}
		changeSelection(0, false);
	}

	public function createModOptions(allMods:Array<Mod>, enabledMods:Array<Mod>):Void
	{
		for (i in 0...allMods.length)
		{
			var option = new Alphabet(FlxG.width - 50 - allModBG.width / 2, 250 + (i * 1000), allMods[i].name, true, CENTER, 1.2, 0, 0, null, 0,
				haxe.io.Path.normalize(allMods[i].icon));
			modOption.set(option, allMods[i]);
			option.cameras = [optionsCam];
			option.clipRect = FlxRect.weak(0, -option.height - 10, option.width, option.height);
			option.clipRect = option.clipRect;
			option.alpha = 0.6;
			add(option);
			menuOptions.push(option);
		}

		for (i in 0...enabledMods.length)
		{
			var option = new Alphabet(50 + enabledModBG.width / 2, 250 + (i * 100), enabledMods[i].name, true, CENTER, 1.2, 0, 0, null, 0, allMods[i].icon);
			modOption.set(option, enabledMods[i]);
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
		allModsText.cameras = [menuCam];
		add(allModsText);
	}
}
