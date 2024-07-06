package states;

import flixel.effects.FlxFlicker;
import lime.app.Application;

class MainMenuState extends MusicMenuState
{
	var bgFlash:FlxBackdrop;
	var allModsCount:Int = -1;

	static var prevCurSelected:Int = 0;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		persistentUpdate = true;

		add(bg = Create.backdrop(Path.image('menuBG'), 1.7));
		bg.cameras = [menuCam];

		add(bgFlash = Create.backdrop(Path.image('menuBGMagenta'), 1.7));
		bgFlash.cameras = [menuCam];
		bgFlash.visible = false;

		for (val in Mods.all)
			allModsCount++;

		for (name in ['story_mode', 'freeplay', 'mods', 'awards', 'credits', 'donate', 'options'])
		{
			if (name == 'mods' && allModsCount == 0)
				continue;
			var option = Create.sparrow(0, 0, Path.sparrow(name), 1.4);
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

		for (i in 0...menuOptions.length)
		{
			menuOptions[i].x = 200 + (200 * i);
			menuOptions[i].y = 100 + (230 * i);
		}

		curSelected = prevCurSelected;
		changeSelection(0);

		var horizonEngineText = Create.text(5, FlxG.height - 65, 'Horizon Engine v' + Application.current.meta.get('version'), 28, Path.font('vcr'),
			0xFFFFFFFF, LEFT)
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		horizonEngineText.cameras = [otherCam];
		add(horizonEngineText);

		var fnfVersion = Create.text(5, FlxG.height - 35, 'Friday Night Funkin\' 0.2.8, 0.4.1', 28, Path.font('vcr'), 0xFFFFFFFF, LEFT)
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		fnfVersion.cameras = [otherCam];
		add(fnfVersion);

		for (i in 0...menuOptions.length)
		{
			var oldX = menuOptions[i].x;
			menuOptions[i].x -= 2000 * (i % 2 == 0 ? 1 : -1);
			FlxTween.tween(menuOptions[i], {x: oldX}, 1, {
				type: ONESHOT,
				ease: FlxEase.expoOut
			});
			menuOptions[i].visible = true;
		}

		Path.clearUnusedMemory();
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

		optionsFollow.setPosition(FlxG.width * .35 + (200 * curSelected), (225 * curSelected) + FlxG.height * .25);

		for (i in 0...menuOptions.length)
		{
			menuOptions[i].centerOffsets();
			menuOptions[i].y = 100 + (230 * i);
		}

		menuFollow.y = menuOptions[curSelected].y * .125 + 450;
	}

	public override function exitState():Void
	{
		super.exitState();
		transitioningOut = false;
		if (curSelected == (5 - (allModsCount == 0 ? 1 : 0)))
			Misc.openURL('https://ninja-muffin24.itch.io/funkin');
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

	function out():Void
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
