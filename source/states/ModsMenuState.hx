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

	var curSection:Int = 1;
	var theWidth = Std.int(FlxG.width / 3 - 100 / 3);

	public override function create():Void
	{
		Path.clearStoredMemory();
		setupMenu();
		createMenuBG();
		createModUI();
		shouldBop = handleInput = false;
		createModOptions();
		changeSection(0, false);
		changeSelection(0, false);
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")) && !transitioningOut)
			exitState();

		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("back")) && !transitioningOut)
			returnState();

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[0], Settings.data.keybinds.get("ui")[4]]) && !transitioningOut)
			changeSection(-1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[3], Settings.data.keybinds.get("ui")[7]]) && !transitioningOut)
			changeSection(1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[5]]) && !transitioningOut)
			changeSelection(1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[6]]) && !transitioningOut)
			changeSelection(-1);

		for (i in 0...staticOptions.length)
		{
			staticOptions[i].y = FlxMath.lerp(staticOptions[i].y, 200 - (50 * (curStatic - i)), FlxMath.bound(elapsed * 5, 0, 1));
		}

		for (i in 0...menuOptions.length)
		{
			menuOptions[i].x = FlxMath.lerp(menuOptions[i].x, (FlxG.width - menuOptions[i].width) * 0.5, FlxMath.bound(elapsed * 5, 0, 1));
			menuOptions[i].y = FlxMath.lerp(menuOptions[i].y, 200 - (50 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1));
		}

		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].x = FlxMath.lerp(enabledOptions[i].x, (FlxG.width - enabledOptions[i].width) * 0.5 + theWidth, FlxMath.bound(elapsed * 5, 0, 1));
			enabledOptions[i].y = FlxMath.lerp(enabledOptions[i].y, 200 - (50 * (curEnabled - i)), FlxMath.bound(elapsed * 5, 0, 1));
		}
	}

	public override function exitState():Void
	{
		switch (curSection)
		{
			case 0:
				if (staticOptions.length <= 0)
					return;
				staticOptions[curStatic].alpha = 1;
				staticOptions[curStatic].option.enabled = !staticOptions[curStatic].option.enabled;
			case 1:
				if (menuOptions.length <= 0)
					return;
				menuOptions[curSelected].alpha = .6;
				cast(menuOptions[curSelected], Alphabet).option.enabled = true;
				enabledOptions.push(cast menuOptions[curSelected]);
				menuOptions.remove(menuOptions[curSelected]);
				changeSelection(0, false);
			case 2:
				if (enabledOptions.length <= 0)
					return;
				enabledOptions[curEnabled].option.enabled = false;
				enabledOptions[curEnabled].alpha = .6;
				menuOptions.push(enabledOptions[curEnabled]);
				enabledOptions.remove(enabledOptions[curEnabled]);
				changeSelection(0, false);
		}
	}

	public override function returnState():Void
	{
		ModManager.enabledMods = [];

		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].option.ID = i;
			ModManager.enabledMods.push(enabledOptions[i].option);
		}

		haxe.ds.ArraySort.sort(ModManager.enabledMods, (a, b) ->
		{
			return a.ID < b.ID ? -1 : a.ID > b.ID ? 1 : 0;
		});

		for (mod in ModManager.enabledMods)
			Settings.data.savedMods.set(mod.path, mod);

		super.returnState();
		Settings.save();
		MusicState.switchState(new MainMenuState());
	}

	public function changeSection(change:Int, sound:Bool = true, set:Bool = false):Void
	{
		if (sound)
			FlxG.sound.play(Path.sound("Scroll"), 0.7);

		set ? curSection = change : curSection += change;

		if (curSection < 0)
			curSection = 2;
		if (curSection > 2)
			curSection = 0;

		switch (curSection)
		{
			case 0:
				staticTitle.alpha = 1;
				allModsTitle.alpha = enabledTitle.alpha = 0.6;

			case 1:
				allModsTitle.alpha = 1;
				staticTitle.alpha = enabledTitle.alpha = 0.6;
			case 2:
				enabledTitle.alpha = 1;
				allModsTitle.alpha = staticTitle.alpha = 0.6;
		}
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false):Void {}

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
			'Controls\nMove selection up/down: ${Settings.data.keybinds.get("ui")[6].toString()}/${Settings.data.keybinds.get("ui")[5].toString()}\nMove current option up/down: ${Settings.data.keybinds.get("ui")[2].toString()}/${Settings.data.keybinds.get("ui")[1].toString()}',
			24, Path.font("vcr"), 0xFFFFFFFF, CENTER);
		controlsText.cameras = [menuCam];
		add(controlsText);

		allModsTitle = new Alphabet(0, 25, "All Mods", true, CENTER, 0.9);
		allModsTitle.screenCenter(X);
		allModsTitle.y += allModsTitle.height;
		allModsTitle.alpha = 0.6;
		allModsTitle.cameras = [menuCam];
		add(allModsTitle);

		staticTitle = new Alphabet(0, 25, "Static Mods", true, CENTER, 0.9);
		staticTitle.screenCenter(X);
		staticTitle.x -= staticModsBG.width + 25;
		staticTitle.y += staticTitle.height;
		staticTitle.alpha = 0.6;
		staticTitle.cameras = [menuCam];
		add(staticTitle);

		enabledTitle = new Alphabet(0, 25, "Enabled Mods", true, CENTER, 0.9);
		enabledTitle.screenCenter(X);
		enabledTitle.x += enabledModsBG.width + 25;
		enabledTitle.y += enabledTitle.height;
		enabledTitle.alpha = 0.6;
		enabledTitle.cameras = [menuCam];
		add(enabledTitle);
	}

	public inline function createModOptions():Void
	{
		var i:Int = 0;
		for (mod in ModManager.allMods)
		{
			if (mod.enabled)
				continue;
			var option = new Alphabet(0, 200 + (50 * i), mod.name, false, CENTER, 0.7);
			option.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
			option.screenCenter(X);
			option.alpha = 0.6;
			option.cameras = [menuCam];
			option.option = mod;
			if (mod.enabled)
			{
				option.x += theWidth + 25;
				enabledOptions.push(option);
			}
			else if (mod.staticMod)
			{
				option.x -= theWidth + 25;
				staticOptions.push(option);
			}
			else
				menuOptions.push(option);
			add(option);
			i++;
		}
	}
	/*

		public override function update(elapsed:Float):Void
		{
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

			for (i in 0...menuOptions.length)
			{
				menuOptions[i].x = FlxMath.lerp(menuOptions[i].x, FlxG.width - 50 - (allModBG.width + menuOptions[i].width) * 0.5, elapsed * 5);
				menuOptions[i].y = FlxMath.lerp(menuOptions[i].y, 250 - (curSelected - i - 1) * 100, elapsed * 5);
				menuOptions[i].clipRect = FlxRect.weak(0,
					Std.int(menuOptions[i].y < 250 ? -menuOptions[i].height - 10 - (menuOptions[i].y - 250) : -menuOptions[i].height - 10), menuOptions[i].width,
					Std.int(menuOptions[i].y > 800 ? menuOptions[i].height - (menuOptions[i].y - 800) : menuOptions[i].height));
				menuOptions[i].clipRect = menuOptions[i].clipRect;
			}
			for (i in 0...enabledOptions.length)
			{
				enabledOptions[i].x = FlxMath.lerp(enabledOptions[i].x, 50 + (enabledModBG.width - enabledOptions[i].width) * 0.5, elapsed * 5);
				enabledOptions[i].y = FlxMath.lerp(enabledOptions[i].y, 250 - (curEnabled - i - 1) * 100, elapsed * 5);
				enabledOptions[i].clipRect = FlxRect.weak(0,
					Std.int(enabledOptions[i].y < 250 ? -enabledOptions[i].height - 10 - (enabledOptions[i].y - 250) : -enabledOptions[i].height - 10),
					enabledOptions[i].width,
					Std.int(enabledOptions[i].y > 789 ? enabledOptions[i].height - (enabledOptions[i].y - 789) : enabledOptions[i].height));
				enabledOptions[i].clipRect = enabledOptions[i].clipRect;
			}
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
	 */
}
