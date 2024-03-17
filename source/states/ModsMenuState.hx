package states;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;
import modding.Mod;
import modding.ModManager;
import openfl.display.BitmapData;
import sys.FileSystem;

class ModsMenuState extends MusicMenuState
{
	var enabledModBG:FlxSprite;
	var allModBG:FlxSprite;
	var allModsText:Alphabet;
	var enabledModsText:Alphabet;
	var modIcon:FlxSprite;
	var modDesc:FlxText;

	var curEnabled:Int = 0;
	var enabledOptions:Array<ModAlphabet> = [];
	var enabled:Bool = false;

	public override function create():Void
	{
		setupMenu();
		createMenuBG();
		createModUI();
		shouldBop = handleInput = false;
		createModOptions(ModManager.disabledMods, ModManager.enabledMods);
		changeSelection(0, false);
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[5]]) && !transitioningOut)
			changeSelection(1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[6]]) && !transitioningOut)
			changeSelection(-1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[2]]) && !transitioningOut)
		{
			if (enabled)
			{
				var option1 = enabledOptions[curEnabled];
				var guh = curEnabled - 1;
				if (guh < 0)
					guh = enabledOptions.length - 1;
				if (guh >= enabledOptions.length)
					guh = 0;
				var option2 = enabledOptions[guh];
				enabledOptions[guh] = option1;
				enabledOptions[curEnabled].alpha = .6;
				enabledOptions[curEnabled] = option2;
				curEnabled -= 1;
			}
			else
			{
				var option1 = menuOptions[curSelected];
				var guh = curSelected - 1;
				if (guh < 0)
					guh = menuOptions.length - 1;
				if (guh >= menuOptions.length)
					guh = 0;
				var option2 = menuOptions[guh];
				menuOptions[guh] = option1;
				menuOptions[curSelected].alpha = .6;
				menuOptions[curSelected] = option2;
				curSelected -= 1;
			}
			changeSelection(0, false);
		}

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[1]]) && !transitioningOut)
		{
			if (enabled)
			{
				var option1 = enabledOptions[curEnabled];
				var guh = curEnabled + 1;
				if (guh < 0)
					guh = enabledOptions.length - 1;
				if (guh >= enabledOptions.length)
					guh = 0;
				var option2 = enabledOptions[guh];
				enabledOptions[guh] = option1;
				enabledOptions[curEnabled].alpha = .6;
				enabledOptions[curEnabled] = option2;
				curEnabled += 1;
			}
			else
			{
				var option1 = menuOptions[curSelected];
				var guh = curSelected + 1;
				if (guh < 0)
					guh = menuOptions.length - 1;
				if (guh >= menuOptions.length)
					guh = 0;
				var option2 = menuOptions[guh];
				menuOptions[guh] = option1;
				menuOptions[curSelected].alpha = .6;
				menuOptions[curSelected] = option2;
				curSelected += 1;
			}
			changeSelection(0, false);
		}

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")) && !transitioningOut)
			exitState();

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("back")) && !transitioningOut)
			returnState();

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
			menuOptions[i].y = FlxMath.lerp(menuOptions[i].y, 250 - (curSelected - i - 1) * 100, elapsed * 5);
			menuOptions[i].clipRect = FlxRect.weak(0,
				Std.int(menuOptions[i].y < 250 ? -menuOptions[i].height - 10 - (menuOptions[i].y - 250) : -menuOptions[i].height - 10), menuOptions[i].width,
				Std.int(menuOptions[i].y > 800 ? menuOptions[i].height - (menuOptions[i].y - 800) : menuOptions[i].height));
			menuOptions[i].clipRect = menuOptions[i].clipRect;
		}
		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].x = FlxMath.lerp(enabledOptions[i].x, 50 + (enabledModBG.width - enabledOptions[i].width) / 2, elapsed * 5);
			enabledOptions[i].y = FlxMath.lerp(enabledOptions[i].y, 250 - (curEnabled - i - 1) * 100, elapsed * 5);
			enabledOptions[i].clipRect = FlxRect.weak(0,
				Std.int(enabledOptions[i].y < 250 ? -enabledOptions[i].height - 10 - (enabledOptions[i].y - 250) : -enabledOptions[i].height - 10),
				enabledOptions[i].width,
				Std.int(enabledOptions[i].y > 789 ? enabledOptions[i].height - (enabledOptions[i].y - 789) : enabledOptions[i].height));
			enabledOptions[i].clipRect = enabledOptions[i].clipRect;
		}
	}

	public override function returnState():Void
	{
		ModManager.enabledMods = [];
		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].mod.ID = i;
			ModManager.enabledMods.push(enabledOptions[i].mod);
		}

		haxe.ds.ArraySort.sort(ModManager.enabledMods, (a, b) ->
		{
			return a.ID < b.ID ? -1 : a.ID > b.ID ? 1 : 0;
		});
		Settings.data.savedMods = ModManager.enabledMods;
		super.returnState();
		Settings.save();
		MusicState.switchState(new MainMenuState());
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false):Void
	{
		if (enabled)
		{
			if (enabledOptions.length <= 0)
				return;
			if (enabledOptions[curEnabled] != null)
				enabledOptions[curEnabled].alpha = .6;
			if (sound)
				FlxG.sound.play(Path.sound("Scroll"), 0.7);
			set ? curEnabled = change : curEnabled += change;
			if (curEnabled < 0)
				curEnabled = enabledOptions.length - 1;
			if (curEnabled >= enabledOptions.length)
				curEnabled = 0;
			enabledOptions[curEnabled].alpha = 1;

			modDesc.text = enabledOptions[curEnabled].mod.description;
			modIcon.loadGraphic(enabledOptions[curEnabled].iconGraphic);
		}
		else
		{
			if (menuOptions.length <= 0)
				return;
			if (menuOptions[curSelected] != null)
				menuOptions[curSelected].alpha = .6;
			super.changeSelection(change, sound, set);
			menuOptions[curSelected].alpha = 1;

			modDesc.text = cast(menuOptions[curSelected], ModAlphabet).mod.description;
			modIcon.loadGraphic(cast(menuOptions[curSelected], ModAlphabet).iconGraphic);
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
				menuOptions[curSelected].alpha = .6;
			if (enabledOptions.length > 0)
				enabledOptions[curEnabled].alpha = 1;
			enabledModsText.alpha = 1;
			allModsText.alpha = .6;
		}
		else
		{
			if (enabledOptions.length > 0)
				enabledOptions[curEnabled].alpha = .6;
			if (menuOptions.length > 0)
				menuOptions[curSelected].alpha = 1;
			enabledModsText.alpha = .6;
			allModsText.alpha = 1;
		}
	}

	public override function exitState():Void
	{
		if (enabled)
		{
			if (enabledOptions.length <= 0)
				return;
			enabledOptions[curEnabled].alpha = .6;
			menuOptions.push(enabledOptions[curEnabled]);
			enabledOptions.remove(enabledOptions[curEnabled]);
		}
		else
		{
			if (menuOptions.length <= 0)
				return;
			menuOptions[curSelected].alpha = .6;
			enabledOptions.push(cast menuOptions[curSelected]);
			menuOptions.remove(menuOptions[curSelected]);
		}
		changeSelection(0, false);
	}

	public function createModOptions(allMods:Array<Mod>, enabledMods:Array<Mod>):Void
	{
		for (i in 0...allMods.length)
		{
			if (enabledMods.contains(allMods[i]))
				continue;
			var option = new ModAlphabet(FlxG.width - 50 - allModBG.width / 2, 250 + ((i + 1) * 100), allMods[i].name, true, CENTER, 1.2);
			option.mod = allMods[i];
			option.iconGraphic = BitmapData.fromFile(allMods[i].icon);
			option.cameras = [optionsCam];
			option.clipRect = FlxRect.weak(0, -option.height - 10, option.width, option.height);
			option.clipRect = option.clipRect;
			option.alpha = .6;
			add(option);
			menuOptions.push(option);
		}

		for (i in 0...enabledMods.length)
		{
			var option = new ModAlphabet(50 + enabledModBG.width / 2, 250 + ((i + 1) * 100), enabledMods[i].name, true, CENTER, 1.2);
			option.mod = enabledMods[i];
			option.iconGraphic = BitmapData.fromFile(enabledMods[i].icon);
			option.cameras = [optionsCam];
			option.clipRect = FlxRect.weak(0, -option.height - 10, option.width, option.height);
			option.clipRect = option.clipRect;
			option.alpha = .6;
			add(option);
			enabledOptions.push(option);
		}
	}

	public inline function createMenuBG():Void
	{
		bg = Util.createBackdrop(Path.image("menuBGDesat"), 1.7);
		bg.cameras = [menuCam];
		add(bg);
	}

	public inline function createModUI():Void
	{
		enabledModBG = Util.makeSprite(50, 50, Std.int(FlxG.width / 2 - 80), Std.int(FlxG.height - 320), 0xBB000000);
		enabledModBG.cameras = [menuCam];
		add(enabledModBG);

		allModBG = Util.makeSprite(0, 50, Std.int(FlxG.width / 2 - 80), Std.int(FlxG.height - 320), 0xBB000000);
		allModBG.cameras = [menuCam];
		allModBG.x = FlxG.width - 50 - allModBG.width;
		add(allModBG);

		var modInfoBG = Util.makeSprite(50, 0, Std.int(FlxG.width - (100 + 790 + 50)), 180, 0xBB000000);
		modInfoBG.cameras = [menuCam];
		modInfoBG.y = FlxG.height - 50 - modInfoBG.height;
		add(modInfoBG);

		var controlsDescBG:FlxSprite = Util.makeSprite(0, 0, 790, 180, 0xBB000000);
		controlsDescBG.cameras = [menuCam];
		controlsDescBG.x = FlxG.width - 50 - controlsDescBG.width;
		controlsDescBG.y = FlxG.height - 50 - modInfoBG.height;
		add(controlsDescBG);

		var controlsDescText:FlxSprite = Util.createText(FlxG.width - 50 - controlsDescBG.width, FlxG.height - 50 - modInfoBG.height,
			'Controls\nMove selection up/down: ${Settings.data.keybinds.get("ui")[6].toString()}/${Settings.data.keybinds.get("ui")[5].toString()}\nMove current option up/down: ${Settings.data.keybinds.get("ui")[2].toString()}/${Settings.data.keybinds.get("ui")[1].toString()}',
			36, Path.font("vcr"), 0xFFFFFFFF, LEFT);
		controlsDescText.cameras = [menuCam];
		add(controlsDescText);

		enabledModsText = new Alphabet(50 + (enabledModBG.width / 2), 150, "Enabled Mods", true, CENTER);
		enabledModsText.cameras = [menuCam];
		enabledModsText.alpha = .6;
		add(enabledModsText);

		allModsText = new Alphabet(FlxG.width - 50 - (allModBG.width / 2), 150, "All Mods", true, CENTER);
		allModsText.cameras = [menuCam];
		add(allModsText);

		modIcon = Util.createGraphicSprite(70, 0, Path.image("unknownMod"), 1.2);
		modIcon.y = FlxG.height - 50 - modIcon.height;
		modIcon.cameras = [menuCam];
		add(modIcon);

		modDesc = Util.createText(0, 0, "", 36, Path.font("vcr"), 0xFFFFFFFF, LEFT);
		modDesc.x = 60 + modIcon.width;
		modDesc.y = FlxG.height - 40 - modInfoBG.height;
		modDesc.cameras = [menuCam];
		add(modDesc);
	}
}

// lazy
class ModAlphabet extends Alphabet
{
	public var mod:Mod;
}
