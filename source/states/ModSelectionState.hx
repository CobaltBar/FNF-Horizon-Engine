package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import modding.Mod;
import modding.ModManager;

class ModSelectionState extends MusicMenuState
{
	var backdrop:FlxBackdrop;
	var hue:Float = 0;

	public override function create():Void
	{
		bpm = 0;
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
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		hue += elapsed * 15;
		hue %= 359;
		backdrop.color = FlxColor.fromHSB(hue, 1, 1);
	}

	public function createMenuOptions(mods:Array<Mod>):Void
	{
		for (i in 0...mods.length)
		{
			var option = new Alphabet(FlxG.width / 2, 400 + (i * 100), mods[i].name, true, CENTER, 1.2);
			option.cameras = [optionsCam];
			option.visible = false;
			add(option);
			menuOptions.push(option);
		}

		var option = new Alphabet(FlxG.width / 2, 400 + (menuOptions.length * 100), "Global Mods Only", true, CENTER, 1.2);
		option.cameras = [optionsCam];
		option.visible = false;
		add(option);
		menuOptions.push(option);
	}

	public function createMenuBackdrop():Void
	{
		backdrop = new FlxBackdrop(Path.image("menuBGDesat"));
		backdrop.scale.set(1.4, 1.4);
		backdrop.velocity.set(50, 0);
		backdrop.screenCenter();
		backdrop.cameras = [menuCam];
		add(backdrop);
	}
}
