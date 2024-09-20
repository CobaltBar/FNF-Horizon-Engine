package horizon.states;

class ModsMenuState extends MusicMenuState
{
	var curEnabled:Int = 0;

	var enabledOptions:Array<FlxSprite> = [];

	var enabledTitle:FlxSprite;
	var disabledTitle:FlxSprite;

	var modIcon:FlxSprite;
	var modDesc:FlxText;
	var modVer:FlxText;
	var targetColor:FlxColor = 0xFFFFFFFF;

	var curSection:Int = 1;

	var parsedMods:Array<Mod> = [];
	var optionToMod:Map<FlxSprite, Mod> = [];

	var menuCurveProgress:Array<Float> = [];
	var enabledCurveProgress:Array<Float> = [];

	public override function create():Void
	{
		Path.clearStoredMemory();
		customInput = true;
		super.create();

		add(bg = Create.backdrop(Path.image('menuBGDesat'), [menuCam], 1.1));

		var circle = Create.sprite(0, 0, Path.image("semicircle"), [menuCam]);
		circle.setPosition(0, FlxG.height - circle.height);
		circle.alpha = .6;
		add(circle);

		var circle = Create.sprite(0, 0, Path.image("semicircle"), [menuCam]);
		circle.setPosition(FlxG.width - circle.width, FlxG.height - circle.height);
		circle.flipX = true;
		circle.alpha = .6;
		add(circle);

		add(disabledTitle = new Alphabet(0, 50, 'Disabled', true, CENTER, .65));
		disabledTitle.screenCenter(X);
		disabledTitle.x -= FlxG.width * .4 - 10;
		disabledTitle.cameras = [menuCam];

		add(enabledTitle = new Alphabet(0, 50, 'Enabled', true, CENTER, .65));
		enabledTitle.screenCenter(X);
		enabledTitle.x += FlxG.width * .4;
		enabledTitle.cameras = [menuCam];

		var box = Create.graphic(0, 0, Std.int(FlxG.width * .5), FlxG.height, 0x99000000, [menuCam]);
		box.screenCenter(X);
		add(box);

		add(modIcon = Create.sprite(box.x + box.width - 5, FlxG.height - 5, Path.image('unknownMod'), [menuCam]));
		modIcon.x -= modIcon.width;
		modIcon.y -= modIcon.height;

		add(modVer = Create.text(0, modIcon.y - 10, 'Version N/A', 18, Path.font('vcr'), 0xFFDDDDDD, CENTER, [menuCam]));
		modVer.fieldHeight = 100;
		modVer.x = modIcon.x + (modIcon.width - modVer.width) * .5;

		add(modDesc = Create.text(0, 0, "N/A", 24, Path.font('vcr'), 0xFFFFFFFF, CENTER, [menuCam]));
		modDesc.fieldWidth = FlxG.width * .5 - 10;
		modDesc.screenCenter();
		modDesc.fieldHeight = 250;

		var controlsText = Create.text(box.x + 5, FlxG.height - 5,
			'Controls:\nMove Selection up/down: ${Settings.keybinds.get('ui_up')[0].toString()}/${Settings.keybinds.get('ui_down')[0].toString()}\nMove current option up/down: ${Settings.keybinds.get('ui_up')[1].toString()}/${Settings.keybinds.get('ui_down')[1].toString()}\nSelect Mod: ${[for (key in Settings.keybinds.get('accept')) key.toString()].join('/')}\nReload Mods: ${[for (key in Settings.keybinds.get('reset')) key.toString()].join('/')}\nReturn to Main Menu: ${[for (key in Settings.keybinds.get('back')) key.toString()].join('/')}',
			16, Path.font('vcr'), 0xFFFFFFFF, LEFT, [menuCam]);
		controlsText.y -= controlsText.height;
		add(controlsText);

		var enabled = [for (mod in Mods.enabled) mod.name];
		for (i in 0...Mods.all.length)
		{
			if (enabled.contains(Mods.all[i]))
				continue;
			parsedMods.push(Mods.parseMod(Path.combine(['mods', Mods.all[i]]), Mods.all[i], i));
		}

		for (mod in parsedMods)
		{
			var option = new Alphabet(0, 0, mod.name, false, CENTER, .5);
			option.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
			option.alpha = .6;
			option.cameras = [optionsCam];
			optionToMod.set(option, mod);
			add(option);
			Path.cacheBitmap(mod.iconPath, [mod], true);

			option.x -= option.width;
			option.y = (circle.height - option.height) * .5;

			menuOptions.insert(mod.ID, option);
		}

		for (mod in Mods.enabled)
		{
			var option = new Alphabet(FlxG.width, 0, mod.name, false, CENTER, .5);
			option.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
			option.alpha = .6;
			option.cameras = [optionsCam];
			optionToMod.set(option, mod);
			add(option);
			Path.cacheBitmap(mod.iconPath, [mod], true);

			option.y = (circle.height - option.height) * .5;

			enabledOptions.insert(mod.ID, option);
		}

		for (arr in [enabledOptions, menuOptions])
			ArraySort.sort(arr, (a, b) -> return (a.ID > b.ID ? 1 : a.ID < b.ID ? -1 : 0));

		Controls.onPress(Settings.keybinds.get('accept'), () -> if (!transitioningOut) exitState());
		Controls.onPress(Settings.keybinds.get('back'), () -> if (!transitioningOut) returnState());
		Controls.onPress(Settings.keybinds.get('reset'), () -> if (!transitioningOut)
		{
			Log.info('Reloading Mods and Mod Assets');
			Mods.load();
			Path.loadAssets();
		});
		Controls.onPress([Settings.keybinds['ui_up'][0]], () -> if (!transitioningOut) changeSelection(-1));
		Controls.onPress([Settings.keybinds['ui_down'][0]], () -> if (!transitioningOut) changeSelection(1));
		Controls.onPress([Settings.keybinds['ui_up'][1]], () -> if (!transitioningOut) shiftSelection(1));
		Controls.onPress([Settings.keybinds['ui_down'][1]], () -> if (!transitioningOut) shiftSelection(-1));
		Controls.onPress(Settings.keybinds['ui_left'], () -> if (!transitioningOut) changeSection(-1));
		Controls.onPress(Settings.keybinds['ui_right'], () -> if (!transitioningOut) changeSection(1));

		bop = false;

		// changeSection(0);
		changeSelection(0);

		Path.clearUnusedMemory();
	}

