package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import modding.Mod;
import modding.ModManager;

class ModSelectionState extends MusicMenuState
{
	var backdrop:FlxBackdrop;
	var hue:Float = 0;
	var categoryOptions:Array<FlxSprite> = [];

	public override function create():Void
	{
		bpm = 0;
		if (ModManager.discoveredMods.length == 0)
			MusicState.switchState(new TitleState(), true, true);
		setupMenu();
		createMenuBackdrop();
		createMenuOptions(ModManager.discoveredMods);
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

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		hue += elapsed * 15;
		hue %= 359;
		backdrop.color = FlxColor.fromHSB(hue, 1, 0.7);
	}

	public function createMenuOptions(mods:Array<Mod>):Void
	{
		for (i in 0...mods.length)
		{
			var option = new Alphabet(FlxG.width / 2, 400 + (i * 100), mods[i].name, true, CENTER, 1.2);
			option.cameras = [optionsCam];
			option.alpha = 0.6;
			option.visible = false;
			add(option);
			menuOptions.push(option);
		}

		var option = new Alphabet(FlxG.width / 2, 400 + (menuOptions.length * 100), "Global Mods Only", true, CENTER, 1.2);
		option.cameras = [optionsCam];
		option.alpha = 0.6;
		option.visible = false;
		add(option);
		menuOptions.push(option);
	}

	public function createMenuBackdrop():Void
	{
		backdrop = new FlxBackdrop(Path.image("menuBGDesat"));
		backdrop.scale.set(1.6, 1.6);
		backdrop.velocity.set(50, 0);
		backdrop.screenCenter();
		backdrop.cameras = [menuCam];
		add(backdrop);
	}
}
