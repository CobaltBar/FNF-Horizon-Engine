package horizon.states;

import flixel.math.FlxRect;

// This state could be a lot better ngl
class ModsMenuState extends MusicMenuState
{
	var curEnabled:Int = 0;

	var enabledOptions:Array<FlxSprite> = [];

	var enabledTitle:FlxSprite;
	var allModsTitle:FlxSprite;

	var modIcon:FlxSprite;
	var modDesc:FlxText;
	var modVer:FlxText;
	var targetColor:FlxColor = 0xFFFFFFFF;

	var curSection:Int = 1;

	var parsedMods:Array<Mod> = [];
	var optionToMod:Map<FlxSprite, Mod> = [];

	var paddedWidth:Int;

	public override function create():Void
	{
		Path.clearStoredMemory();
		customInput = true;
		super.create();

		add(bg = Create.backdrop(Path.image('menuBGDesat'), [menuCam], 1.1));

		/*paddedWidth = Std.int((FlxG.width - 20) / 3);
			var subHeight = Std.int((FlxG.height - 220) / 3);
			var subY = FlxG.height - 170;

			for (i in 0...3)
				add(Create.graphic(i * (paddedWidth + 5) + 5, 5, paddedWidth, FlxG.height - 180, 0xCC000000, [menuCam]));
			add(Create.graphic(5, subY, paddedWidth * 2 + 5, subHeight, 0xCC000000, [menuCam]));
			add(Create.graphic(paddedWidth * 2 + 15, subY, paddedWidth, subHeight, 0xCC000000, [menuCam]));

			add(modIcon = Create.sprite(15, subY + 5, Path.image('unknownMod'), [menuCam]));
			add(modDesc = Create.text(modIcon.width + 20, subY + 15, 'N/A', 24, Path.font('vcr'), 0xFFFFFFFF, LEFT, [menuCam]));
			modDesc.fieldWidth = 610;
			modDesc.fieldHeight = 150;

			add(modVer = Create.text(paddedWidth * 2 + 5, subY + modIcon.height - 15, 'VERSION N/A', 18, Path.font('vcr'), 0xFFCCCCCC, RIGHT, [menuCam]));
			modVer.fieldWidth = 200;
			modVer.fieldHeight = 50;
			modVer.x -= modVer.width;

			var controlsText:FlxText = Create.text(paddedWidth * 2 + 20, subY + 5,
				'Controls:\nMove Selection up/down: ${Settings.keybinds.get('ui_up')[0].toString()}/${Settings.keybinds.get('ui_down')[0].toString()}\nMove current option up/down: ${Settings.keybinds.get('ui_up')[1].toString()}/${Settings.keybinds.get('ui_down')[1].toString()}\nSelect Mod: ${[for (key in Settings.keybinds.get('accept')) key.toString()].join('/')}\nReload Mods: ${[for (key in Settings.keybinds.get('reset')) key.toString()].join('/')}\nReturn to Main Menu: ${[for (key in Settings.keybinds.get('back')) key.toString()].join('/')}',
				16, Path.font('vcr'), 0xFFFFFFFF, LEFT, [menuCam]);
			add(controlsText);

			add(allModsTitle = new Alphabet(0, 25, 'All Mods', true, CENTER, .7));
			allModsTitle.cameras = [menuCam];
			allModsTitle.screenCenter(X);
			allModsTitle.alpha = .6;

			add(staticTitle = new Alphabet(0, 25, 'Static Mods', true, CENTER, .7));
			staticTitle.cameras = [menuCam];
			staticTitle.screenCenter(X);
			staticTitle.x -= paddedWidth + 10;
			staticTitle.alpha = .6;

			add(enabledTitle = new Alphabet(0, 25, 'Enabled Mods', true, CENTER, .7));
			enabledTitle.cameras = [menuCam];
			enabledTitle.screenCenter(X);
			enabledTitle.x += paddedWidth + 10;
			enabledTitle.alpha = .6;

			// I hate from here
			var i = 0;
			var enabled = [for (mod in Mods.enabled) mod.name];
			for (mod in Mods.all)
			{
				if (enabled.contains(mod))
					continue;
				parsedMods.push(Mods.parseMod(Path.combine(['mods', mod]), mod, i));
				i++;
			}

			for (mod in parsedMods)
			{
				var option = new Alphabet(0, 0, mod.name, false, CENTER, .5);
				option.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
				option.screenCenter(X);
				option.alpha = .6;
				option.cameras = [optionsCam];
				option.clipRect = new FlxRect(0, 0, option.width + 10, option.height * 2);
				optionToMod.set(option, mod);
				add(option);
				Path.cacheBitmap(mod.iconPath, [mod], true);

				if (mod.staticMod)
				{
					option.x -= paddedWidth + 10;
					option.y = 200 + (50 * staticOptions.length);
					staticOptions.insert(mod.ID, option);
				}
				else
				{
					option.y = 200 + (50 * menuOptions.length);
					menuOptions.insert(mod.ID, option);
				}
			}

			for (mod in Mods.enabled)
			{
				var option = new Alphabet(0, 0, mod.name, false, CENTER, .5);
				option.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
				option.screenCenter(X);
				option.alpha = .6;
				option.cameras = [optionsCam];
				option.clipRect = new FlxRect(0, 0, option.width + 10, option.height * 2);
				optionToMod.set(option, mod);
				add(option);
				Path.cacheBitmap(mod.iconPath, [mod], true);

				option.x += paddedWidth + 10;
				option.y = 200 + (50 * enabledOptions.length);

				enabledOptions.insert(mod.ID, option);
			}

			for (arr in [staticOptions, enabledOptions, menuOptions])
				ArraySort.sort(arr, (a, b) -> return (a.ID > b.ID ? 1 : a.ID < b.ID ? -1 : 0));

			// to here

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
			changeSection(0);
			changeSelection(0); */

		Path.clearUnusedMemory();
	}

