package horizon.states;

import flixel.effects.FlxFlicker;
import flixel.math.FlxRect;

class StoryMenuState extends MusicMenuState
{
	var difficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekInfo:FlxText;
	var songsText:FlxText;
	var curDifficulty:Int = 0;
	var tracks:FlxSprite;

	var menuChars:Map<Mod, Map<String, MenuCharacter>> = [];
	var optionToData:Array<StoryMenuData> = [];

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		bop = false;
		persistentUpdate = true;

		// TODO make an actual preloading system based on a macro
		for (diff in ['easy', 'normal', 'hard', 'erect', 'nightmare'])
			Path.image('difficulty-$diff');

		// I don't like this but it works
		for (mod in [Mods.assets].concat(Mods.enabled))
		{
			menuChars.set(mod, []);
			for (week in mod.weeks)
			{
				if (week.bg != 'blank')
					Path.image('menu-${week.bg}', [mod]);
				for (char in week.menuChars)
					if (!menuChars[mod].exists(char))
					{
						var character = new MenuCharacter('char-$char', [mod]);
						character.cameras = [optionsCam];
						character.screenCenter();
						character.x += character.posX;
						character.y += character.posY;
						character.visible = false;
						add(character);
						menuChars[mod].set(char, character);
					}
			}
		}

		add(bg = Create.graphic(0, 60, FlxG.width, 386, 0xFFF9CF51, [menuCam]));

		add(weekInfo = Create.text(FlxG.width * .5, 15, '000000', 32, Path.font('vcr'), 0xFFE55777, CENTER, [menuCam]));
		weekInfo.screenCenter(X);

		add(tracks = Create.sprite(0, bg.y + bg.height + 25, Path.image('tracks'), [menuCam]));
		tracks.screenCenter(X);
		tracks.x -= FlxG.width * .35;

		add(songsText = Create.text(0, bg.y + bg.height + 75, 'Song 1\nSong 2\nSong 3', 32, Path.font('vcr'), 0xFFE55777, CENTER, [menuCam]));
		songsText.screenCenter(X);
		songsText.x -= FlxG.width * .35;

		add(difficulty = Create.sprite(0, bg.y + bg.height + 25, Path.image('difficulty-normal'), [menuCam]));
		difficulty.screenCenter(X);
		difficulty.x += FlxG.width * .3;

		add(leftArrow = Create.atlas(0, 0, Path.atlas('arrows'), [menuCam]));
		leftArrow.animation.addByPrefix('idle', 'leftIdle', 24);
		leftArrow.animation.addByPrefix('press', 'leftConfirm', 24);
		leftArrow.animation.play('idle');
		leftArrow.x = difficulty.x - leftArrow.width - 15;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;

		add(rightArrow = Create.atlas(0, 0, Path.atlas('arrows'), [menuCam]));
		rightArrow.animation.addByPrefix('idle', 'rightIdle', 24);
		rightArrow.animation.addByPrefix('press', 'rightConfirm', 24);
		rightArrow.animation.play('idle');
		rightArrow.x = difficulty.x + difficulty.width + 10;
		rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;

		var mods = Mods.enabled;

		if (Mods.enabled.length == 0)
			mods.unshift(Mods.assets);

		for (mod in mods)
		{
			var songNames = [for (song in mod.songs) song.folder.toLowerCase() => song.name];

			for (i => week in mod.weeks)
			{
				var option = Create.sprite(0, FlxG.height - 250 - (100 * i), Path.image('week-${week.name.toLowerCase().replace(' ', '')}'), [optionsCam]);
				option.clipRect = new FlxRect(0, 0, option.frameWidth, option.frameHeight);
				option.screenCenter(X);
				option.x -= 75;
				option.alpha = .6;
				optionToData.push({mod: mod, week: week, songs: [for (song in week.songs) songNames[song]]});
				add(option);
				menuOptions.push(option);
			}
		}

		Controls.onPress(Settings.keybinds.get('ui_left'), () -> if (!transitioningOut)
		{
			leftArrow.animation.play('press');
			changeDifficulty(-1);
		});

		Controls.onPress(Settings.keybinds.get('ui_right'), () -> if (!transitioningOut)
		{
			rightArrow.animation.play('press');
			changeDifficulty(1);
		});

		Controls.onRelease(Settings.keybinds.get('ui_left'), () -> if (!transitioningOut)
		{
			leftArrow.animation.play('idle');
			leftArrow.x = difficulty.x - leftArrow.width - 15;
			leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;
		});

		Controls.onRelease(Settings.keybinds.get('ui_right'), () -> if (!transitioningOut)
		{
			rightArrow.animation.play('idle');
			rightArrow.x = difficulty.x + difficulty.width + 10;
			rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;
		});

