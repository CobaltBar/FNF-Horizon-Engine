package states;

import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;

class AccessibilityState extends MusicMenuState
{
	static var options = ['Flashing Lights', 'Reduced Motion', 'Low Quality Mode', 'Continue'];
	static var descriptions = [
		'Enable Flashing Lights',
		'Enable Reduced Motion (Disables the insane Title and Main Menu Tweens)',
		'Enable Low Quality Mode (Enable if your PC is bad)',
		'Continue'
	];

	var checkboxes:Array<Checkbox> = [];
	var description:FlxText;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();

		#if DISCORD_ENABLED
		DiscordRPC.change('In the Menus', 'Accessibility Screen');
		#end

		var bg = Create.backdrop(FlxGridOverlay.create(128, 128, 256, 256, true, 0x85252525, 0x85505050).graphic);
		bg.velocity.set(50, 30);
		bg.cameras = [menuCam];
		add(bg);

		var descriptionBG = Create.graphic(0, FlxG.height - 50, FlxG.width, 50, 0xCC000000);
		descriptionBG.cameras = [otherCam];
		add(descriptionBG);

		description = Create.text(0, FlxG.height - 45, 'N/A', 36, Path.font('vcr'), 0xFFFFFFFF, CENTER).setBorderStyle(OUTLINE, 0xFF000000, 2);
		description.screenCenter(X);
		description.cameras = [otherCam];
		add(description);

		for (i in 0...options.length)
		{
			var option = new Alphabet(300 + (50 * i), 500 + (200 * i), options[i], true, LEFT);
			option.cameras = [optionsCam];
			option.alpha = .6;
			add(option);
			menuOptions.push(option);
			if (i == options.length - 1)
				continue;
			var checkbox:Checkbox = new Checkbox(0, 0, options[i] == 'Flashing Lights');
			checkbox.targetSpr = option;
			checkbox.offsetX = -checkbox.width - 25;
			checkbox.offsetY = checkbox.height * .5;
			checkbox.copyAlpha = true;
			checkbox.cameras = [optionsCam];
			checkbox.alpha = .6;
			add(checkbox);
			checkboxes.push(checkbox);
		}

		changeSelection(0);
		Path.clearUnusedMemory();
	}

	public override function update(elapsed:Float):Void
	{
		for (i in 0...menuOptions.length)
			menuOptions[i].setPosition(FlxMath.lerp(menuOptions[i].x, 300 - (50 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)),
				FlxMath.lerp(menuOptions[i].y, 500 - (200 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)));
		super.update(elapsed);
	}

	public override function changeSelection(change:Int):Void
	{
		menuOptions[curSelected].alpha = .6;
		super.changeSelection(change);
		description.text = descriptions[curSelected];
		description.screenCenter(X);
		menuOptions[curSelected].alpha = 1;
	}

	public override function exitState():Void
	{
		FlxG.sound.play(Path.audio('Confirm'), .7);
		if (curSelected == 3)
		{
			Settings.data.flashingLights = checkboxes[0].checked;
			Settings.data.reducedMotion = checkboxes[1].checked;
			Settings.data.lowQuality = checkboxes[2].checked;
			Settings.data.accessibilityConfirmed = true;
			Settings.save();
			transitioningOut = true;
			if (!Settings.data.reducedMotion)
			{
				new FlxTimer().start(.1, timer ->
				{
					FlxTween.tween(menuOptions[timer.loopsLeft], {x: menuOptions[timer.loopsLeft].x - 1250}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
				}, menuOptions.length - 1);

				FlxTween.tween(menuOptions[menuOptions.length - 1],
					{x: (FlxG.width - menuOptions[menuOptions.length - 1].width) * .5, y: (FlxG.height - menuOptions[menuOptions.length - 1].height) * .5},
					.75, {type: ONESHOT, ease: FlxEase.expoOut});
				FlxTween.tween(optionsCam, {zoom: 2}, .75, {type: ONESHOT, ease: FlxEase.expoOut});
			}

			FlxFlicker.flicker(menuOptions[menuOptions.length - 1], .75, 0.06, true, true, flicker -> MusicState.switchState(new TitleState(), true));
		}
		else
			checkboxes[curSelected].checked = !checkboxes[curSelected].checked;
	}

	public override function returnState():Void {}
}
