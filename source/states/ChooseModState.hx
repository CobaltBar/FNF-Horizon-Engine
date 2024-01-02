package states;

import flixel.FlxObject;
import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import modding.ModManager;

class ChooseModState extends MusicState
{
	var modTexts:Array<FlxSpriteGroup>;
	var title:FlxSpriteGroup;
	var bg:FlxBackdrop;
	var hue:Float = 0;

	var optionsCam:FlxCamera;
	var hudCam:FlxCamera;
	var curSelected:Int = 0;
	var optionsFollow:FlxObject;
	var transitioningOut:Bool = false;

	public override function create():Void
	{
		optionsCam = Util.createCamera(true);
		hudCam = Util.createCamera(true);
		createBG();
		optionsFollow = new FlxObject(FlxG.width / 2, FlxG.height / 2);
		optionsCam.follow(optionsFollow, LOCKON, 0.08);
		var totalHeight:Float = 0;

		modTexts = new Array<FlxSpriteGroup>();

		var defaultOption = Alphabet.generateText(FlxG.width / 2, 0, "None", true, Center);
		defaultOption.cameras = [optionsCam];
		totalHeight += defaultOption.height + 120;
		modTexts.push(defaultOption);
		add(defaultOption);

		for (mod in ModManager.standaloneMods)
		{
			var modText = Alphabet.generateTextWithIcon(FlxG.width / 2, 0, mod.name, true, Center, mod.icon);
			modText.y += totalHeight;
			modText.cameras = [optionsCam];
			totalHeight += modText.height + 50;
			modText.alpha = .5;
			modTexts.push(modText);
			add(modText);
		}
		changeSelection(0);
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		hue += elapsed * 15;
		hue %= 359;
		bg.color = FlxColor.fromHSB(hue, 1, 1);

		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[1], Settings.data.keybinds.get("ui")[5]]) && !transitioningOut)
			changeSelection(1);
		if (FlxG.keys.anyJustPressed([Settings.data.keybinds.get("ui")[2], Settings.data.keybinds.get("ui")[6]]) && !transitioningOut)
			changeSelection(-1);
		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")) && !transitioningOut)
		{
			transitioningOut = true;
			FlxG.sound.play("assets/sounds/Confirm.ogg", 0.7);
			FlxG.camera.flash();
			FlxTween.tween(optionsCam, {zoom: 1.2}, 1, {
				ease: FlxEase.quadOut,
				type: ONESHOT,
			});

			new FlxTimer().start(1, timer ->
			{
				ModManager.chooseModState = false;
				if (curSelected != 0)
				{
					ModManager.theChosenMod = ModManager.standaloneMods[curSelected];
					ModManager.replaceAssets();
				}
				MusicState.switchState(new TitleState());
			});

			for (i in 0...modTexts.length)
			{
				if (i != curSelected)
					FlxTween.tween(modTexts[i], {alpha: 0}, 0.5, {
						ease: FlxEase.quadOut,
						type: ONESHOT,
						onComplete: tween ->
						{
							modTexts[i].destroy();
						}
					});
			}
		}

		super.update(elapsed);
	}

	override function destroy()
	{
		untyped modTexts.length = 0;
		super.destroy();
	}

	private function changeSelection(add:Int)
	{
		FlxG.sound.play("assets/sounds/Scroll.ogg", 0.7);

		modTexts[curSelected].alpha = .5;

		curSelected += add;

		if (curSelected < 0)
			curSelected = modTexts.length - 1;
		if (curSelected >= modTexts.length)
			curSelected = 0;

		modTexts[curSelected].alpha = 1;

		optionsFollow.y = modTexts[curSelected].getScreenPosition().y;
	}

	private function createBG():Void
	{
		bg = new FlxBackdrop(FlxGridOverlay.create(128, 128, 256, 256, true, 0xffffffff, 0xffb9b9b9).graphic);
		bg.velocity.set(30, 20);
		bg.alpha = 0.3;
		bg.updateHitbox();
		bg.screenCenter(X);
		bg.cameras = [FlxG.camera];
		add(bg);
		title = Alphabet.generateText(FlxG.width / 2, 100, "Choose which mod you want to play!", true, Center);
		title.cameras = [hudCam];
		add(title);
	}
}
