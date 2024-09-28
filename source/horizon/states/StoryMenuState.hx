package horizon.states;

class StoryMenuState extends MusicMenuState
{
	var difficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekInfo:FlxText;
	var songsText:FlxText;
	var curDifficulty:Int = 0;
	var tracks:FlxSprite;

	var menuChars:Map<String, MenuCharacter> = [];
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

		for (mod in [Mods.assets].concat(Mods.enabled))
			for (week in mod.weeks)
			{
				if (week.bg != 'blank')
					Path.image('menu-${week.bg}', [mod]);
				for (char in week.menuChars)
					Path.sparrow('char-$char', [mod]);
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

		add(leftArrow = Create.atlas(0, 0, Path.sparrow('arrows'), [menuCam]));
		leftArrow.animation.addByPrefix('idle', 'leftIdle', 24);
		leftArrow.animation.addByPrefix('press', 'leftConfirm', 24);
		leftArrow.animation.play('idle');
		leftArrow.x = difficulty.x - leftArrow.width - 10;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;

		add(rightArrow = Create.atlas(0, 0, Path.sparrow('arrows'), [menuCam]));
		rightArrow.animation.addByPrefix('idle', 'rightIdle', 24);
		rightArrow.animation.addByPrefix('press', 'rightConfirm', 24);
		rightArrow.animation.play('idle');
		rightArrow.x = difficulty.x + difficulty.width + 5;
		rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;

		for (mod in [Mods.assets].concat(Mods.enabled))
		{
			var songNames = [for (song in mod.songs) song.folder.toLowerCase() => song.name];

			for (week in mod.weeks)
			{
				var option = Create.sprite(0, FlxG.height - 100, Path.image('week-${week.name.toLowerCase().replace(' ', '')}'), [optionsCam]);
				option.alpha = .6;
				option.screenCenter(X);
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
			leftArrow.x = difficulty.x - leftArrow.width - 10;
			leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;
		});
		Controls.onRelease(Settings.keybinds.get('ui_right'), () -> if (!transitioningOut)
		{
			rightArrow.animation.play('idle');
			rightArrow.x = difficulty.x + difficulty.width + 5;
			rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;
		});

		changeSelection(0);
		Path.clearUnusedMemory();
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}

	public override function changeSelection(change:Int)
	{
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

		for (key => value in menuChars)
			if (!key.startsWith(optionToData[curSelected].mod.folder))
				value.visible = false;

		for (char in optionToData[curSelected].week.menuChars)
		{
			var key = '${optionToData[curSelected].mod.folder}-$char';
			if (!menuChars.exists(key))
			{
				var character = new MenuCharacter('char-$char', [optionToData[curSelected].mod]);
				character.cameras = [optionsCam];
				character.screenCenter();
				character.x += character.positions[0];
				character.y += character.positions[1];
				add(character);
				menuChars.set(key, character);
			}
			else
				menuChars[key].visible = true;
		}

		curDifficulty = Math.floor(optionToData[curSelected].week.difficulties.length * .5);
		changeDifficulty(0);
	}

	public function changeDifficulty(change:Int):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = optionToData[curSelected].week.difficulties.length - 1;
		if (curDifficulty >= optionToData[curSelected].week.difficulties.length)
			curDifficulty = 0;

		difficulty.loadGraphic(Path.image('difficulty-${optionToData[curSelected].week.difficulties[curDifficulty].toLowerCase() ?? 'normal'}',
			[optionToData[curSelected].mod]));

		difficulty.updateHitbox();
		difficulty.screenCenter(X);
		difficulty.x += FlxG.width * .3;

		leftArrow.x = difficulty.x - leftArrow.width - 10;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;
		rightArrow.x = difficulty.x + difficulty.width + 5;
		rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;
	}

	public override function onBeat()
	{
		super.onBeat();
		for (char in menuChars)
			char.bop();
	}

	public override function returnState():Void
	{
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}
}

@:structInit @:publicFields
private class StoryMenuData
{
	var mod:Mod;
	var week:Week;
	var songs:Array<String>;
}
