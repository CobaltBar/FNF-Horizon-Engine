package states;

import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tweens.misc.NumTween;

class TitleState extends MusicState
{
	var gf:FlxSprite;
	var titleEnter:FlxSprite;
	var titleEnterTimer:Float = 0;
	var logo:FlxSprite;
	var skippedIntro:Bool = false;

	var introTexts:Array<Alphabet> = [];
	var introImages:Array<FlxSprite> = [];
	var goofyTexts:Array<String> = [];

	static var titleData:TitleJSON;
	static var comingBack:Bool = false;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		persistentUpdate = true;

		#if DISCORD_ENABLED
		DiscordRPC.change('In the Menus', 'Title Screen');
		#end

		titleData = Path.json('titleData');
		Conductor.bpm = titleData.bpm;
		var goofyTextList = Path.txt('introTexts').split('\n');
		var num = FlxG.random.int(0, goofyTextList.length - 1);
		goofyTexts.push(goofyTextList[num].split('--')[0]);
		goofyTexts.push(goofyTextList[num].split('--')[1]);

		gf = Create.sparrow(titleData.gfPosition[0], titleData.gfPosition[1], Path.sparrow('gfDanceTitle'), 1.35);
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
		gf.visible = false;
		add(gf);

		logo = Create.sparrow(titleData.logoPosition[0], titleData.logoPosition[1], Path.sparrow('logoBumpin'), 1.4);
		logo.animation.addByPrefix('bop', 'logo bumpin', 24, false);
		logo.visible = false;
		add(logo);

		titleEnter = Create.sparrow(titleData.startPosition[0], titleData.startPosition[1], Path.sparrow('titleEnter'), 1.4);
		titleEnter.animation.addByPrefix('Pressed', 'ENTER PRESSED', 24, true);
		titleEnter.animation.addByPrefix('idle', 'ENTER IDLE', 24, true);
		titleEnter.animation.play('idle');
		titleEnter.visible = false;
		add(titleEnter);

		FlxTween.num(0, 1, 2, {type: PINGPONG, ease: FlxEase.quadInOut}, num -> titleEnterTimer = num);

		if (comingBack)
			skipIntro();
		else
		{
			if (FlxG.sound.music == null)
				FlxG.sound.playMusic(Path.audio('menuSong'), 0);
		}

