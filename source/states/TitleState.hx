package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import sys.io.File;
import tjson.TJSON;

typedef TitleData =
{
	bpm:Int,
	gfPosition:Array<Int>,
	logoPosition:Array<Int>,
	enterPosition:Array<Int>
}

class TitleState extends MusicState
{
	var gf:FlxSprite;
	var titleEnter:FlxSprite;
	var logo:FlxSprite;
	var titleData:TitleData;
	var skippedIntro:Bool = false;
	var enterMainMenu:Bool = false;

	public static var comingBack:Bool = false;

	var titleTimer:Float = 0;
	var introTexts:Array<FlxSpriteGroup> = new Array<FlxSpriteGroup>();
	var introImages:Array<FlxSprite> = new Array<FlxSprite>();
	var goofyTexts:Array<String> = new Array<String>();

	public override function create():Void
	{
		Settings.load();
		loadTitleData();
		generateObjects();

		if (comingBack)
			skipIntro();

		super.create();
	}

	public override function onBeat(timer:FlxTimer):Void
	{
		if (gf.visible)
		{
			if (curBeat % 2 == 0)
				gf.animation.play("danceLeft");
			else
				gf.animation.play("danceRight");
		}

		if (logo.visible)
			logo.animation.play("Bop", true);

		if (!skippedIntro)
		{
			switch (curBeat)
			{
				case 1:
					FlxG.sound.playMusic("assets/songs/Gettin Freaky.ogg", 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					createIntroText("Wonder Engine by", 100);
				case 4:
					createIntroText("Cobalt Bar", -50);
				case 5:
					clearIntroTexts();
				case 6:
					createIntroText("Not Associated with", 200);
				case 8:
					createIntroText("Newgrounds", 100);
					createIntroImage("assets/images/title/newgrounds_logo.png", 0);
				case 9:
					clearIntroTexts();
					clearIntroImages();
				case 10:
					createIntroText(goofyTexts[0], 50);
				case 12:
					createIntroText(goofyTexts[1], -50);
				case 13:
					clearIntroTexts();
				case 14:
					createIntroText("Friday", 100);
				case 15:
					createIntroText("Night", 0);
				case 16:
					createIntroText("Funkin'", -100);
				case 17:
					skipIntro();
			}
		}

		super.onBeat(timer);
	}

	public override function update(elapsed:Float):Void
	{
		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")))
		{
			if (!skippedIntro)
			{
				skipIntro();
			}
			else if (!enterMainMenu)
			{
				enterMainMenu = true;
				titleEnter.color = 0xffffffff;
				titleEnter.alpha = 1;
				titleEnter.animation.play("Pressed");
				FlxG.sound.play("assets/sounds/Confirm.ogg", 0.7);
				new FlxTimer().start(1, function(tmr:FlxTimer):Void
				{
					MusicState.switchState(new MainMenuState(), false);
				});
			}
		}

		titleTimer += FlxMath.bound(elapsed, 0, 1);
		if (titleTimer > 2)
			titleTimer -= 2;

		var timer:Float = titleTimer;
		if (timer >= 1)
			timer = (-timer) + 2;

		timer = FlxEase.quadInOut(timer);

		if (titleEnter.visible && !enterMainMenu)
		{
			titleEnter.color = FlxColor.interpolate(0xFF33FFFF, 0xFF3333CC, timer);
			titleEnter.alpha = FlxMath.lerp(1, 0.64, timer);
		}

		super.update(elapsed);
	}

	private function skipIntro():Void
	{
		skippedIntro = true;
		clearIntroTexts();
		gf.visible = true;
		logo.visible = true;
		titleEnter.visible = true;
		FlxG.camera.flash(0xffffffff, 1);
		if (curBeat % 2 == 0)
			gf.animation.play("danceLeft");
		else
			gf.animation.play("danceRight");
		logo.animation.play("Bop", true);
	}

	private function loadTitleData():Void
	{
		titleData = TJSON.parse(File.getContent("assets/data/titleData.json"));
		bpm = titleData.bpm;
		var goofyTextList = File.getContent("assets/data/introTexts.txt").split('\n');
		var num = FlxG.random.int(0, goofyTextList.length - 1);
		goofyTexts.push(goofyTextList[num].split('--')[0]);
		goofyTexts.push(goofyTextList[num].split('--')[1]);
	}

	private function generateObjects():Void
	{
		gf = Util.createSparrowSprite(titleData.gfPosition[0], titleData.gfPosition[1], "assets/images/title/gfDanceTitle");
		Util.scale(gf, 1.35);
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gf.visible = false;
		add(gf);

		logo = Util.createSparrowSprite(titleData.logoPosition[0], titleData.logoPosition[1], "assets/images/title/logoBumpin");
		Util.scale(logo, 1.4);
		logo.animation.addByPrefix("Bop", "logo bumpin", 24, false);
		logo.visible = false;
		add(logo);

		titleEnter = Util.createSparrowSprite(titleData.enterPosition[0], titleData.enterPosition[1], "assets/images/title/titleEnter");
		Util.scale(titleEnter, 1.3);
		titleEnter.animation.addByPrefix("Pressed", "ENTER PRESSED", 24, true);
		titleEnter.animation.addByPrefix("Idle", "ENTER IDLE", 24, true);
		titleEnter.animation.play("Idle");
		titleEnter.visible = false;
		add(titleEnter);
	}

	private function createIntroText(text:String, yOff:Float):Void
	{
		var texts:FlxSpriteGroup = Alphabet.generateText(FlxG.width / 2, FlxG.height / 2, text, true, Center, yOff);
		introTexts.push(texts);
		add(texts);
	}

	private function createIntroImage(path:String, yOff:Float):Void
	{
		var img:FlxSprite = Util.createSprite(FlxG.width / 2, FlxG.height / 2 + yOff, path);
		Util.scale(img, 1.4, 1.4);
		img.screenCenter(X);
		introImages.push(img);
		add(img);
	}

	private function clearIntroTexts():Void
	{
		for (i in 0...introTexts.length)
		{
			introTexts[introTexts.length - 1].destroy();
			introTexts.pop();
		}
	}

	private function clearIntroImages():Void
	{
		for (i in 0...introImages.length)
		{
			introImages[introImages.length - 1].destroy();
			introImages.pop();
		}
	}
}