	public override function update(elapsed:Float):Void
	{
		for (i in 0...menuOptions.length)
		{
			menuCurveProgress[i] = FlxMath.lerp(menuCurveProgress[i], (i - curSelected + (menuOptions.length * .5)) / menuOptions.length,
				FlxMath.bound(elapsed * 10, 0, 1));

			var point = Util.quadBezier(FlxPoint.weak(0, 140), FlxPoint.weak(500, 420), FlxPoint.weak(0, FlxG.height - 20), menuCurveProgress[i]);
			menuOptions[i].x = FlxMath.lerp(menuOptions[i].x, point.x - menuOptions[i].width, FlxMath.bound(elapsed * 10, 0, 1));
			menuOptions[i].y = FlxMath.lerp(menuOptions[i].y, point.y, FlxMath.bound(elapsed * 10, 0, 1));

			point.putWeak();
		}

		for (i in 0...enabledOptions.length)
		{
			enabledCurveProgress[i] = FlxMath.lerp(enabledCurveProgress[i], (i - curEnabled + (enabledOptions.length * .5)) / enabledOptions.length,
				FlxMath.bound(elapsed * 10, 0, 1));

			var point = Util.quadBezier(FlxPoint.weak(FlxG.width, 140), FlxPoint.weak(FlxG.width - 500, 420), FlxPoint.weak(FlxG.width, FlxG.height - 20),
				enabledCurveProgress[i]);
			enabledOptions[i].x = FlxMath.lerp(enabledOptions[i].x, point.x, FlxMath.bound(elapsed * 10, 0, 1));
			enabledOptions[i].y = FlxMath.lerp(enabledOptions[i].y, point.y, FlxMath.bound(elapsed * 10, 0, 1));

			point.putWeak();
		}

		bg.color = FlxColor.interpolate(bg.color, targetColor, FlxMath.bound(elapsed * 10, 0, 1));

		super.update(elapsed);
	}