		Path.clearUnusedMemory();
	}

	public override function update(elapsed:Float):Void
	{
		if (Controls.accept)
		{
			if (!skippedIntro)
				skipIntro();
			else
			{
				if (!transitioningOut)
				{
					transitioningOut = true;
					titleEnter.color = 0xFFFFFFFF;
					titleEnter.alpha = 1;
					titleEnter.animation.play('Pressed');
					FlxG.sound.play(Path.audio('Confirm'), .7);
					if (!FlxG.sound.music.playing)
					{
						FlxG.sound.music.resume();
						FlxG.sound.music.fadeIn(2, 0, .7);
					}
					FlxTween.tween(titleEnter, {y: FlxG.height + 300}, 1, {type: ONESHOT, ease: FlxEase.backIn});
					FlxTween.tween(gf, {x: FlxG.width + 300}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
					FlxTween.tween(logo, {x: (FlxG.width - logo.width) * .5}, .75, {type: ONESHOT, ease: FlxEase.expoOut});
					FlxTween.tween(logo, {y: (FlxG.height - logo.height) * .5}, .45, {
						type: ONESHOT,
						ease: FlxEase.expoOut,
						onComplete: tween -> Settings.data.reducedMotion ? FlxTween.tween(logo, {alpha: 0}, .5,
							{type: ONESHOT, ease: FlxEase.expoIn}) : FlxTween.tween(logo, {y: -1250}, .5, {type: ONESHOT, ease: FlxEase.expoIn})
					});
					FlxTween.tween(logo.scale, {x: 2.25, y: 2.25}, .75, {
						type: ONESHOT,
						ease: FlxEase.expoOut,
						onComplete: tween -> FlxTimer.wait(.5, () ->
						{
							comingBack = true;
							MusicState.switchState(new MainMenuState(), false, true);
						})
					});
				}
			}
		}

		if (titleEnter.visible && !transitioningOut)
		{
			titleEnter.color = FlxColor.interpolate(0xFF33FFFF, 0xFF3333CC, titleEnterTimer);
			titleEnter.alpha = FlxMath.lerp(1, .64, titleEnterTimer);
		}

		super.update(elapsed);
	}

	public override function onBeat():Void
	{
		gf.animation.play(curBeat % 2 == 0 ? 'danceLeft' : 'danceRight');
		logo.animation.play('bop', true);

		if (!skippedIntro)
			switch (curBeat)
			{
				case 1:
					FlxG.sound.music.fadeIn(4, 0, .7);
					createIntroText('Horizon Engine by', -50);
				case 3:
					tweenLastIntroText(1, 150);
					createIntroText('Cobalt Bar', -50);
					introTexts[1].setColorTransform(0, .5, 1, 1, 0, 0, 0, 0);
				case 4:
					Settings.data.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects();
				case 5:
					createIntroText('Not Associated with', 100);
				case 7:
					tweenLastIntroText(1, 150);
					createIntroText('Newgrounds', 100);
					createIntroImage(Path.image('newgrounds_logo'), 0);
				case 8:
					Settings.data.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects();
				case 9:
					createIntroText(goofyTexts[0], 50);
				case 11:
					tweenLastIntroText(1, 50);
					createIntroText(goofyTexts[1], -50);
				case 12:
					Settings.data.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects();
				case 13:
					bop = false;
					targetZoom = 1.2;
					createIntroText('Friday', -100);
				case 14:
					targetZoom = 1.35;
					tweenLastIntroText(1, 100);
					createIntroText('Night', -100);
				case 15:
					targetZoom = 1.5;
					tweenLastIntroText(1, 100);
					tweenLastIntroText(2, 100);
					createIntroText('Funkin\'', -100);
				case 16:
					skipIntro();
			}

		super.onBeat();
	}

	function skipIntro():Void
	{
		skippedIntro = gf.visible = logo.visible = titleEnter.visible = bop = true;
		targetZoom = FlxG.camera.zoom = 1;
		clearIntroObjects();
		FlxG.camera.flash();
	}

	function createIntroText(text:String, yOff:Float):Alphabet
	{
		var alphabet = new Alphabet(FlxG.width * 2 * (introTexts.length % 2 == 0 ? 1 : -1), FlxG.height * .5, text, true, CENTER, 1.4, 0, yOff);
		introTexts.push(alphabet);
		add(alphabet);
		FlxTween.tween(alphabet, {x: FlxG.width * .5}, .5, {type: ONESHOT, ease: FlxEase.expoOut});
		return alphabet;
	}

	function createIntroImage(path:FlxGraphicAsset, yOff:Float):FlxSprite
	{
		var img:FlxSprite = Create.sprite(0, FlxG.height * 2, path, 1.4);
		img.screenCenter(X);
		introImages.push(img);
		add(img);
		FlxTween.tween(img, {y: FlxG.height * .5 + yOff}, .5, {type: ONESHOT, ease: FlxEase.expoOut});
		return img;
	}

	function tweenOutIntroObjects():Void
	{
		for (i in 0...introTexts.length)
			FlxTween.tween(introTexts[i], {y: -1250 * (i % 2 == 0 ? 1 : -1)}, .5,
				{type: ONESHOT, ease: FlxEase.expoIn, onComplete: tween -> introTexts[i].destroy()});
		for (obj in introImages)
			FlxTween.tween(obj, {y: -1250 * (obj.y > FlxG.height * .5 ? 1 : -1)}, .5,
				{type: ONESHOT, ease: FlxEase.expoIn, onComplete: tween -> obj.destroy()});
	}

	private function clearIntroObjects():Void
	{
		for (obj in introTexts)
		{
			FlxTween.cancelTweensOf(obj);
			obj.destroy();
		}
		introTexts = [];
		for (obj in introImages)
		{
			FlxTween.cancelTweensOf(obj);
			obj.destroy();
		}
		introImages = [];
	}

	inline function tweenLastIntroText(howFarBack:Int = 1, yOff:Float):Void
		FlxTween.tween(introTexts[introTexts.length - howFarBack], {y: introTexts[introTexts.length - howFarBack].y - yOff}, .5,
			{type: ONESHOT, ease: FlxEase.expoOut});
}