	/*
		public override function update(elapsed:Float):Void
		{
			for (i in 0...menuOptions.length)
			{
				menuOptions[i].clipRect.y = menuOptions[i].y < 100 ? (100 - menuOptions[i].y) : 0;
				menuOptions[i].clipRect.height = menuOptions[i].y > 495 ? menuOptions[i].height * 2 - (menuOptions[i].y - 495) : menuOptions[i].height * 2;
				menuOptions[i].clipRect = menuOptions[i].clipRect;

				menuOptions[i].x = FlxMath.lerp(menuOptions[i].x, (FlxG.width - menuOptions[i].width) * .5, FlxMath.bound(elapsed * 5, 0, 1));
				menuOptions[i].y = FlxMath.lerp(menuOptions[i].y, 200 - (50 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1));
			}

			for (i in 0...enabledOptions.length)
			{
				enabledOptions[i].clipRect.y = enabledOptions[i].y < 100 ? (100 - enabledOptions[i].y) : 0;
				enabledOptions[i].clipRect.height = enabledOptions[i].y > 495 ? enabledOptions[i].height * 2 - (enabledOptions[i].y - 495) : enabledOptions[i].height * 2;
				enabledOptions[i].clipRect = enabledOptions[i].clipRect;

				enabledOptions[i].x = FlxMath.lerp(enabledOptions[i].x, (FlxG.width - enabledOptions[i].width) * .5 + paddedWidth + 10,
					FlxMath.bound(elapsed * 5, 0, 1));
				enabledOptions[i].y = FlxMath.lerp(enabledOptions[i].y, 200 - (50 * (curEnabled - i)), FlxMath.bound(elapsed * 5, 0, 1));
			}

			bg.color = FlxColor.interpolate(bg.color, targetColor, FlxMath.bound(elapsed * 5, 0, 1));

			super.update(elapsed);
		}

		public override function exitState():Void
		{
			modIcon.loadGraphic(Path.image('unknownMod'));
			modDesc.text = 'N/A';
			modVer.text = 'N/A';
			targetColor = 0xFFFFFFFF;

			changeSelection(0);

			switch (curSection)
			{
				case 0:
					if (staticOptions.length <= 0)
						return;
					if (theStaticOption != null)
						theStaticOption.alpha = .6;
					theStaticOption = staticOptions[curStatic];
					theStaticOption.alpha = .8;
				case 1:
					if (menuOptions.length <= 0)
						return;
					menuOptions[curSelected].alpha = .6;
					optionToMod[menuOptions[curSelected]].ID = enabledOptions.length - 1;
					enabledOptions.push(menuOptions[curSelected]);
					menuOptions.remove(menuOptions[curSelected]);

				case 2:
					if (enabledOptions.length <= 0)
						return;
					enabledOptions[curEnabled].alpha = .6;
					optionToMod[enabledOptions[curSelected]].ID = menuOptions.length - 1;
					menuOptions.push(enabledOptions[curEnabled]);
					enabledOptions.remove(enabledOptions[curEnabled]);
			}

			changeSection(0);
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

			if (theStaticOption != null)
			{
				optionToMod[theStaticOption].ID = 0;
				Mods.enabled.insert(0, optionToMod[theStaticOption]);
			}

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

		public function shiftSelection(change:Int):Void
		{
			switch (curSection)
			{
				case 1:
					if (menuOptions.length < 1)
						return;
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
				curSection = 2;
			if (curSection > 2)
				curSection = 0;

			switch (curSection)
			{
				case 0:
					if (staticOptions.length == 0)
						curSection = change > 0 ? menuOptions.length > 0 ? 1 : 2 : change <= 0 ? enabledOptions.length > 0 ? 2 : 1 : curSection;
				case 1:
					if (menuOptions.length == 0)
						curSection = change > 0 ? enabledOptions.length > 0 ? 2 : 1 : change <= 0 ? staticOptions.length > 0 ? 0 : 2 : curSection;
				case 2:
					if (enabledOptions.length == 0)
						curSection = change > 0 ? staticOptions.length > 0 ? 0 : 1 : change <= 0 ? menuOptions.length > 0 ? 1 : 0 : curSection;
			}

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
			switch (curSection)
			{
				case 0:
					if (staticOptions.length < 1)
						return;
					if (staticOptions[curStatic].alpha != .8)
						staticOptions[curStatic].alpha = .6;

					if (change != 0)
						FlxG.sound.play(Path.audio('scroll'), .7);

					curStatic += change;

					if (curStatic < 0)
						curStatic = staticOptions.length - 1;
					if (curStatic >= staticOptions.length)
						curStatic = 0;

					if (staticOptions[curStatic].alpha != .8)
						staticOptions[curStatic].alpha = 1;

					var mod = optionToMod[staticOptions[curStatic]];
					modIcon.loadGraphic(mod.iconPath);
					modDesc.text = mod.description;
					modVer.text = mod.version;
					targetColor = mod.color;

				case 1:
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

				case 2:
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
	}*/
	public override function destroy()
	{
		parsedMods = [];
		super.destroy();
	}
}
