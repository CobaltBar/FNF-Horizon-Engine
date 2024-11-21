package horizon.states;

import flixel.addons.display.FlxBackdrop;
import flixel.effects.FlxFlicker;
import lime.app.Application;

class MainMenuState extends MusicMenuState
{
	var flashBG:FlxBackdrop;
	var modCount:Int = 0;
	var curveProgress:Array<Float> = [];

	static var prevSelected:Int = 0;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		persistentUpdate = true;

		add(bg = Create.backdrop(Path.image('menuBG'), [menuCam], 1.1));

		add(flashBG = Create.backdrop(Path.image('menuBGMagenta'), [menuCam], 1.1));
		flashBG.visible = false;

		for (val in Mods.all)
			modCount++;

		for (name in ['storymode', 'freeplay', 'mods', 'credits', 'merch', 'options'])
		{
			if (name == 'mods' && modCount == 0)
				continue;
			var option = Create.atlas(0, 0, Path.atlas(name), [optionsCam]);
			option.animation.addByPrefix('selected', name + ' selected', 24, true);
			option.animation.addByPrefix('idle', name + ' idle', 24, true);
			option.animation.play('idle');
			option.updateHitbox();
			option.centerOffsets();
			add(option);
			menuOptions.push(option);
		}

		curSelected = prevSelected;
		changeSelection(0);

		var horizonEngineText = Create.text(5, FlxG.height - 55, 'Horizon Engine v${Application.current.meta['version']} - build ${Constants.horizonVer}', 24,
			Path.font('vcr'), 0xFFFFFFFF, LEFT, [otherCam])
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		add(horizonEngineText);

		var fnfVersion = Create.text(5, FlxG.height - 30, 'Friday Night Funkin\' v0.4.1', 24, Path.font('vcr'), 0xFFFFFFFF, LEFT, [otherCam])
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		add(fnfVersion);
		Path.clearUnusedMemory();
	}

	public override function update(elapsed:Float):Void
	{
		for (i in 0...menuOptions.length)
		{
			curveProgress[i] = FlxMath.lerp(curveProgress[i], (i - curSelected - 1 + menuOptions.length) / (2 * (menuOptions.length) - 1),
				FlxMath.bound(elapsed * 10, 0, 1));

			var point = Util.quadBezier(FlxPoint.weak(-FlxG.width * .6, -FlxG.width * .6), FlxPoint.weak(FlxG.width * .8, FlxG.height * .5),
				FlxPoint.weak(-FlxG.width * .6, FlxG.height * 1.6), curveProgress[i]);

			menuOptions[i].setPosition(point.x, point.y);
			point.putWeak();
		}
		super.update(elapsed);
	}

	public override function changeSelection(change:Int):Void
	{
		menuOptions[curSelected].x -= menuOptions[curSelected].width * .5;
		menuOptions[curSelected].y -= menuOptions[curSelected].height * .5;
		menuOptions[curSelected].animation.play('idle');
		menuOptions[curSelected].x += menuOptions[curSelected].width * .5;
		menuOptions[curSelected].y += menuOptions[curSelected].height * .5;

		super.changeSelection(change);

		menuOptions[curSelected].x -= menuOptions[curSelected].width * .5;
		menuOptions[curSelected].y -= menuOptions[curSelected].height * .5;
		menuOptions[curSelected].animation.play('selected');
		menuOptions[curSelected].x += menuOptions[curSelected].width * .5;
		menuOptions[curSelected].y += menuOptions[curSelected].height * .5;
	}

	public override function exitState():Void
	{
		super.exitState();
		transitioningOut = false;
		prevSelected = curSelected;
		if (curSelected == (4 - (modCount == 0 ? 1 : 0)))
			FlxG.openURL('https://needlejuicerecords.com/pages/friday-night-funkin');
		else
		{
			if (Settings.flashingLights)
				FlxFlicker.flicker(flashBG, 1.1, .15, false);
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
			if (Settings.flashingLights)
				FlxFlicker.flicker(menuOptions[curSelected], 1.3, .06, false, false, flicker -> out());
			else
				FlxTimer.wait(1.3, out.bind());
			for (i in 0...menuOptions.length)
				if (i != curSelected)
					FlxTween.tween(menuOptions[i], {alpha: 0}, .3, {
						ease: FlxEase.quintOut,
						type: ONESHOT,
						onComplete: tween -> menuOptions[i].destroy()
					});
		}
	}

	public override function returnState():Void
	{
		super.returnState();
		prevSelected = curSelected;
		MusicState.switchState(new TitleState());
	}

	inline function out():Void
		switch (curSelected)
		{
			case 0:
				MusicState.switchState(new StoryMenuState());
			case 1:
				// MusicState.switchState(new FreeplayState());
			case 2 if (modCount != 0):
				MusicState.switchState(new ModsMenuState());
			case 2:
				// MusicState.switchState(new CreditsState());
			case 5 | 4 if (modCount != 0):
				// MusicState.switchState(new OptionsState());
		}
}
