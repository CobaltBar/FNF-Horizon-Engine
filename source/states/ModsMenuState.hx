package states;

import flixel.math.FlxRect;
import modding.Mod;
import modding.ModManager;

class ModsMenuState extends MusicMenuState
{
	var curEnabled:Int = 0;
	var curStatic:Int = 0;

	var enabledOptions:Array<Alphabet> = [];
	var staticOptions:Array<Alphabet> = [];

	var enabledTitle:FlxSprite;
	var staticTitle:FlxSprite;
	var allModsTitle:FlxSprite;

	var modIcon:FlxSprite;
	var modDesc:FlxText;
	var targetColor:FlxColor;

	var curSection:Int = 1;
	var theWidth = Std.int(FlxG.width / 3 - 100 / 3);

	var theStaticOption:Alphabet;

	public override function create():Void
	{
		Path.clearStoredMemory();
		setupMenu();
		createMenuBG();
		createModUI();
		targetColor = FlxColor.WHITE;
		shouldBop = handleInput = false;
		createModOptions();
		changeSection(0, false);
		changeSelection(0, false);
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (i in 0...staticOptions.length)
		{
			staticOptions[i].y = FlxMath.lerp(staticOptions[i].y, 200 - (50 * (curStatic - i)), FlxMath.bound(elapsed * 5, 0, 1));
			staticOptions[i].clipRect = FlxRect.weak(0,
				staticOptions[i].y < 150 ? -staticOptions[i].height - (staticOptions[i].y - 150) : -staticOptions[i].height, staticOptions[i].width + 10,
				staticOptions[i].y > 792 ? staticOptions[i].height * 2 - (staticOptions[i].y - 792) : staticOptions[i].height * 2);
			staticOptions[i].clipRect = staticOptions[i].clipRect;
		}

		for (i in 0...menuOptions.length)
		{
			menuOptions[i].x = FlxMath.lerp(menuOptions[i].x, (FlxG.width - menuOptions[i].width) * .5, FlxMath.bound(elapsed * 5, 0, 1));
			menuOptions[i].y = FlxMath.lerp(menuOptions[i].y, 200 - (50 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1));
			menuOptions[i].clipRect = FlxRect.weak(0, menuOptions[i].y < 150 ? -menuOptions[i].height - (menuOptions[i].y - 150) : -menuOptions[i].height,
				menuOptions[i].width + 10, menuOptions[i].y > 792 ? menuOptions[i].height * 2 - (menuOptions[i].y - 792) : menuOptions[i].height * 2);
			menuOptions[i].clipRect = menuOptions[i].clipRect;
		}

		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].x = FlxMath.lerp(enabledOptions[i].x, (FlxG.width - enabledOptions[i].width) * .5 + theWidth + 25,
				FlxMath.bound(elapsed * 5, 0, 1));
			enabledOptions[i].y = FlxMath.lerp(enabledOptions[i].y, 200 - (50 * (curEnabled - i)), FlxMath.bound(elapsed * 5, 0, 1));

