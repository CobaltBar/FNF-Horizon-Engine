package states;

import flixel.effects.FlxFlicker;
import lime.app.Application;

class MainMenuState extends MusicMenuState
{
	var bgFlash:FlxSprite;

	public override function create():Void
	{
		bpm = TitleState.titleData.bpm;
		setupMenu();
		createMenuBG();
		createMenuOptions(['story_mode', 'freeplay', 'mods', 'awards', 'credits', 'donate', 'options']);
		createVersionTexts();

		var i:Int = 0;
		new FlxTimer().start(0.1, (t:FlxTimer) ->
		{
			var trueX:Float = menuOptions[i].x;
			menuOptions[i].x -= (2000 * (i % 2 == 0 ? 1 : -1));
			menuOptions[i].visible = true;
			FlxTween.tween(menuOptions[i], {x: trueX}, 1, {
				type: ONESHOT,
				ease: FlxEase.expoOut,
			});
			i++;
		}, menuOptions.length);

		changeSelection(0, false);

		super.create();
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false):Void
	{
		super.changeSelection(change, set);
		menuOptions[curSelected].x -= menuOptions[curSelected].width * 0.5;
		menuOptions[curSelected].animation.play("idle");
		menuOptions[curSelected].x += menuOptions[curSelected].width * 0.5;

		set ? curSelected = change : curSelected += change;

		if (curSelected < 0)
			curSelected = menuOptions.length - 1;
		if (curSelected >= menuOptions.length)
			curSelected = 0;

		menuOptions[curSelected].x -= menuOptions[curSelected].width * 0.5;
		menuOptions[curSelected].animation.play("selected");
		menuOptions[curSelected].x += menuOptions[curSelected].width * 0.5;

		var offset:Float = 0;
		for (i in 0...menuOptions.length)
		{
			menuOptions[i].centerOffsets();
			menuOptions[i].y = 100 + offset;
			offset += menuOptions[i].height + 45;
		}

		optionsFollow.y = menuOptions[curSelected].y * 0.5 + 450;
		menuFollow.y = menuOptions[curSelected].y / 8 + 450;
	}

	public override function exitState()
	{
		super.exitState();
		if (curSelected == 5)
			Util.browserLoad('https://ninja-muffin24.itch.io/funkin');
		else
		{
			if (Settings.data.flashing)
				FlxFlicker.flicker(bgFlash, 1.1, 0.15, false);
			optionsCam.follow(menuOptions[curSelected], LOCKON, 0.12);
			transitioningOut = true;
			FlxTween.tween(optionsCam, {zoom: 1.2}, 1, {
				ease: FlxEase.expoOut,
				type: ONESHOT,
			});
			FlxTween.tween(menuCam, {zoom: 0.9}, 1, {
				ease: FlxEase.expoOut,
				type: ONESHOT,
			});
			FlxFlicker.flicker(menuOptions[curSelected], 1.2, 0.06, false, false, (flicker:FlxFlicker) ->
			{
				switch (curSelected)
				{
					case 0:
						MusicState.switchState(new StoryMenuState());
					case 1:
						MusicState.switchState(new FreeplayState());
					case 2:
						MusicState.switchState(new ModsMenuState());
					case 3:
						MusicState.switchState(new AwardsState());
					case 4:
						MusicState.switchState(new CreditsState());
					case 6:
						MusicState.switchState(new OptionsState());
				}
			});
			for (i in 0...menuOptions.length)
				if (i != curSelected)
					FlxTween.tween(menuOptions[i], {alpha: 0}, 0.3, {
						ease: FlxEase.quintOut,
						type: ONESHOT,
						onComplete: tween ->
						{
							menuOptions[i].destroy();
						}
					});
		}
	}

	public override function returnState()
	{
		super.returnState();
		MusicState.switchState(new TitleState());
	}

	public function createVersionTexts():Void
	{
		var wonderEngineText = Util.createText(5, FlxG.height - 65, "Wonder Engine v" + Application.current.meta.get("version"), 28, Path.font("vcr"),
			0xFFFFFFFF, LEFT)
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		wonderEngineText.cameras = [otherCam];
		add(wonderEngineText);

		var fnfVersion = Util.createText(5, FlxG.height - 35, "Friday Night Funkin' v0.2.8", 28, Path.font("vcr"), 0xFFFFFFFF, LEFT)
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		fnfVersion.cameras = [otherCam];
		add(fnfVersion);
	}

	public function createMenuOptions(options:Array<String>):Void
	{
		for (name in options)
		{
			var option = Util.createSparrowSprite(FlxG.width * 0.5, 0, name, 1.4);
			option.animation.addByPrefix("selected", name + " white", 24, true);
			option.animation.addByPrefix("idle", name + " basic", 24, true);
			option.animation.play("idle");
			option.cameras = [optionsCam];
			option.visible = false;
			option.updateHitbox();
			option.centerOffsets();
			add(option);
			menuOptions.push(option);
		}
		var offset:Float = 0;
		for (i in 0...options.length)
		{
			menuOptions[i].x = (FlxG.width - menuOptions[i].width) * 0.5;
			menuOptions[i].y = 100 + offset;
			offset += menuOptions[i].height + 45;
		}
	}

	public function createMenuBG():Void
	{
		bg = Util.createGraphicSprite(0, 0, Path.image("menuBG"), 1.7);
		bg.screenCenter();
		bg.cameras = [menuCam];
		add(bg);

		bgFlash = Util.createGraphicSprite(0, 0, Path.image("menuBGMagenta"), 1.7);
		bgFlash.screenCenter();
		bgFlash.cameras = [menuCam];
		bgFlash.visible = false;
		add(bgFlash);
	}
}