	public function shiftSelection(change:Int):Void
	{
		if (curSection == 1)
		{
			if (enabledOptions.length < 1)
				return;
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
		changeSelection(0);
	}

	public function changeSection(change:Int):Void
	{
		curSection += change;

		if (curSection < 0)
			curSection = 1;
		if (curSection > 1)
			curSection = 0;

		if (curSection == 0)
		{
			disabledTitle.alpha = 1;
			enabledTitle.alpha = .6;

			if (menuOptions[curSelected] != null)
				menuOptions[curSelected].alpha = 1;
			if (enabledOptions[curEnabled] != null)
				enabledOptions[curEnabled].alpha = .6;
		}
		else
		{
			disabledTitle.alpha = .6;
			enabledTitle.alpha = 1;

			if (menuOptions[curSelected] != null)
				menuOptions[curSelected].alpha = .6;
			if (enabledOptions[curEnabled] != null)
				enabledOptions[curEnabled].alpha = 1;
		}

		modIcon.loadGraphic(Path.image('unknownMod'));
		modDesc.text = 'N/A';
		modVer.text = 'N/A';
		targetColor = 0xFFFFFFFF;

		changeSelection(0);

		if (change != 0)
			FlxG.sound.play(Path.audio('scroll'), .7);
	}

	public override function changeSelection(change:Int):Void
	{
		if (curSection == 0)
		{
			if (menuOptions.length < 1)
				return;
			if (menuOptions[curSelected] != null)
				menuOptions[curSelected].alpha = .6;
			super.changeSelection(change);
			menuOptions[curSelected].alpha = 1;

			var mod = optionToMod[menuOptions[curSelected]];
			modIcon.loadGraphic(mod.iconPath);
			modDesc.text = mod.description;
			modVer.text = mod.version;
			targetColor = mod.color;
		}
		else
		{
			if (enabledOptions.length < 1)
				return;
			if (enabledOptions[curEnabled] != null)
				enabledOptions[curEnabled].alpha = .6;
			if (change != 0)
				FlxG.sound.play(Path.audio('scroll'), .7);

			curEnabled += change;
			if (curEnabled < 0)
				curEnabled = enabledOptions.length - 1;
			if (curEnabled >= enabledOptions.length)
				curEnabled = 0;

			enabledOptions[curEnabled].alpha = 1;
			var mod = optionToMod[enabledOptions[curEnabled]];
			modIcon.loadGraphic(mod.iconPath);
			modDesc.text = mod.description;
			modVer.text = mod.version;
			targetColor = mod.color;
		}
	}

	public override function exitState():Void
	{
		modIcon.loadGraphic(Path.image('unknownMod'));
		modDesc.text = 'N/A';
		modVer.text = 'N/A';
		targetColor = 0xFFFFFFFF;

		if (curSection == 0)
		{
			if (menuOptions.length <= 0)
				return;
			menuOptions[curSelected].alpha = .6;
			optionToMod[menuOptions[curSelected]].ID = enabledOptions.length - 1;
			enabledOptions.push(menuOptions[curSelected]);
			menuOptions.remove(menuOptions[curSelected]);
		}
		else
		{
			if (enabledOptions.length <= 0)
				return;
			enabledOptions[curEnabled].alpha = .6;
			optionToMod[enabledOptions[curEnabled]].ID = menuOptions.length - 1;
			menuOptions.push(enabledOptions[curEnabled]);
			enabledOptions.remove(enabledOptions[curEnabled]);
		}

		changeSelection(0);
	}

	public override function returnState():Void
	{
		Mods.enabled = [];

		for (i in 0...enabledOptions.length)
		{
			optionToMod[enabledOptions[i]].ID = i + 1;
			Mods.enabled.insert(i + 1, optionToMod[enabledOptions[i]]);
		}

		ArraySort.sort(Mods.enabled, (a, b) -> a.ID < b.ID ? -1 : a.ID > b.ID ? 1 : 0);

		for (mod in Mods.enabled)
		{
			var weeks:Map<String, {score:Int, accuracy:Float, locked:Bool}> = [];
			var songs:Map<String, {score:Int, accuracy:Float}> = [];

			for (week in mod.weeks)
				weeks.set(week.folder, {
					score: week.score,
					accuracy: week.accuracy,
					locked: week.locked,
				});
			for (song in mod.songs)
				songs.set(song.folder, {
					score: song.score,
					accuracy: song.accuracy
				});
			Settings.savedMods.set(mod.folder, {
				enabled: true,
				ID: mod.ID,
				weeks: weeks,
				songs: songs
			});
		}

		Path.loadAssets();
		SettingsManager.save();
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public override function destroy()
	{
		parsedMods = [];
		super.destroy();
	}
}
