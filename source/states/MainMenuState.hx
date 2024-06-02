package states;

import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import lime.app.Application;

class MainMenuState extends MusicMenuState
{
	var bgFlash:FlxBackdrop;

	var allModsCount:Int = 0;

	static var prevCurSelected:Int = 0;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		DiscordRPC.change('In The Menus', 'The Main Menu');
		persistentUpdate = true;
		createMenuBG();
		for (val in Mods.all)
			allModsCount++;
		createMenuOptions(['story_mode', 'freeplay', 'mods', 'awards', 'credits', 'donate', 'options']);
		createVersionTexts();

		changeSelection(0);

		for (i in 0...menuOptions.length)
		{
			var oldX = menuOptions[i].x;
			menuOptions[i].x -= 2000 * (i % 2 == 0 ? 1 : -1);
			FlxTween.tween(menuOptions[i], {x: oldX}, 1, {
				type: ONESHOT,
				ease: FlxEase.expoOut
			});
			if (!Settings.data.reducedMotion)
			{
				var oldY = menuOptions[i].y;
				menuOptions[i].y -= 2000;
				FlxTween.tween(menuOptions[i], {y: oldY}, 1, {
					type: ONESHOT,
					ease: FlxEase.cubeOut
				});
			}
			menuOptions[i].visible = true;
		}

		curSelected = prevCurSelected;
	}

	public override function changeSelection(change:Int):Void
	{
		menuOptions[curSelected].x -= menuOptions[curSelected].width * .5;
		menuOptions[curSelected].animation.play('idle');
		menuOptions[curSelected].x += menuOptions[curSelected].width * .5;

		super.changeSelection(change);
		prevCurSelected = curSelected;

		menuOptions[curSelected].x -= menuOptions[curSelected].width * .5;
		menuOptions[curSelected].animation.play('selected');
		menuOptions[curSelected].x += menuOptions[curSelected].width * .5;

		var offset:Float = 0;
		for (i in 0...menuOptions.length)
		{
			menuOptions[i].centerOffsets();
			menuOptions[i].y = 100 + offset;
			offset += menuOptions[i].height + 45;
		}

		optionsFollow.y = menuOptions[curSelected].y * .5 + 450;
		menuFollow.y = menuOptions[curSelected].y * .125 + 450;
	}

	public override function exitState()
	{
		super.exitState();
		transitioningOut = false;
		if (curSelected == (5 - (allModsCount == 0 ? 1 : 0)))
			Util.browserLoad('https://ninja-muffin24.itch.io/funkin');
		else
		{
			if (Settings.data.flashingLights)
				FlxFlicker.flicker(bgFlash, 1.1, .15, false);
			optionsCam.follow(menuOptions[curSelected], LOCKON, .12);
			transitioningOut = true;

			FlxTween.tween(optionsCam, {zoom: 1.2}, 1, {
				ease: FlxEase.expoOut,
				type: ONESHOT,
			});
			FlxTween.tween(menuCam, {zoom: .9}, 1, {
				ease: FlxEase.expoOut,
				type: ONESHOT,
			});
			if (Settings.data.flashingLights)
				FlxFlicker.flicker(menuOptions[curSelected], 1.3, .06, false, false, flicker -> out());
			else
				FlxTimer.wait(1.3, () -> out());
			for (i in 0...menuOptions.length)
				if (i != curSelected)
					FlxTween.tween(menuOptions[i], {alpha: 0}, .3, {
						ease: FlxEase.quintOut,
						type: ONESHOT,
						onComplete: tween ->
						{
							menuOptions[i].destroy();
						}
					});
		}
	}

	public override function returnState():Void
	{
		super.returnState();
		MusicState.switchState(new TitleState());
	}

	function createVersionTexts():Void
	{
		var horizonEngineText = Util.createText(5, FlxG.height - 65, 'Horizon Engine v' + Application.current.meta.get('version'), 28, Path.font('vcr'),
			0xFFFFFFFF, LEFT)
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		horizonEngineText.cameras = [otherCam];
		add(horizonEngineText);

		var fnfVersion = Util.createText(5, FlxG.height - 35, 'Friday Night Funkin\' v0.2.8', 28, Path.font('vcr'), 0xFFFFFFFF, LEFT)
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		fnfVersion.cameras = [otherCam];
		add(fnfVersion);
	}

	function createMenuOptions(options:Array<String>):Void
	{
		for (name in options)
		{
			if (allModsCount == 0 && name == 'mods')
				continue;
			var option = Util.createSparrowSprite(0, 0, name, 1.4);
			option.animation.addByPrefix('selected', name + ' white', 24, true);
			option.animation.addByPrefix('idle', name + ' basic', 24, true);
			option.animation.play('idle');
			option.cameras = [optionsCam];
			option.visible = false;
			option.updateHitbox();
			option.centerOffsets();
			add(option);
			menuOptions.push(option);
		}
		var offset:Float = 0;
		for (i in 0...menuOptions.length)
		{
			menuOptions[i].x = (FlxG.width - menuOptions[i].width) * .5;
			menuOptions[i].y = 100 + offset;
			offset += menuOptions[i].height + 45;
		}
	}

	inline function createMenuBG():Void
	{
		bg = Util.createBackdrop(Path.image('menuBG'), 1.7);
		bg.cameras = [menuCam];
		add(bg);

		bgFlash = Util.createBackdrop(Path.image('menuBGMagenta'), 1.7);
		bgFlash.cameras = [menuCam];
		bgFlash.visible = false;
		add(bgFlash);
	}

	inline function out():Void
		if (allModsCount == 0)
			switch (curSelected)
			{
				case 0:
					MusicState.switchState(new StoryMenuState());
				case 1:
				// MusicState.switchState(new FreeplayState());
				case 2:
				// MusicState.switchState(new AwardsState());
				case 3:
				// MusicState.switchState(new CreditsState());
				case 5:
					// MusicState.switchState(new OptionsState());
			}
		else
			switch (curSelected)
			{
				case 0:
					MusicState.switchState(new StoryMenuState());
				case 1:
				// MusicState.switchState(new FreeplayState());
				case 2:
					MusicState.switchState(new ModsMenuState());
				case 3:
				// MusicState.switchState(new AwardsState());
				case 4:
				// MusicState.switchState(new CreditsState());
				case 6:
					// MusicState.switchState(new OptionsState());
			}
}