		changeSelection(0);
		Path.clearUnusedMemory();
	}

	public override function update(elapsed:Float):Void
	{
		if (!transitioningOut)
			for (i => option in menuOptions)
			{
				option.y = FlxMath.lerp(option.y, FlxG.height - 250 - (100 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1));
				option.clipRect.y = option.y < FlxG.height - 274 ? (FlxG.height - 274) - option.y : 0;
				option.clipRect = option.clipRect;
			}

		super.update(elapsed);
	}

	public override function changeSelection(change:Int)
	{
		for (char in menuChars[optionToData[curSelected].mod])
			char.visible = false;

		menuOptions[curSelected].alpha = .6;
		super.changeSelection(change);
		menuOptions[curSelected].alpha = 1;

		weekInfo.text = '${optionToData[curSelected].week.name} - ${Std.string(optionToData[curSelected].week.score).lpad('0', 6)}';
		weekInfo.screenCenter(X);

		songsText.text = optionToData[curSelected].songs.join('\n');
		songsText.screenCenter(X);
		songsText.x -= FlxG.width * .35;

		if (optionToData[curSelected].week.bg == null || optionToData[curSelected].week.bg == 'blank')
		{
			bg.makeGraphic(FlxG.width, 386, 0xFFF9CF51);
			bg.scale.set(1, 1);
		}
		else
		{
			bg.loadGraphic(Path.image('menu-${optionToData[curSelected].week.bg}', [optionToData[curSelected].mod]));
			bg.scale.set(optionToData[curSelected].week.bgScale, optionToData[curSelected].week.bgScale);
		}
		bg.updateHitbox();

		for (char in menuChars[optionToData[curSelected].mod])
			char.visible = true;

		curDifficulty = Math.floor(optionToData[curSelected].week.difficulties.length * .5);
		changeDifficulty(0);
	}

	public function changeDifficulty(change:Int):Void
	{
		curDifficulty = (curDifficulty + change + optionToData[curSelected].week.difficulties.length) % optionToData[curSelected].week.difficulties.length;

		difficulty.loadGraphic(Path.image('difficulty-${optionToData[curSelected].week.difficulties[curDifficulty].toLowerCase() ?? 'normal'}',
			[optionToData[curSelected].mod]));

		difficulty.updateHitbox();
		difficulty.screenCenter(X);
		difficulty.x += FlxG.width * .3;

		leftArrow.x = difficulty.x - leftArrow.width - 15;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;
		rightArrow.x = difficulty.x + difficulty.width + 10;
		rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;
	}

	public override function onBeat()
	{
		super.onBeat();
		for (mod in menuChars.keys())
			for (char in menuChars[mod])
				char.bop();
	}

	public override function exitState():Void
	{
		var mods = Mods.enabled.filter(f -> f != optionToData[curSelected].mod && f.global);
		mods.unshift(optionToData[curSelected].mod);

		var folderToSong = [
			for (song in optionToData[curSelected].mod.songs)
				song.folder.toLowerCase() => song
		];

		PlayState.mods = mods;
		PlayState.songs = [for (song in optionToData[curSelected].week.songs) folderToSong[song]];
		PlayState.difficulty = optionToData[curSelected].week.difficulties[curDifficulty].toLowerCase();
		PlayState.week = optionToData[curSelected].week;

		FlxG.sound.music.fadeOut(1, 0, tween ->
		{
			FlxG.sound.music.pause();
			MusicState.switchState(new PlayState());
		});

		if (!Settings.reducedMotion)
		{
			menuOptions[curSelected].clipRect = null;
			if (Settings.flashingLights)
				FlxFlicker.flicker(menuOptions[curSelected], 1.3, 0.06, false, false);
			FlxTween.tween(menuOptions[curSelected].scale, {x: 1.1, y: 1.1}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
			for (i => option in menuOptions)
				if (i != curSelected)
					FlxTween.tween(option, {alpha: 0}, .5);

			for (spr in [difficulty, leftArrow, rightArrow, weekInfo, songsText, tracks, bg])
				FlxTween.tween(spr, {alpha: .25}, .5);
			for (char in menuChars[optionToData[curSelected].mod])
				if (!char.animation.exists('confirm'))
					FlxTween.tween(char, {alpha: .45}, .5);
		}

		for (char in menuChars[optionToData[curSelected].mod])
			if (char.animation.exists('confirm'))
				char.playAnim('confirm', true);

		super.exitState();
	}

	public override function returnState():Void
	{
		MusicState.switchState(new MainMenuState());
		super.returnState();
	}
}

@:structInit @:publicFields
private class StoryMenuData
{
	var mod:Mod;
	var week:Week;
	var songs:Array<String>;
}
