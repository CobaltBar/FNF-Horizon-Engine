package states;

import flixel.addons.display.FlxBackdrop;
import flixel.addons.display.FlxGridOverlay;
import modding.ModManager;

class ChooseModState extends MusicState
{
	var modTexts:Array<FlxSpriteGroup> = new Array<FlxSpriteGroup>();
	var title:FlxSpriteGroup;
	var bg:FlxBackdrop;
	var hue:Float = 0;

	public override function create()
	{
		bg = new FlxBackdrop(FlxGridOverlay.create(128, 128, 256, 256, true, 0xffffffff, 0xffb8b8b8).graphic);
		bg.velocity.set(30, 20);
		bg.alpha = 0.3;
		bg.updateHitbox();
		bg.screenCenter(X);
		add(bg);
		add(new FlxSprite(FlxG.width / 2, 0).makeGraphic(1, FlxG.height));
		title = Alphabet.generateText(FlxG.width / 2, 100, "Choose which mod you want to play!", true, Center);
		add(title);
		for (mod in ModManager.standaloneMods)
		{
			var modText = Alphabet.generateTextWithIcon(FlxG.width / 2, FlxG.height / 2, mod.name, true, Center, mod.icon, 0.8);
			modTexts.push(modText);
			add(modText);
		}
		super.create();
	}

	public override function update(elapsed:Float)
	{
		hue += elapsed * 4;
		hue %= 359;
		bg.color = FlxColor.fromHSB(hue, 1, 1);
		super.update(elapsed);
	}
}
