package states;

import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.math.FlxRect;
import haxe.io.Path as HaxePath;

class StoryMenuState extends MusicMenuState
{
	var difficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekInfo:FlxText;
	var songsText:FlxText;
	var curDifficulty:Int = 0;

	var weekChars:FlxTypedContainer<MenuChar>;

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
			menuOptions[i].setPosition(FlxMath.lerp(menuOptions[i].x, FlxG.width * .5 - 400 - (50 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)),
				FlxMath.lerp(menuOptions[i].y, 750 - (200 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)));
			menuOptions[i].clipRect = FlxRect.weak(0, menuOptions[i].y < 825 ? -menuOptions[i].height - (menuOptions[i].y - 825) : -menuOptions[i].height,
				menuOptions[i].width + 10, menuOptions[i].height * 2);
			menuOptions[i].clipRect = menuOptions[i].clipRect;
		}

		if (!transitioningOut)
		{
			if (Controls.ui_left)
				changeDifficulty(-1);

			if (Controls.ui_right)
				changeDifficulty(1);
		}
		super.update(elapsed);
	}

	public override function onBeat()
	{
		super.onBeat();
		weekChars.forEach(char -> char.animation.play(char.animation.exists('idle') ? 'idle' : curBeat % 2 == 0 ? 'danceLeft' : 'danceRight'));
	}

	public override function changeSelection(change:Int):Void
	{
		menuOptions[curSelected].alpha = .6;
		super.changeSelection(change);
		menuOptions[curSelected].alpha = 1;
		weekInfo.text = '${Std.string(optionToData[menuOptions[curSelected]].week.score).lpad('0', 6)} - ${optionToData[menuOptions[curSelected]].week.name}';
		weekInfo.screenCenter(X);
		songsText.text = optionToData[menuOptions[curSelected]].songs.join('\n');
		if (optionToData[menuOptions[curSelected]].week.menuBG == "blank")
		{
			bg.scale.set(1, 1);
			bg.makeGraphic(FlxG.width, 400, 0xFFF9CF51);
		}
		else
		{
			bg.loadGraphic(Path.image('menu-${optionToData[menuOptions[curSelected]].week.menuBG}', optionToData[menuOptions[curSelected]].mod));
			bg.scale.set(optionToData[menuOptions[curSelected]].week.bgScale, optionToData[menuOptions[curSelected]].week.bgScale);
		}
		var names:Array<String> = [];
		weekChars.forEach(char -> optionToData[menuOptions[curSelected]].week.menuChars.contains('menu-${char.name}') ? names.push(char.name) : char.destroy());
		bg.updateHitbox();
		for (char in optionToData[menuOptions[curSelected]].week.menuChars)
			if (!names.contains('menu-$char'))
				weekChars.insert(0, new MenuChar('menu-$char', optionToData[menuOptions[curSelected]].mod));
		curDifficulty = 1;
		changeDifficulty(0);
	}

	public function changeDifficulty(change:Int):Void
	{
		if (change != 0)
			FlxG.sound.play(Path.sound('Scroll'), .7);

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = optionToData[menuOptions[curSelected]].week.difficulties.length - 1;
		if (curDifficulty >= optionToData[menuOptions[curSelected]].week.difficulties.length)
			curDifficulty = 0;

		difficulty.loadGraphic(Path.image('difficulty-${optionToData[menuOptions[curSelected]].week.difficulties[curDifficulty] ?? 'normal'}',
			optionToData[menuOptions[curSelected]].mod));
		difficulty.updateHitbox();
		difficulty.x = FlxG.width - 350 - difficulty.width * .5;
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
		bg = Util.makeSprite(0, 100, FlxG.width, 400, 0xFFF9CF51);
		bg.cameras = [menuCam];
		add(bg);

		add(weekChars = new FlxTypedContainer<MenuChar>());
		weekChars.cameras = [menuCam];

		weekInfo = Util.createText(FlxG.width * .5, 25, '000000', 64, Path.font('vcr'), 0xFFE55777, LEFT);
		weekInfo.cameras = [menuCam];
		add(weekInfo);

		var tracks = Util.createGraphicSprite(150, 750, Path.image('tracks'), 1.5);
		tracks.cameras = [menuCam];
		add(tracks);

		songsText = Util.createText(150, 830, 'Song 1\nSong 2\nSong 3', 48, Path.font('vcr'), 0xFFE55777, CENTER);
		songsText.cameras = [menuCam];
		add(songsText);

		difficulty = Util.createGraphicSprite(0, 750, Path.image('difficulty-easy'), 1.4)
			.loadGraphic(Path.image('difficulty-normal'))
			.loadGraphic(Path.image('difficulty-hard'));
		difficulty.updateHitbox();
		difficulty.x = FlxG.width - 350 - difficulty.width * .5;
		difficulty.cameras = [menuCam];
		add(difficulty);

		leftArrow = Util.createSparrowSprite(0, 0, "storyModeAssets", 1.3);
		leftArrow.animation.addByPrefix('idle', 'arrow left', 24);
		leftArrow.animation.addByPrefix('press', 'arrow push left', 24);
		leftArrow.animation.play('idle');
		leftArrow.x = difficulty.x - leftArrow.width - 20;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;
		leftArrow.cameras = [menuCam];
		add(leftArrow);

		rightArrow = Util.createSparrowSprite(0, 0, "storyModeAssets", 1.3);
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
				var option = Util.createGraphicSprite(FlxG.width * .5 - 400 + (50 * i), 750 + (200 * i), Path.image('week-${week.name}', mod), 1.4);
				option.alpha = .6;
				option.clipRect = FlxRect.weak(0, -option.height, option.width + 10, option.height * 2);
				option.clipRect = option.clipRect;
				var songs:Array<String> = [];
				for (song in week.songs)
					songs.push(mod.songs?.get(song)?.name);
				optionToData.set(option, {mod: mod, week: week, songs: songs});
				option.cameras = [optionsCam];
				add(option);
				menuOptions.push(option);
				i++;
			}
	}
}

class MenuChar extends FlxSprite
{
	public var name:String;

	public function new(jsonPath:String, mod:Mod)
	{
		var json:MenuCharJson = Path.json(jsonPath, mod);
		name = HaxePath.withoutExtension(jsonPath);
		super(json?.position[0] ?? 0, json?.position[1] ?? 0);
		scale.set(json?.scale ?? 1, json?.scale ?? 1);
		frames = Path.sparrow(HaxePath.withoutExtension(jsonPath), mod);
		animation.addByPrefix('confirm', json?.confirm, json?.fps ?? 24, false);
		if (json?.idle?.length == 1)
		{
			animation.addByPrefix('idle', json?.idle[0], json?.fps ?? 24);
			animation.play('idle');
		}
		else
		{
			animation.addByPrefix('danceLeft', json?.idle[0], json?.fps ?? 24);
			animation.addByPrefix('danceRight', json?.idle[1], json?.fps ?? 24);
			animation.play('danceLeft');
		}
		updateHitbox();
		centerOffsets(true);
	}
}
