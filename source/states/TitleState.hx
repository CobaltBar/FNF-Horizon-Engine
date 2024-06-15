package states;

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

	@:noCompletion static var titleData:TitleJsonData;
	static var comingBack:Bool = false;

	public override function create()
	{
		Path.clearStoredMemory();
		super.create();
		DiscordRPC.change('In The Menus', 'The Title');
		persistentUpdate = true;
		loadTitleData();
		generateObjects();
		if (!comingBack && FlxG.sound.music == null)
			FlxG.sound.playMusic(Path.sound('menuSong'), 0);
		if (comingBack)
			skipIntro();
	}

	public override function update(elapsed:Float)
	{
		if (Controls.accept)
		{
			if (!skippedIntro)
				skipIntro();
			else if (!transitioningOut)
			{
				transitioningOut = true;
				titleEnter.color = 0xffffffff;
				titleEnter.alpha = 1;
				titleEnter.animation.play('Pressed');
				FlxG.sound.play(Path.sound('Confirm'), .7);
				if (!FlxG.sound.music.playing)
				{
					FlxG.sound.music.resume();
					FlxG.sound.music.fadeIn(2, 0, .7);
				}
				FlxTween.tween(titleEnter, {y: FlxG.height + 300}, 1, {type: ONESHOT, ease: FlxEase.backIn,});
				FlxTween.tween(gf, {x: FlxG.width + 300}, 1, {type: ONESHOT, ease: FlxEase.expoOut,});
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
					onComplete: tween ->
					{
						FlxTimer.wait(.5, () ->
						{
							comingBack = true;
							MusicState.switchState(new MainMenuState(), false, true);
						});
					}
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
			titleEnter.alpha = FlxMath.lerp(1, .64, timer);
		}

		super.update(elapsed);
	}

	public override function onBeat()
	{
		gf.animation.play(curBeat % 2 == 0 ? 'danceLeft' : 'danceRight');

		logo.animation.play('bop', true);

		if (!skippedIntro)
			switch (curBeat)
			{
				case 0:
					FlxG.sound.music.fadeIn(4, 0, .7);
					createIntroText('Horizon Engine by', -50);
				case 2:
					tweenLastIntroText(1, 150);
					createIntroText('Cobalt Bar', -50);
					introTexts[1].setColorTransform(0, .5, 1, 1, 0, 0, 0, 0);
				case 3:
					Settings.data.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects(true);
				case 4:
					createIntroText('Not Associated with', 100);
				case 6:
					tweenLastIntroText(1, 150);
					createIntroText('Newgrounds', 100);
					createIntroImage(Path.image('newgrounds_logo'), 0);
				case 7:
					Settings.data.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects(true);
				case 8:
					createIntroText(goofyTexts[0], 50);
				case 10:
					tweenLastIntroText(1, 50);
					createIntroText(goofyTexts[1], -50);
				case 11:
					Settings.data.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects(true);
				case 12:
					shouldBop = false;
					targetZoom = 1.2;
					createIntroText('Friday', -100);
				case 13:
					targetZoom = 1.35;
					tweenLastIntroText(1, 100);
					createIntroText('Night', -100);
				case 14:
					targetZoom = 1.5;
					tweenLastIntroText(1, 100);
					tweenLastIntroText(2, 100);
					createIntroText('Funkin\'', -100);
				case 15:
					skipIntro();
			}

		super.onBeat();
	}

	private function skipIntro():Void
	{
		skippedIntro = gf.visible = logo.visible = titleEnter.visible = shouldBop = true;
		targetZoom = 1;
		clearIntroObjects();
		FlxG.camera.flash(0xFFFFFFFF, 1, () -> {}, true);
	}

	private function createIntroText(text:String, yOff:Float):Alphabet
	{
		var alphabet:Alphabet = new Alphabet(FlxG.width * 2 * (introTexts.length % 2 == 0 ? 1 : -1), FlxG.height * .5, text, true, CENTER, 1.4, 0, yOff);
		introTexts.push(alphabet);
		add(alphabet);
		FlxTween.tween(alphabet, {x: FlxG.width * .5}, .5, {type: ONESHOT, ease: FlxEase.expoOut,});
		return alphabet;
	}

	private function createIntroImage(path, yOff:Float):FlxSprite
	{
		var img:FlxSprite = Util.createGraphicSprite(FlxG.width * .5, FlxG.height * 2, path, 1.4);
		img.screenCenter(X);
		introImages.push(img);
		add(img);
		FlxTween.tween(img, {y: FlxG.height * .5 + yOff}, .5, {type: ONESHOT, ease: FlxEase.expoOut});
		return img;
	}

	private function tweenOutIntroObjects(destroy:Bool = false):Void
	{
		for (i in 0...introTexts.length)
			FlxTween.tween(introTexts[i], {y: -1250 * (i % 2 == 0 ? 1 : -1)}, .5,
				{type: ONESHOT, ease: FlxEase.expoIn, onComplete: tween -> if (destroy) introTexts[i].destroy()});
		for (obj in introImages)
			FlxTween.tween(obj, {y: -1250 * (obj.y > FlxG.height * .5 ? 1 : -1)}, .5,
				{type: ONESHOT, ease: FlxEase.expoIn, onComplete: tween -> if (destroy) obj.destroy()});
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

	private function tweenLastIntroText(howFarBack:Int = 1, yOff:Float):Void
	{
		FlxTween.tween(introTexts[introTexts.length - howFarBack], {y: introTexts[introTexts.length - howFarBack].y - yOff}, .5, {
			type: ONESHOT,
			ease: FlxEase.expoOut,
		});
	}

	private inline function loadTitleData():Void
	{
		titleData = Path.json('titleData');
		Conductor.bpm = titleData.bpm;
		var goofyTextList = Path.txt('introTexts').split('\n');
		var num = FlxG.random.int(0, goofyTextList.length - 1);
		goofyTexts.push(goofyTextList[num].split('--')[0]);
		goofyTexts.push(goofyTextList[num].split('--')[1]);
	}

	private function generateObjects():Void
	{
		gf = Util.createSparrowSprite(titleData.gfPosition[0], titleData.gfPosition[1], 'gfDanceTitle', 1.35);
		gf.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], '', 24, false);
		gf.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], '', 24, false);
		gf.visible = false;
		add(gf);

		logo = Util.createSparrowSprite(titleData.logoPosition[0], titleData.logoPosition[1], 'logoBumpin', 1.4);
		logo.animation.addByPrefix('bop', 'logo bumpin', 24, false);
		logo.visible = false;
		add(logo);

		titleEnter = Util.createSparrowSprite(titleData.startPosition[0], titleData.startPosition[1], 'titleEnter', 1.3);
		titleEnter.animation.addByPrefix('Pressed', 'ENTER PRESSED', 24, true);
		titleEnter.animation.addByPrefix('idle', 'ENTER IDLE', 24, true);
		titleEnter.animation.play('idle');
		titleEnter.visible = false;
		add(titleEnter);
	}
}
