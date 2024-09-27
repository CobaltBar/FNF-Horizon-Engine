package horizon.states;

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

		titleData = Path.json('titleData');
		Conductor.bpm = titleData.bpm;
		var goofyTextList = Path.txt('introTexts').split('\n');
		var num = FlxG.random.int(0, goofyTextList.length - 1);
		goofyTexts.push(goofyTextList[num].split('--')[0]);
		goofyTexts.push(goofyTextList[num].split('--')[1]);

		add(gf = Create.atlas(titleData.gfPosition[0], titleData.gfPosition[1], Path.sparrow('gfDanceTitle'), .9));
		gf.animation.addByPrefix('left', 'left', 24);
		gf.animation.addByPrefix('right', 'right', 24);
		gf.visible = false;

		add(logo = Create.atlas(titleData.logoPosition[0], titleData.logoPosition[1], Path.sparrow('logoBumpin')));
		logo.animation.addByPrefix('bop', 'logo bumpin', 24, false);
		logo.visible = false;

		add(titleEnter = Create.atlas(titleData.startPosition[0], titleData.startPosition[1], Path.sparrow('titleEnter')));
		titleEnter.animation.addByPrefix('Pressed', 'ENTER PRESSED', 24, true);
		titleEnter.animation.addByPrefix('idle', 'ENTER IDLE', 24, true);
		titleEnter.animation.play('idle');
		titleEnter.visible = false;

		FlxTween.num(0, 1, 2, {type: PINGPONG, ease: FlxEase.quadInOut}, num -> titleEnterTimer = num);

		if (comingBack)
			skipIntro();
		else if (FlxG.sound.music == null)
			FlxG.sound.playMusic(Path.audio('gettinFreaky'), 0);

		Controls.onPress(Settings.keybinds['accept'], () ->
		{
			if (!skippedIntro)
				skipIntro();
			else if (!transitioningOut)
			{
				transitioningOut = true;
				titleEnter.color = 0xFFFFFFFF;
				titleEnter.alpha = 1;
				titleEnter.animation.play('Pressed');
				FlxG.sound.play(Path.audio('confirm'), .7);
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
					onComplete: tween -> Settings.reducedMotion ? FlxTween.tween(logo, {alpha: 0}, .5,
						{type: ONESHOT, ease: FlxEase.expoIn}) : FlxTween.tween(logo, {y: -FlxG.height * 1.5}, .5, {type: ONESHOT, ease: FlxEase.expoIn})
				});
				FlxTween.tween(logo.scale, {x: 1.6, y: 1.6}, .75, {
					type: ONESHOT,
					ease: FlxEase.expoOut,
					onComplete: tween -> FlxTimer.wait(.5, () ->
					{
						comingBack = true;
						MusicState.switchState(new MainMenuState());
					})
				});
			}
		});
		Path.clearUnusedMemory();
	}

	public override function update(elapsed:Float):Void
	{
		if (titleEnter.visible && !transitioningOut)
		{
			titleEnter.color = FlxColor.interpolate(0xFF33FFFF, 0xFF3333CC, titleEnterTimer);
			titleEnter.alpha = FlxMath.lerp(1, .64, titleEnterTimer);
		}

		super.update(elapsed);
	}

	public override function onBeat():Void
	{
		gf.animation.play(curBeat % 2 == 0 ? 'left' : 'right');
		logo.animation.play('bop', true);

		if (!skippedIntro)
			switch (curBeat)
			{
				case 1:
					FlxG.sound.music.fadeIn(4, 0, .7);
					createIntroText('Horizon Engine by');
				case 3:
					tweenLastIntroText(1, -50);
					createIntroText('Cobalt Bar', 50);
					introTexts[1].setColorTransform(0, .5, 1, 1, 0, 0, 0, 0);
				case 4:
					Settings.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects();
				case 5:
					createIntroText('Not Associated with');
				case 7:
					tweenLastIntroText(1, -180);
					createIntroText('Newgrounds', -85);
					createIntroImage(Path.image('newgrounds_logo'), 25);
				case 8:
					Settings.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects();
				case 9:
					createIntroText(goofyTexts[0], 0);
				case 11:
					tweenLastIntroText(1, -50);
					createIntroText(goofyTexts[1], 50);
				case 12:
					Settings.reducedMotion ? clearIntroObjects() : tweenOutIntroObjects();
				case 13:
					bop = false;
					targetZoom = 1.2;
					createIntroText('Friday', 75);
				case 14:
					targetZoom = 1.35;
					tweenLastIntroText(1, -75);
					createIntroText('Night', 75);
				case 15:
					targetZoom = 1.5;
					tweenLastIntroText(1, -75);
					tweenLastIntroText(2, -75);
					createIntroText('Funkin\'', 75);
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

	function createIntroText(text:String, yOff:Float = 0):Alphabet
	{
		var alphabet = new Alphabet(FlxG.width * 2 * (introTexts.length % 2 == 0 ? 1 : -1), 0, text, true, CENTER);
		alphabet.screenCenter(Y);
		alphabet.y += yOff;
		introTexts.push(alphabet);
		add(alphabet);
		FlxTween.tween(alphabet, {x: (FlxG.width - alphabet.width) * .5}, .5, {type: ONESHOT, ease: FlxEase.expoOut});
		return alphabet;
	}

	function createIntroImage(path:flixel.system.FlxAssets.FlxGraphicAsset, yOff:Float):FlxSprite
	{
		var img:FlxSprite = Create.sprite(0, FlxG.height * 2, path, null, .8);
		img.screenCenter(X);
		introImages.push(img);
		add(img);
		FlxTween.tween(img, {y: FlxG.height * .5 + yOff}, .5, {type: ONESHOT, ease: FlxEase.expoOut});
		return img;
	}

	function tweenOutIntroObjects():Void
	{
		for (i in 0...introTexts.length)
			FlxTween.tween(introTexts[i], {y: -FlxG.height * 1.5 * (i % 2 == 0 ? 1 : -1)}, .5,
				{type: ONESHOT, ease: FlxEase.expoIn, onComplete: tween -> introTexts[i].destroy()});
		for (obj in introImages)
			FlxTween.tween(obj, {y: FlxG.height * 1.5 * (obj.y > FlxG.height * .5 ? 1 : -1)}, .5,
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
		FlxTween.tween(introTexts[introTexts.length - howFarBack], {y: introTexts[introTexts.length - howFarBack].y + yOff}, .5,
			{type: ONESHOT, ease: FlxEase.expoOut});
}

typedef TitleJSON =
{
	bpm:Float,
	gfPosition:Array<Int>,
	logoPosition:Array<Int>,
	startPosition:Array<Int>
}