			enabledOptions[i].clipRect = FlxRect.weak(0,
				enabledOptions[i].y < 150 ? -enabledOptions[i].height - (enabledOptions[i].y - 150) : -enabledOptions[i].height, enabledOptions[i].width + 10,
				enabledOptions[i].y > 792 ? enabledOptions[i].height * 2 - (enabledOptions[i].y - 792) : enabledOptions[i].height * 2);
			enabledOptions[i].clipRect = enabledOptions[i].clipRect;
		}

		bg.color = FlxColor.interpolate(bg.color, targetColor, FlxMath.bound(elapsed * 5, 0, 1));

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")) && !transitioningOut)
			exitState();

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("back")) && !transitioningOut)
			returnState();

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[2]]) && !transitioningOut)
			shiftSelection(1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[1]]) && !transitioningOut)
			shiftSelection(-1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[3], Settings.data.keybinds.get("ui")[7]]) && !transitioningOut)
			changeSection(1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[0], Settings.data.keybinds.get("ui")[4]]) && !transitioningOut)
			changeSection(-1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[5]]) && !transitioningOut)
			changeSelection(1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[6]]) && !transitioningOut)
			changeSelection(-1);
	}

	public override function exitState():Void
		switch (curSection)
		{
			case 0:
				if (staticOptions.length <= 0)
					return;
				staticOptions[curStatic].alpha = staticOptions[curStatic].alpha == .8 ? .6 : .8;
				theStaticOption = staticOptions[curStatic];
			case 1:
				if (menuOptions.length <= 0)
					return;
				menuOptions[curSelected].alpha = .6;
				cast(menuOptions[curSelected], Alphabet).option.enabled = true;
				cast(menuOptions[curSelected], Alphabet).option.ID = enabledOptions.length - 1;
				enabledOptions.push(cast menuOptions[curSelected]);
				menuOptions.remove(menuOptions[curSelected]);
				changeSelection(0, false);
			case 2:
				if (enabledOptions.length <= 0)
					return;
				enabledOptions[curEnabled].alpha = .6;
				enabledOptions[curSelected].option.enabled = false;
				enabledOptions[curSelected].option.ID = menuOptions.length - 1;
				menuOptions.push(enabledOptions[curEnabled]);
				enabledOptions.remove(enabledOptions[curEnabled]);
				changeSelection(0, false);
		}

	public override function returnState():Void
	{
		ModManager.enabledMods = [];

		for (i in 0...menuOptions.length)
			ModManager.allMods[cast(menuOptions[i], Alphabet).option.path].ID = i;

		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].option.ID = i + 1;
			ModManager.enabledMods.insert(i + 1, enabledOptions[i].option);
		}

		haxe.ds.ArraySort.sort(ModManager.enabledMods, (a, b) ->
		{
			return a.ID < b.ID ? -1 : a.ID > b.ID ? 1 : 0;
		});

		theStaticOption.option.ID = 0;
		theStaticOption.option.enabled = true;
		ModManager.enabledMods.insert(0, theStaticOption.option);

		for (mod in ModManager.enabledMods)
			Settings.data.savedMods.set(mod.path, mod);

		super.returnState();
		Settings.save();
		MusicState.switchState(new MainMenuState());
	}

	public function shiftSelection(change:Int)
	{
		switch (curSection)
		{
			case 1:
				var newCurSelected = curSelected - change;
				if (newCurSelected < 0)
					newCurSelected = menuOptions.length - 1;
				if (newCurSelected >= menuOptions.length)
					newCurSelected = 0;
				var op1 = menuOptions[curSelected];
				var op2 = menuOptions[newCurSelected];
				op1.alpha = .6;
				menuOptions[curSelected] = op2;
				menuOptions[newCurSelected] = op1;
				curSelected -= change;
			case 2:
				var newCurEnabled = curEnabled - change;
				if (newCurEnabled < 0)
					newCurEnabled = enabledOptions.length - 1;
				if (newCurEnabled >= enabledOptions.length)
					newCurEnabled = 0;
				var op1 = enabledOptions[curEnabled];
				op1.alpha = .6;
				var op2 = enabledOptions[newCurEnabled];
				enabledOptions[curEnabled] = op2;
				enabledOptions[newCurEnabled] = op1;
				curEnabled -= change;
		}
		changeSelection(0, false);
	}

	public function changeSection(change:Int, sound:Bool = true, set:Bool = false):Void
	{
		if (sound)
			FlxG.sound.play(Path.sound("Scroll"), .7);

		set ? curSection = change : curSection += change;

		if (curSection < 0)
			curSection = 2;
		if (curSection > 2)
			curSection = 0;

		switch (curSection)
		{
			case 0:
				staticTitle.alpha = 1;
				allModsTitle.alpha = enabledTitle.alpha = .6;
				if (menuOptions[curSelected] != null)
					menuOptions[curSelected].alpha = .6;
				if (enabledOptions[curEnabled] != null)
					enabledOptions[curEnabled].alpha = .6;
			case 1:
				allModsTitle.alpha = 1;
				staticTitle.alpha = enabledTitle.alpha = .6;
				if (staticOptions[curStatic] != null && staticOptions[curStatic].alpha != .8)
					staticOptions[curStatic].alpha = .6;
				if (enabledOptions[curEnabled] != null)
					enabledOptions[curEnabled].alpha = .6;
			case 2:
				enabledTitle.alpha = 1;
				allModsTitle.alpha = staticTitle.alpha = .6;
				if (staticOptions[curStatic] != null && staticOptions[curStatic].alpha != .8)
					staticOptions[curStatic].alpha = .6;
				if (menuOptions[curSelected] != null)
					menuOptions[curSelected].alpha = .6;
		}
		changeSelection(0, false);
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false):Void
		switch (curSection)
		{
			case 0:
				if (staticOptions.length <= 0)
					return;
				if (staticOptions[curStatic] != null && staticOptions[curStatic].alpha != .8)
					staticOptions[curStatic].alpha = .6;
				if (sound)
					FlxG.sound.play(Path.sound("Scroll"), .7);
				set ? curStatic = change : curStatic += change;
				if (curStatic < 0)
					curStatic = staticOptions.length - 1;
				if (curStatic >= staticOptions.length)
					curStatic = 0;
				if (staticOptions[curStatic].alpha != .8)
					staticOptions[curStatic].alpha = 1;
				modIcon.loadGraphic(staticOptions[curStatic].option.icon);
				modDesc.text = staticOptions[curStatic].option.description;
				targetColor.red = staticOptions[curStatic].option.color[0];
				targetColor.green = staticOptions[curStatic].option.color[1];
				targetColor.blue = staticOptions[curStatic].option.color[2];
			case 1:
				if (menuOptions.length <= 0)
					return;
				if (menuOptions[curSelected] != null)
					menuOptions[curSelected].alpha = .6;
				super.changeSelection(change, sound, set);
				menuOptions[curSelected].alpha = 1;
				modIcon.loadGraphic(cast(menuOptions[curSelected], Alphabet).option.icon);
				modDesc.text = cast(menuOptions[curSelected], Alphabet).option.description;
				targetColor.red = cast(menuOptions[curSelected], Alphabet).option.color[0];
				targetColor.green = cast(menuOptions[curSelected], Alphabet).option.color[1];
				targetColor.blue = cast(menuOptions[curSelected], Alphabet).option.color[2];
			case 2:
				if (enabledOptions.length <= 0)
					return;
				if (enabledOptions[curEnabled] != null)
					enabledOptions[curEnabled].alpha = .6;
				if (sound)
					FlxG.sound.play(Path.sound("Scroll"), .7);
				set ? curEnabled = change : curEnabled += change;
				if (curEnabled < 0)
					curEnabled = enabledOptions.length - 1;
				if (curEnabled >= enabledOptions.length)
					curEnabled = 0;
				enabledOptions[curEnabled].alpha = 1;
				modIcon.loadGraphic(enabledOptions[curEnabled].option.icon);
				modDesc.text = enabledOptions[curEnabled].option.description;
				targetColor.red = enabledOptions[curEnabled].option.color[0];
				targetColor.green = enabledOptions[curEnabled].option.color[1];
				targetColor.blue = enabledOptions[curEnabled].option.color[2];
		}

	public inline function createMenuBG():Void
	{
		bg = Util.createBackdrop(Path.image("menuBGDesat"), 1.7);
		bg.cameras = [menuCam];
		add(bg);
	}

	public inline function createModUI():Void
	{
		var allModsBG = Util.makeSprite(0, 25, Std.int(FlxG.width / 3 - 100 / 3), FlxG.height - 275, 0xCC000000);
		allModsBG.screenCenter(X);
		allModsBG.cameras = [menuCam];
		add(allModsBG);

		var staticModsBG = Util.makeSprite(0, 25, Std.int(FlxG.width / 3 - 100 / 3), FlxG.height - 275, 0xCC000000);
		staticModsBG.screenCenter(X);
		staticModsBG.x -= staticModsBG.width + 25;
		staticModsBG.cameras = [menuCam];
		add(staticModsBG);

		var enabledModsBG = Util.makeSprite(0, 25, Std.int(FlxG.width / 3 - 100 / 3), FlxG.height - 275, 0xCC000000);
		enabledModsBG.screenCenter(X);
		enabledModsBG.x += enabledModsBG.width + 25;
		enabledModsBG.cameras = [menuCam];
		add(enabledModsBG);

		var descriptionBG = Util.makeSprite(25, FlxG.height - 225, Std.int(FlxG.width - 575), 200, 0xCC000000);
		descriptionBG.cameras = [menuCam];
		add(descriptionBG);

		modIcon = Util.createGraphicSprite(55, FlxG.height - 205, Path.image("unknownMod"), 1.2);
		modIcon.cameras = [menuCam];
		add(modIcon);

		modDesc = Util.createText(modIcon.width + 65, FlxG.height - 205, "N/A", 36, Path.font("vcr"), 0xFFFFFFFF, LEFT);
		modDesc.fieldWidth = 1100;
		modDesc.fieldHeight = 175;
		modDesc.cameras = [menuCam];
		add(modDesc);

		var controlsBG = Util.makeSprite(descriptionBG.width + 50, FlxG.height - 225, 500, 200, 0xCC000000);
		controlsBG.cameras = [menuCam];
		add(controlsBG);

		var controlsText = Util.createText(descriptionBG.width + 50, FlxG.height - 225,
			'Controls\nMove selection up/down: ${Settings.data.keybinds.get("ui")[6].toString()}/${Settings.data.keybinds.get("ui")[5].toString()}\nMove current option up/down: ${Settings.data.keybinds.get("ui")[2].toString()}/${Settings.data.keybinds.get("ui")[1].toString()}\nSelect Mod:${Settings.data.keybinds.get("accept")[0].toString()}/${Settings.data.keybinds.get("accept")[0].toString()}\nReturn to Main Menu:${Settings.data.keybinds.get("back")[0].toString()}/${Settings.data.keybinds.get("back")[1].toString()}',
			24, Path.font("vcr"), 0xFFFFFFFF, LEFT);
		controlsText.cameras = [menuCam];
		add(controlsText);

		allModsTitle = new Alphabet(0, 25, "All Mods", true, CENTER, .9);
		allModsTitle.screenCenter(X);
		allModsTitle.y += allModsTitle.height;
		allModsTitle.alpha = .6;
		allModsTitle.cameras = [menuCam];
		add(allModsTitle);

		staticTitle = new Alphabet(0, 25, "Static Mods", true, CENTER, .9);
		staticTitle.screenCenter(X);
		staticTitle.x -= staticModsBG.width + 25;
		staticTitle.y += staticTitle.height;
		staticTitle.alpha = .6;
		staticTitle.cameras = [menuCam];
		add(staticTitle);

		enabledTitle = new Alphabet(0, 25, "Enabled Mods", true, CENTER, .9);
		enabledTitle.screenCenter(X);
		enabledTitle.x += enabledModsBG.width + 25;
		enabledTitle.y += enabledTitle.height;
		enabledTitle.alpha = .6;
		enabledTitle.cameras = [menuCam];
		add(enabledTitle);
	}

	public inline function createModOptions():Void
		for (mod in ModManager.allMods)
		{
			var option = new Alphabet(0, 200, mod.name, false, CENTER, .7);
			option.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
			option.clipRect = FlxRect.weak(0, -option.height, option.width + 10, option.height * 2);
			option.clipRect = option.clipRect;
			option.screenCenter(X);
			option.alpha = .6;
			option.cameras = [optionsCam];
			option.option = mod;
			Path.cacheBitmap(mod.icon, mod, true);
			if (mod.enabled)
			{
				option.x += theWidth + 25;
				enabledOptions.insert(mod.ID, option);
			}
			if (mod.staticMod)
			{
				option.x -= theWidth + 25;
				staticOptions.insert(mod.ID, option);
			}
			if (!mod.staticMod && !mod.enabled)
				menuOptions.insert(mod.ID, option);
			add(option);
		}
}
