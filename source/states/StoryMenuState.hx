package states;

import flixel.math.FlxRect;

/*
	TODO - Difficulty Switch, Difficulty movement centering + shrink a bit
 */
class StoryMenuState extends MusicMenuState
{
	var difficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekScore:FlxText;
	var weekName:FlxText;
	var songsText:FlxText;
	var curDifficulty:Int = 0;

	var optionToData:Map<FlxSprite, {mod:Mod, week:Week, songs:Array<String>}> = [];

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		DiscordRPC.change('In The Menus', 'Story Mode Menu');
		shouldBop = false;
		createMenuBG();
		createMenuOptions();
		changeSelection(0);
	}

	public override function update(elapsed:Float):Void
	{
		for (i in 0...menuOptions.length)
		{
			menuOptions[i].setPosition(FlxMath.lerp(menuOptions[i].x, (FlxG.width - menuOptions[i].width) * .5 - (50 * (curSelected - i)),
				FlxMath.bound(elapsed * 5, 0, 1)),
				FlxMath.lerp(menuOptions[i].y, 600 - (200 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)));
			menuOptions[i].clipRect = FlxRect.weak(0, menuOptions[i].y < 625 ? -menuOptions[i].height - (menuOptions[i].y - 625) : -menuOptions[i].height,
				menuOptions[i].width + 10, menuOptions[i].height * 2);
			menuOptions[i].clipRect = menuOptions[i].clipRect;
		}
		super.update(elapsed);
	}

	public override function changeSelection(change:Int):Void
	{
		menuOptions[curSelected].alpha = .6;
		super.changeSelection(change);
		menuOptions[curSelected].alpha = 1;
		weekName.text = optionToData[menuOptions[curSelected]].week.name;
		weekName.x = FlxG.width - weekName.width - 10;
		songsText.text = optionToData[menuOptions[curSelected]].songs.join('\n');
		weekScore.text = Std.string(optionToData[menuOptions[curSelected]].week.score).lpad('0', 6);
		difficulty.loadGraphic(Path.image('difficulty-${(optionToData[menuOptions[curSelected]].week.difficulties.length < 2 ? optionToData[menuOptions[curSelected]].week.difficulties[1] : optionToData[menuOptions[curSelected]].week.difficulties[0]) ?? 'normal'}',
			optionToData[menuOptions[curSelected]].mod));
		difficulty.updateHitbox();
		leftArrow.x = difficulty.x - leftArrow.width - 20;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;
		rightArrow.x = difficulty.x + difficulty.width + 20;
		rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;
	}

	public override function exitState():Void
	{
		// Transfer to PlayState
		super.exitState();
	}

	public override function returnState():Void
	{
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	inline function createMenuBG():Void
	{
		bg = Util.makeSprite(0, 120, FlxG.width, 400, 0xFFF9CF51);
		bg.cameras = [menuCam];
		add(bg);

		weekScore = Util.createText(10, 55, '000000', 64, Path.font('vcr'), 0xFFE55777, LEFT);
		weekScore.cameras = [menuCam];
		add(weekScore);

		weekName = Util.createText(0, 55, 'Week', 64, Path.font('vcr'), 0xFFAAAAAA, RIGHT);
		weekName.cameras = [menuCam];
		add(weekName);

		var tracks = Util.createGraphicSprite(150, 600, Path.image('tracks'), 1.5);
		tracks.cameras = [menuCam];
		add(tracks);

		songsText = Util.createText(150, 680, 'Song 1\nSong 2\nSong 3', 48, Path.font('vcr'), 0xFFE55777, CENTER);
		songsText.cameras = [menuCam];
		add(songsText);

		difficulty = Util.createGraphicSprite(0, 600, Path.image('difficulty-easy'), 1.4)
			.loadGraphic(Path.image('difficulty-normal'))
			.loadGraphic(Path.image('difficulty-hard'));
		difficulty.updateHitbox();
		difficulty.x = FlxG.width - 200 - difficulty.width;
		difficulty.cameras = [menuCam];
		add(difficulty);

		leftArrow = Util.createSparrowSprite(0, 0, "storyModeAssets", 1.5);
		leftArrow.animation.addByPrefix('idle', 'arrow left', 24);
		leftArrow.animation.addByPrefix('press', 'arrow push left', 24);
		leftArrow.animation.play('idle');
		leftArrow.x = difficulty.x - leftArrow.width - 20;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;
		leftArrow.cameras = [menuCam];
		add(leftArrow);

		rightArrow = Util.createSparrowSprite(0, 0, "storyModeAssets", 1.5);
		rightArrow.animation.addByPrefix('idle', 'arrow right', 24);
		rightArrow.animation.addByPrefix('press', 'arrow push right', 24);
		rightArrow.animation.play('idle');
		rightArrow.x = difficulty.x + difficulty.width + 20;
		rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;
		rightArrow.cameras = [menuCam];
		add(rightArrow);
	}

	inline function createMenuOptions():Void
	{
		var i:Int = 0;

		for (mod in Mods.enabled)
			for (week in mod.weeks)
			{
				var option = Util.createGraphicSprite(0, 600 + (200 * i), Path.image('week-${week.name}', mod), 1.4);
				option.x = (FlxG.width - option.width) * .5 + (50 * i);
				option.alpha = .6;
				option.clipRect = FlxRect.weak(0, -option.height, option.width + 10, option.height * 2);
				option.clipRect = option.clipRect;
				var songs:Array<String> = [];
				for (song in week.songs)
					songs.push(mod.songs.get(song).name);
				optionToData.set(option, {mod: mod, week: week, songs: songs});
				option.cameras = [optionsCam];
				add(option);
				menuOptions.push(option);
				i++;
			}
	}
}
