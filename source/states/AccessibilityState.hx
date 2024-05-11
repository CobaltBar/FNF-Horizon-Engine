package states;

import flixel.addons.display.FlxGridOverlay;

class AccessibilityState extends MusicMenuState
{
	static var options = ['Flashing Lights', 'Reduced Motion', 'Low Quality Mode', 'Continue'];
	static var descriptions = [
		'Enable Flashing Lights',
		'Enable Reduced Motion',
		'Enable Low Quality Mode (Enable if your PC is bad)'
	];

	var checkboxes:Array<Checkbox> = [];
	var description:FlxText;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		DiscordRPC.change('In The Menus', 'Accessibility Menu');
		createUI();
		createOptions();
		changeSelection(0);
	}

	public override function update(elapsed:Float):Void
	{
		for (i in 0...menuOptions.length)
			menuOptions[i].setPosition(FlxMath.lerp(menuOptions[i].x, 200 - (50 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)),
				FlxMath.lerp(menuOptions[i].y, 350 - (200 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)));
		super.update(elapsed);
	}

	public override function changeSelection(change:Int):Void
	{
		menuOptions[curSelected].alpha = .6;
		super.changeSelection(change);
		if (curSelected != 3)
			description.text = descriptions[curSelected];
		description.screenCenter(X);
		menuOptions[curSelected].alpha = 1;
	}

	public override function exitState():Void
	{
		FlxG.sound.play(Path.sound('Confirm'), 0.7);
		if (curSelected == 3)
		{
			Settings.data.flashingLights = checkboxes[0].checked;
			Settings.data.reducedMotion = checkboxes[1].checked;
			Settings.data.lowQuality = checkboxes[2].checked;
			Settings.data.accessibilityConfirmed = true;
			MusicState.switchState(new TitleState());
		}
		else
			checkboxes[curSelected].checked = !checkboxes[curSelected].checked;
	}

	public override function returnState():Void {}

	private inline function createOptions():Void
		for (i in 0...options.length)
		{
			var option = new Alphabet(200 + (50 * i), 350 + (200 * i), options[i], true, LEFT);
			option.cameras = [optionsCam];
			option.alpha = .6;
			add(option);
			menuOptions.push(option);
			if (i == options.length - 1)
				continue;
			var checkbox:Checkbox = new Checkbox(0, 0, options[i] == 'Flashing Lights');
			checkbox.targetSprite = option;
			checkbox.offsetX = -checkbox.width - 25;
			checkbox.offsetY = (checkbox.height + option.height) * .5;
			checkbox.copyAlpha = true;
			checkbox.cameras = [optionsCam];
			checkbox.alpha = .6;
			add(checkbox);
			checkboxes.push(checkbox);
		}

	private inline function createUI():Void
	{
		var bg = Util.createBackdrop(FlxGridOverlay.create(128, 128, 256, 256, true, 0x85CCCCCC, 0x85FFFFFF).graphic);
		bg.velocity.set(50, 30);
		bg.cameras = [menuCam];
		add(bg);
		var descriptionBG = Util.makeSprite(0, FlxG.height - 50, FlxG.width, 50, 0xCC000000);
		descriptionBG.cameras = [otherCam];
		add(descriptionBG);
		description = Util.createText(0, FlxG.height - 45, 'N/A', 36, Path.font('vcr'), 0xFFFFFFFF, CENTER).setBorderStyle(OUTLINE, 0xFF000000, 2);
		description.screenCenter(X);
		description.cameras = [otherCam];
		add(description);
	}
}
