package states;

import flixel.math.FlxRect;

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
	var modVer:FlxText;
	var targetColor:FlxColor;

	var curSection:Int = 1;
	var theWidth = Std.int(FlxG.width / 3 - 100 / 3);

	var theStaticOption:Alphabet;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();

		#if DISCORD_ENABLED
		DiscordRPC.change('In the Menus', 'Mods Menu');
		#end

		add(bg = Create.backdrop(Path.image('menuBGDesat'), 1.7));
		bg.cameras = [menuCam];

		var allModsBG = Create.graphic(0, 25, Std.int(FlxG.width / 3 - 100 / 3), FlxG.height - 275, 0xCC000000);
		allModsBG.screenCenter(X);
		allModsBG.cameras = [menuCam];
		add(allModsBG);

		var staticModsBG = Create.graphic(0, 25, Std.int(FlxG.width / 3 - 100 / 3), FlxG.height - 275, 0xCC000000);
		staticModsBG.screenCenter(X);
		staticModsBG.x -= staticModsBG.width + 25;
		staticModsBG.cameras = [menuCam];
		add(staticModsBG);

		var enabledModsBG = Create.graphic(0, 25, Std.int(FlxG.width / 3 - 100 / 3), FlxG.height - 275, 0xCC000000);
		enabledModsBG.screenCenter(X);
		enabledModsBG.x += enabledModsBG.width + 25;
		enabledModsBG.cameras = [menuCam];
		add(enabledModsBG);

		var descriptionBG = Create.graphic(25, FlxG.height - 225, Std.int(FlxG.width - 575), 200, 0xCC000000);
		descriptionBG.cameras = [menuCam];
		add(descriptionBG);

		modIcon = Create.sprite(55, FlxG.height - 205, Path.image('unknownMod'), 1.2);
		modIcon.cameras = [menuCam];
		add(modIcon);

		modDesc = Create.text(modIcon.width + 65, FlxG.height - 205, 'N/A', 36, Path.font('vcr'), 0xFFFFFFFF, LEFT);
		modDesc.fieldWidth = 900;
		modDesc.fieldHeight = 175;
		modDesc.cameras = [menuCam];
		add(modDesc);

		modVer = Create.text(modIcon.width + 880, FlxG.height - 75, 'Version N/A', 32, Path.font('vcr'), 0xFFCCCCCC, RIGHT);
		modVer.fieldWidth = 300;
		modVer.fieldHeight = 175;
		modVer.cameras = [menuCam];
		add(modVer);

		var controlsBG = Create.graphic(descriptionBG.width + 50, FlxG.height - 225, 500, 200, 0xCC000000);
		controlsBG.cameras = [menuCam];
		add(controlsBG);

		var controlsText = Create.text(descriptionBG.width + 50, FlxG.height - 225,
			'Controls\nMove selection up/down: ${Settings.data.keybinds.get('ui')[6].toString()}/${Settings.data.keybinds.get('ui')[5].toString()}\nMove current option up/down: ${Settings.data.keybinds.get('ui')[2].toString()}/${Settings.data.keybinds.get('ui')[1].toString()}\nSelect Mod: ${Settings.data.keybinds.get('accept')[0].toString()}/${Settings.data.keybinds.get('accept')[1].toString()}\nReload Mods:${Settings.data.keybinds.get('reset')[0].toString()}\nReturn to Main Menu: ${Settings.data.keybinds.get('back')[0].toString()}/${Settings.data.keybinds.get('back')[1].toString()}',
			24, Path.font('vcr'), 0xFFFFFFFF, LEFT);
		controlsText.fieldWidth = 500;
		controlsText.cameras = [menuCam];
		add(controlsText);

		allModsTitle = new Alphabet(0, 25, 'All Mods', true, LEFT);
		allModsTitle.screenCenter(X);
		allModsTitle.y += allModsTitle.height;
		allModsTitle.alpha = .6;
		allModsTitle.cameras = [menuCam];
		add(allModsTitle);

		staticTitle = new Alphabet(0, 25, 'Static Mods', true, LEFT);
		staticTitle.screenCenter(X);
		staticTitle.x -= staticModsBG.width + 25;
		staticTitle.y += staticTitle.height;
		staticTitle.alpha = .6;
		staticTitle.cameras = [menuCam];
		add(staticTitle);

		enabledTitle = new Alphabet(0, 25, 'Enabled Mods', true, LEFT);
		enabledTitle.screenCenter(X);
		enabledTitle.x += enabledModsBG.width + 25;
		enabledTitle.y += enabledTitle.height;
		enabledTitle.alpha = .6;
		enabledTitle.cameras = [menuCam];
		add(enabledTitle);

		targetColor = FlxColor.WHITE;
		bop = handleInput = false;

		var i:Int = 0;
		for (mod in Mods.all)
		{
			if (mod.name == 'Assets')
				continue;
			var option:Alphabet = new Alphabet(0, 200 + (50 * i), mod.name, false, LEFT, .7);
			option.setColorTransform(1, 1, 1, 1, 255, 255, 255, 0);
			option.clipRect = FlxRect.weak(0, -option.height, option.width + 10, option.height * 2);
			option.clipRect = option.clipRect;
			option.screenCenter(X);
			option.alpha = .6;
			option.cameras = [optionsCam];
			option.option = mod;
			Path.cacheBitmap(mod.iconPath, [mod], true);
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
			i++;
		}

		changeSection(0);
		changeSelection(0);

		Path.clearUnusedMemory();
	}

	public override function update(elapsed:Float):Void
	{
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

		if (!transitioningOut)
		{
			if (Controls.accept)
				exitState();

			if (Controls.back)
				returnState();

			if (Controls.reset)
			{
				Log.info('Reloading Mods & Mod Assets');
				Mods.load();
				@:privateAccess Path.assets.clear();
				Path.loadAssets();
			}

			if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[1]]))
				shiftSelection(-1);

			if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[2]]))
				shiftSelection(1);

			if (Controls.ui_left)
				changeSection(-1);

			if (Controls.ui_right)
				changeSection(1);

			if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[6]]))
				changeSelection(-1);

			if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get('ui')[5]]))
				changeSelection(1);
		}

		super.update(elapsed);
	}

	public override function exitState():Void
	{
		resetModInfo();
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
				cast(menuOptions[curSelected], Alphabet).option.enabled = true;
				cast(menuOptions[curSelected], Alphabet).option.ID = enabledOptions.length - 1;
				enabledOptions.push(cast menuOptions[curSelected]);
				menuOptions.remove(menuOptions[curSelected]);
				changeSelection(0);
			case 2:
				if (enabledOptions.length <= 0)
					return;
				enabledOptions[curEnabled].alpha = .6;
				enabledOptions[curSelected].option.enabled = false;
				enabledOptions[curSelected].option.ID = menuOptions.length - 1;
				menuOptions.push(enabledOptions[curEnabled]);
				enabledOptions.remove(enabledOptions[curEnabled]);
				changeSelection(0);
		}
	}

	public override function returnState():Void
	{
		Mods.enabled = [];
		Settings.data.savedMods.clear();

		for (i in 0...menuOptions.length)
			Mods.all[cast(menuOptions[i], Alphabet).option.path].ID = i;

		for (i in 0...enabledOptions.length)
		{
			enabledOptions[i].option.ID = i + 1;
			Mods.enabled.insert(i + 1, enabledOptions[i].option);
		}

		haxe.ds.ArraySort.sort(Mods.enabled, (a, b) ->
		{
			return a.ID < b.ID ? -1 : a.ID > b.ID ? 1 : 0;
		});

		if (theStaticOption != null)
		{
			theStaticOption.option.ID = 0;
			theStaticOption.option.enabled = true;
			Mods.enabled.insert(0, theStaticOption.option);
		}

		for (mod in Mods.enabled)
		{
			var weeks:Map<String, {score:Int}> = [];
			var songs:Map<String, {score:Int, accuracy:Float}> = [];
			for (key => value in mod.weeks)
				weeks.set(key, {
					score: value.score
				});
			for (key => value in mod.songs)
				songs.set(key, {
					score: value.score,
					accuracy: value.accuracy
				});
			Settings.data.savedMods.set(mod.folderName, {
				enabled: mod.enabled,
				ID: mod.ID,
				weeks: weeks,
				songs: songs
			});
		}

		@:privateAccess Path.assets.clear();
		Path.loadAssets();

		Settings.save();
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public function shiftSelection(change:Int):Void
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
		changeSelection(0);
	}

	public function changeSection(change:Int):Void
	{
		if (change != 0)
			FlxG.sound.play(Path.audio('Scroll'), .7);

		curSection += change;

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
		resetModInfo();
		changeSelection(0);
	}

	public override function changeSelection(change:Int):Void
		switch (curSection)
		{
			case 0:
				if (staticOptions.length <= 0)
					return;
				if (staticOptions[curStatic] != null && staticOptions[curStatic].alpha != .8)
					staticOptions[curStatic].alpha = .6;
				if (change != 0)
					FlxG.sound.play(Path.audio('Scroll'), .7);
				curStatic += change;
				if (curStatic < 0)
					curStatic = staticOptions.length - 1;
				if (curStatic >= staticOptions.length)
					curStatic = 0;
				if (staticOptions[curStatic].alpha != .8)
					staticOptions[curStatic].alpha = 1;
				modIcon.loadGraphic(staticOptions[curStatic].option.iconPath);
				modDesc.text = staticOptions[curStatic].option.description;
				modVer.text = staticOptions[curStatic].option.version;
				targetColor = staticOptions[curStatic].option.color;
			case 1:
				if (menuOptions.length <= 0)
					return;
				if (menuOptions[curSelected] != null)
					menuOptions[curSelected].alpha = .6;
				super.changeSelection(change);
				menuOptions[curSelected].alpha = 1;
				modIcon.loadGraphic(cast(menuOptions[curSelected], Alphabet).option.iconPath);
				modDesc.text = cast(menuOptions[curSelected], Alphabet).option.description;
				modVer.text = cast(menuOptions[curSelected], Alphabet).option.version;
				targetColor = cast(menuOptions[curSelected], Alphabet).option.color;
			case 2:
				if (enabledOptions.length <= 0)
					return;
				if (enabledOptions[curEnabled] != null)
					enabledOptions[curEnabled].alpha = .6;
				if (change != 0)
					FlxG.sound.play(Path.audio('Scroll'), .7);
				curEnabled += change;
				if (curEnabled < 0)
					curEnabled = enabledOptions.length - 1;
				if (curEnabled >= enabledOptions.length)
					curEnabled = 0;
				enabledOptions[curEnabled].alpha = 1;
				modIcon.loadGraphic(enabledOptions[curEnabled].option.iconPath);
				modDesc.text = enabledOptions[curEnabled].option.description;
				modVer.text = enabledOptions[curEnabled].option.version;
				targetColor = enabledOptions[curEnabled].option.color;
		}

	inline function resetModInfo():Void
	{
		modIcon.loadGraphic(Path.image('unknownMod'));
		modDesc.text = 'N/A';
		modVer.text = 'N/A';
		targetColor = 0xFFFFFFFF;
	}
}
