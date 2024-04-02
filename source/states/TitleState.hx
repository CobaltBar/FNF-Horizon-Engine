package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.misc.VarTween;
import modding.ModManager;
import sys.io.File;

typedef TitleData =
{
	bpm:Float,
	gfPosition:Array<Int>,
	logoPosition:Array<Int>,
	startPosition:Array<Int>
}

class TitleState extends MusicState
{
	var gf:FlxSprite;
	var titleEnter:FlxSprite;
	var logo:FlxSprite;
	var skippedIntro:Bool = false;
	var titleTimer:Float = 0;
	var introTexts:Array<Alphabet> = [];
	var introImages:Array<FlxSprite> = [];
	var goofyTexts:Array<String> = [];

	public static var titleData:TitleData;

	static var comingBack:Bool = false;

	public override function create():Void
	{
		Path.clearStoredMemory();
		loadTitleData();
		generateObjects();
		if (!comingBack && FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(Path.sound("menuSong"), 0);
			FlxG.sound.music.onComplete = () ->
			{
				curBeat = curStep = 0;
				curDecBeat = 0;
			}
		}
		if (comingBack)
			skipIntro();
		super.create();
	}

	public override function update(elapsed:Float):Void
	{
		if (FlxG.keys.anyJustPressed(Settings.data.keybinds.get("accept")))
		{
			if (!skippedIntro)
			{
				skipIntro();
			}
			else if (!transitioningOut)
			{
				transitioningOut = true;
				titleEnter.color = 0xffffffff;
				titleEnter.alpha = 1;
				titleEnter.animation.play("Pressed");
				FlxG.sound.play(Path.sound("Confirm"), 0.7);
				if (!FlxG.sound.music.playing)
				{
					FlxG.sound.music.resume();
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				}
				FlxTween.tween(titleEnter, {y: FlxG.height + 300}, 1, {
					type: ONESHOT,
					ease: FlxEase.expoOut,
				});
				FlxTween.tween(gf, {x: FlxG.width + 300}, 1, {
					type: ONESHOT,
					ease: FlxEase.expoOut,
				});
				FlxTween.tween(logo, {x: (FlxG.width - logo.width) * 0.5, y: (FlxG.height - logo.height) * 0.5}, 1, {
					type: ONESHOT,
					ease: FlxEase.expoOut,
				});
				new FlxTimer().start(0.3, (tmr:FlxTimer) ->
				{
					FlxTween.tween(logo, {alpha: 0}, 1, {
						type: ONESHOT,
						ease: FlxEase.expoOut,
					});
				});
				FlxTween.tween(logo.scale, {x: 2, y: 2}, 1, {
					type: ONESHOT,
					ease: FlxEase.expoOut,
				});
				new FlxTimer().start(1, (tmr:FlxTimer) ->
				{
					comingBack = true;
					MusicState.switchState(new MainMenuState(), false, true);
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

		if (titleEnter.visible && !transitioningOut)
		{
			titleEnter.color = FlxColor.interpolate(0xFF33FFFF, 0xFF3333CC, timer);
			titleEnter.alpha = FlxMath.lerp(1, 0.64, timer);
		}

		super.update(elapsed);
	}

	public override function onBeat():Void
	{
		if (gf.visible)
		{
			if (curBeat % 2 == 0)
				gf.animation.play("danceLeft");
			else
				gf.animation.play("danceRight");
		}

		if (logo.visible)
			logo.animation.play("bop", true);

		if (!skippedIntro)
		{
			switch (curBeat)
			{
				case 0:
					FlxG.sound.music.fadeIn(4, 0, 0.7);
					createIntroText("Wonder Engine by", -50);
				case 2:
					tweenLastIntroText(1, 150);
					createIntroText("Cobalt Bar", -50);
				case 3:
					clearIntroTexts();
				case 4:
					createIntroText("Not Associated with", 100);
				case 6:
					tweenLastIntroText(1, 150);
					createIntroText("Newgrounds", 100);
					createIntroImage(Path.image("newgrounds_logo"), 0);
				case 7:
					clearIntroTexts();
					clearIntroImages();
				case 8:
					createIntroText(goofyTexts[0], 50);
				case 10:
					tweenLastIntroText(1, 50);
					createIntroText(goofyTexts[1], -50);
				case 11:
					clearIntroTexts();
				case 12:
					shouldBop = false;
					targetZoom = 1.2;
					createIntroText("Friday", -100);
				case 13:
					targetZoom = 1.35;
					tweenLastIntroText(1, 100);
					createIntroText("Night", -100);
				case 14:
					targetZoom = 1.5;
					tweenLastIntroText(1, 100);
					tweenLastIntroText(2, 100);
					createIntroText("Funkin'", -100);
				case 15:
					skipIntro();
			}
		}

		super.onBeat();
	}

	private function skipIntro():Void
	{
		skippedIntro = gf.visible = logo.visible = titleEnter.visible = shouldBop = true;
		targetZoom = 1;
		clearIntroTexts();
		clearIntroImages();
		FlxG.camera.flash(0xFFFFFFFF, 1, () -> {}, true);
		if (curBeat % 2 == 0)
			gf.animation.play("danceLeft");
		else
			gf.animation.play("danceRight");
		logo.animation.play("bop", true);
	}

	private function createIntroText(text:String, yOff:Float):Alphabet
	{
		var oldX = FlxG.width * 2 * (introTexts.length % 2 == 0 ? -1 : 1);
		var alphabet:Alphabet = new Alphabet(oldX, FlxG.height * 0.5, text, true, CENTER, 1.4, 0, yOff);
		introTexts.push(alphabet);
		add(alphabet);
		FlxTween.tween(alphabet, {x: alphabet.x - oldX + FlxG.width * 0.5}, 0.5, {
			type: ONESHOT,
			ease: FlxEase.expoOut,
		});
		return alphabet;
	}

	private function createIntroImage(path:flixel.system.FlxAssets.FlxGraphicAsset, yOff:Float):FlxSprite
	{
		var img:FlxSprite = Util.createGraphicSprite(FlxG.width * 0.5, FlxG.height * 2, path, 1.4);
		img.screenCenter(X);
		introImages.push(img);
		add(img);
		FlxTween.tween(img, {y: FlxG.height * 0.5 + yOff}, 0.5, {
			type: ONESHOT,
			ease: FlxEase.expoOut
		});
		return img;
	}

	private function clearIntroTexts():Void
	{
		for (obj in introTexts)
		{
			obj.destroy();
		}
		introTexts = [];
	}

	private function clearIntroImages():Void
	{
		for (obj in introImages)
			obj.destroy();
		introImages = [];
	}

	private function tweenLastIntroText(howFarBack:Int = 1, yOff:Float):Void
	{
		FlxTween.tween(introTexts[introTexts.length - howFarBack], {y: introTexts[introTexts.length - howFarBack].y - yOff}, 0.5, {
			type: ONESHOT,
			ease: FlxEase.expoOut,
		});
	}

	private function loadTitleData():Void
	{
		titleData = Path.json("titleData");
		Conductor.bpm = titleData.bpm;
		var goofyTextList = Path.txt("introTexts").split('\n');
		var num = FlxG.random.int(0, goofyTextList.length - 1);
		goofyTexts.push(goofyTextList[num].split('--')[0]);
		goofyTexts.push(goofyTextList[num].split('--')[1]);
	}

	private function generateObjects():Void
	{
		gf = Util.createSparrowSprite(titleData.gfPosition[0], titleData.gfPosition[1], "gfDanceTitle", 1.35);
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gf.visible = false;
		add(gf);

		logo = Util.createSparrowSprite(titleData.logoPosition[0], titleData.logoPosition[1], "logoBumpin", 1.4);
		logo.animation.addByPrefix("bop", "logo bumpin", 24, false);
		logo.visible = false;
		add(logo);

		titleEnter = Util.createSparrowSprite(titleData.startPosition[0], titleData.startPosition[1], "titleEnter", 1.3);
		titleEnter.animation.addByPrefix("Pressed", "ENTER PRESSED", 24, true);
		titleEnter.animation.addByPrefix("idle", "ENTER IDLE", 24, true);
		titleEnter.animation.play("idle");
		titleEnter.visible = false;
		add(titleEnter);
	}
}
