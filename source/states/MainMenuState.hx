package states;

import flixel.FlxObject;
import flixel.effects.FlxFlicker;
import lime.app.Application;

class MainMenuState extends MusicState
{
	var menuBG:FlxSprite;
	var menuBGFlash:FlxSprite;
	var menuBGCam:FlxCamera;

	var menuBGFollow:FlxObject;

	var menuOptions:Array<FlxSprite> = new Array<FlxSprite>();
	var menuOptionsCam:FlxCamera;

	var menuOptionsFollow:FlxObject;

	var curSelection:Int = 0;

	var versionTexts:Array<FlxText> = new Array<FlxText>();

	var otherCam:FlxCamera;

	var transitioningOut:Bool = false;

	public override function create():Void
	{
		TitleState.comingBack = true;
		menuBGCam = Util.createCamera(true);
		menuOptionsCam = Util.createCamera(true);
		otherCam = Util.createCamera(true);

		createFollowPoints();

		menuBGCam.follow(menuBGFollow, LOCKON, 0.16);
		menuOptionsCam.follow(menuOptionsFollow, LOCKON, 0.12);

		createMenuBGs();
		createMenuOptions(['story_mode', 'freeplay', 'mods', 'awards', 'credits', 'donate', 'options']);
		createVersionTexts();
		new FlxTimer().start(0.5, (t:FlxTimer) ->
		{
			startMenuAnimation();
		});

		super.create();
	}

	public override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;
		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[1], Settings.data.keybinds.get("ui")[5]]))
			changeSelection(1);
		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[2], Settings.data.keybinds.get("ui")[6]]))
			changeSelection(-1);
		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")))
		{
			if (!transitioningOut)
			{
				FlxG.sound.play("assets/sounds/Confirm.ogg", 0.7);
				if (curSelection == 5)
				{
					Util.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					if (Settings.data.flashing)
						FlxFlicker.flicker(menuBGFlash, 1.1, 0.15, false);

					menuOptionsCam.follow(menuOptions[curSelection], LOCKON, 0.12);
					transitioningOut = true;
					FlxTween.tween(menuOptionsCam, {zoom: 1.2}, 1, {
						ease: FlxEase.quadOut,
						type: ONESHOT,
					});
					FlxFlicker.flicker(menuOptions[curSelection], 1.2, 0.06, false, false, (flicker:FlxFlicker) ->
					{
						switch (curSelection)
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
					{
						if (i != curSelection)
							FlxTween.tween(menuOptions[i], {alpha: 0}, 0.5, {
								ease: FlxEase.quadOut,
								type: ONESHOT,
							}); // TODO kill sprite
					}
				}
			}
		}
		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("back")))
			MusicState.switchState(new TitleState());
		super.update(elapsed);
	}

	private function createVersionTexts():Void
	{
		var wonderEngineVersion = Util.createText(5, FlxG.height - 75, "Wonder Engine v" + Application.current.meta.get("version"), 28,
			"assets/fonts/vcr.ttf", 0xFFFFFFFF, LEFT)
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		versionTexts.push(wonderEngineVersion);
		wonderEngineVersion.cameras = [otherCam];
		add(wonderEngineVersion);
		var fnfVersion = Util.createText(5, FlxG.height - 45, "Friday Night Funkin' v0.2.8", 28, "assets/fonts/vcr.ttf", 0xFFFFFFFF, LEFT)
			.setBorderStyle(OUTLINE, 0xFF000000, 2);
		versionTexts.push(fnfVersion);
		fnfVersion.cameras = [otherCam];
		add(fnfVersion);
	}

	private function createFollowPoints():Void
	{
		menuBGFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
		menuOptionsFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
	}

	private function createMenuOptions(options:Array<String>):Void
	{
		for (name in options)
		{
			var option = Util.createSparrowSprite(FlxG.width / 2, 0, "assets/images/mainMenu/" + name);
			option.animation.addByPrefix("selected", name + " white", 24, true);
			option.animation.addByPrefix("idle", name + " basic", 24, true);
			option.animation.play("idle");
			option.cameras = [menuOptionsCam];
			Util.scale(option, 1.4);
			option.visible = false;
			add(option);
			menuOptions.push(option);
		}

		var offset:Float = 0;
		for (i in 0...options.length)
		{
			menuOptions[i].x = (FlxG.width - menuOptions[i].width) / 2;
			menuOptions[i].y = 100 + offset;
			offset += menuOptions[i].height + 45;
		}
	}

	private function createMenuBGs():Void
	{
		menuBG = Util.createSprite(200, 200, "assets/images/menuBG.png");
		Util.scale(menuBG, 1.7);
		menuBG.screenCenter(X);
		menuBG.cameras = [menuBGCam];
		add(menuBG);

		menuBGFlash = Util.createSprite(200, 200, "assets/images/menuBG.png");
		Util.scale(menuBGFlash, 1.7);
		menuBGFlash.screenCenter(X);
		menuBGFlash.cameras = [menuBGCam];
		menuBGFlash.visible = false;
		add(menuBGFlash);
	}

	private function startMenuAnimation():Void
	{
		for (i in 0...menuOptions.length)
		{
			var trueX:Float = menuOptions[i].x;
			if (i % 2 == 0)
				menuOptions[i].x -= 2000;
			else
				menuOptions[i].x += 2000;
			menuOptions[i].visible = true;
			FlxTween.tween(menuOptions[i], {x: trueX}, 1, {
				type: ONESHOT,
				ease: FlxEase.backOut,
			});
		}

		changeSelection(0);
	}

	private function changeSelection(add:Int)
	{
		FlxG.sound.play("assets/sounds/Scroll.ogg", 0.7);
		menuOptions[curSelection].x -= menuOptions[curSelection].width / 2;
		menuOptions[curSelection].animation.play("idle");
		menuOptions[curSelection].x += menuOptions[curSelection].width / 2;

		curSelection += add;

		if (curSelection < 0)
			curSelection = menuOptions.length - 1;
		if (curSelection >= menuOptions.length)
			curSelection = 0;

		menuOptions[curSelection].x -= menuOptions[curSelection].width / 2;
		menuOptions[curSelection].animation.play("selected");
		menuOptions[curSelection].x += menuOptions[curSelection].width / 2;
		reoffsetMenuOptions();

		menuOptionsFollow.y = menuOptions[curSelection].y / 2 + 450;
		menuBGFollow.y = menuOptions[curSelection].y / 9 + 480;
	}

	private function reoffsetMenuOptions()
	{
		var offset:Float = 0;
		for (i in 0...menuOptions.length)
		{
			menuOptions[i].centerOffsets();
			menuOptions[i].y = 100 + offset;
			offset += menuOptions[i].height + 45;
		}
	}
}
