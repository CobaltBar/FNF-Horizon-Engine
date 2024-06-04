package states;

import flixel.effects.FlxFlicker;
import flixel.group.FlxContainer.FlxTypedContainer;
import flixel.math.FlxRect;
import haxe.io.Path as HaxePath;

// tbh this could be a lot better, but idrc anymore lmfao
class StoryMenuState extends MusicMenuState
{
	var difficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	var weekInfo:FlxText;
	var songsText:FlxText;
	var curDifficulty:Int = 0;
	var tracks:FlxSprite;

	var menuChars:Array<MenuChar> = [];
	var menuCharNames:Array<String> = [];
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
		if (!transitioningOut)
		{
			if (Controls.ui_left)
				changeDifficulty(-1);

			if (Controls.ui_right)
				changeDifficulty(1);

			for (i in 0...menuOptions.length)
			{
				menuOptions[i].setPosition(FlxMath.lerp(menuOptions[i].x, FlxG.width * .5 - 400 - (50 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)),
					FlxMath.lerp(menuOptions[i].y, 750 - (200 * (curSelected - i)), FlxMath.bound(elapsed * 5, 0, 1)));
				menuOptions[i].clipRect = FlxRect.weak(0, menuOptions[i].y < 825 ? -menuOptions[i].height - (menuOptions[i].y - 825) : -menuOptions[i].height,
					menuOptions[i].width + 10, menuOptions[i].height * 2);
				menuOptions[i].clipRect = menuOptions[i].clipRect;
			}
		}
		super.update(elapsed);
	}

	public override function onBeat()
	{
		super.onBeat();
		if (!transitioningOut)
			for (char in menuChars)
				if (char.json?.repeatEvery != null)
				{
					if (curBeat % char.json?.repeatEvery == 0)
						char.animation.play(char.animation.exists('idle') ? 'idle' : curBeat % 2 == 0 ? 'danceLeft' : 'danceRight', true);
				}
				else
					char.animation.play(char.animation.exists('idle') ? 'idle' : curBeat % 2 == 0 ? 'danceLeft' : 'danceRight', true);
	}

	public override function changeSelection(change:Int):Void
	{
		menuOptions[curSelected].alpha = .6;
		super.changeSelection(change);
		menuOptions[curSelected].alpha = 1;
		weekInfo.text = '${Std.string(optionToData[menuOptions[curSelected]].week.score).lpad('0', 6)} - ${optionToData[menuOptions[curSelected]].week.name}';
		weekInfo.screenCenter(X);
		songsText.text = optionToData[menuOptions[curSelected]].songs.join('\n');

		songsText.screenCenter(X);
		songsText.x -= FlxG.width * .35;
		if (optionToData[menuOptions[curSelected]].week.menuBG == null || optionToData[menuOptions[curSelected]].week.menuBG == "blank")
		{
			bg.scale.set(1, 1);
			bg.makeGraphic(FlxG.width, 400, 0xFFF9CF51);
		}
		else
		{
			bg.loadGraphic(Path.image('menu-${optionToData[menuOptions[curSelected]].week.menuBG}', [optionToData[menuOptions[curSelected]].mod]));
			bg.scale.set(optionToData[menuOptions[curSelected]].week.bgScale, optionToData[menuOptions[curSelected]].week.bgScale);
		}
		bg.updateHitbox();

		for (i in 0...menuCharNames.length)
			if (!optionToData[menuOptions[curSelected]].week.menuChars.contains(menuCharNames[i]))
			{
				menuChars[i].destroy();
				menuChars.remove(menuChars[i]);
				menuCharNames.remove(menuCharNames[i]);
			}

		for (char in optionToData[menuOptions[curSelected]].week.menuChars)
			if (!menuCharNames.contains(char))
			{
				var option = new MenuChar('menu-$char', optionToData[menuOptions[curSelected]].mod);
				option.cameras = [menuCam];
				add(option);
				menuChars.push(option);
				menuCharNames.push(char);
			}
		curDifficulty = 1;
		changeDifficulty(0);
	}

	public function changeDifficulty(change:Int):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = optionToData[menuOptions[curSelected]].week.difficulties.length - 1;
		if (curDifficulty >= optionToData[menuOptions[curSelected]].week.difficulties.length)
			curDifficulty = 0;

		difficulty.loadGraphic(Path.image('difficulty-${optionToData[menuOptions[curSelected]].week.difficulties[curDifficulty].toLowerCase() ?? 'normal'}',
			[optionToData[menuOptions[curSelected]].mod]));
		difficulty.updateHitbox();
		difficulty.x = FlxG.width - 350 - difficulty.width * .5;
		leftArrow.x = difficulty.x - leftArrow.width - 20;
		leftArrow.y = difficulty.y + (difficulty.height - leftArrow.height) * .5;
		rightArrow.x = difficulty.x + difficulty.width + 20;
		rightArrow.y = difficulty.y + (difficulty.height - rightArrow.height) * .5;
	}

	public override function exitState():Void
	{
		var mods = [optionToData[menuOptions[curSelected]].mod];
		for (mod in Mods.enabled)
			if (mod.global)
				mods.push(mod);
		var songs = [];
		for (song in optionToData[menuOptions[curSelected]].songs)
			songs.push(optionToData[menuOptions[curSelected]].mod.songs.get(song.toLowerCase()));
		PlayState.config = {mods: mods, songs: songs, difficulty: optionToData[menuOptions[curSelected]].week.difficulties[curDifficulty]};
		FlxTimer.wait(1, () -> MusicState.switchState(new PlayState()));
		if (!Settings.data.reducedMotion)
		{
			menuOptions[curSelected].clipRect = null;
			menuOptions[curSelected].clipRect = menuOptions[curSelected].clipRect;
			if (Settings.data.flashingLights)
				FlxFlicker.flicker(menuOptions[curSelected], 1.3, 0.06, false, false);
			menuOptions[curSelected].updateHitbox();
			FlxTween.tween(menuOptions[curSelected], {x: (FlxG.width - menuOptions[curSelected].width) * .5, y: FlxG.height - 350}, 1,
				{type: ONESHOT, ease: FlxEase.expoOut});
			FlxTween.tween(menuOptions[curSelected].scale, {x: 1.5, y: 1.5}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
			for (i in 0...menuOptions.length)
				if (i != curSelected)
					FlxTween.tween(menuOptions[i], {alpha: 0}, .5);

			for (spr in [difficulty, leftArrow, rightArrow, weekInfo, songsText, tracks, bg])
				FlxTween.tween(spr, {alpha: .25}, .5);
			for (char in menuChars)
				if (!char.animation.exists('confirm'))
					FlxTween.tween(char, {alpha: .25}, .5);
		}
		for (char in menuChars)
			if (char.animation.exists('confirm'))
				char.animation.play('confirm', true);

		FlxG.sound.music.fadeOut(.75, 0, tween -> FlxG.sound.music.pause());

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

		weekInfo = Util.createText(FlxG.width * .5, 25, '000000', 64, Path.font('vcr'), 0xFFE55777, LEFT);
		weekInfo.cameras = [menuCam];
		add(weekInfo);

		tracks = Util.createGraphicSprite(0, 750, Path.image('tracks'), 1.5);
		tracks.screenCenter(X);
		tracks.x -= FlxG.width * .35;
		tracks.cameras = [menuCam];
		add(tracks);

		songsText = Util.createText(0, 830, 'Song 1\nSong 2\nSong 3', 48, Path.font('vcr'), 0xFFE55777, CENTER);
		songsText.screenCenter(X);
		songsText.x -= FlxG.width * .35;
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
				var option = Util.createGraphicSprite(FlxG.width * .5 - 400 - (50 * i), 750 - (200 * i),
					Path.image('week-${week.name.toLowerCase().replace(' ', '')}', [mod]), 1.4);
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
	public var json:MenuCharJson;

	public function new(jsonPath:String, mod:Mod)
	{
		json = Path.json(jsonPath, [mod]);
		super(json?.position[0] ?? 0, json?.position[1] ?? 0);
		scale.set(json?.scale ?? 1, json?.scale ?? 1);
		frames = Path.sparrow(HaxePath.withoutExtension(jsonPath), [mod]);
		if (json?.confirm != null)
			if (json?.confirmIndices != null)
				animation.addByIndices('confirm', json?.confirm, json?.confirmIndices, '', json?.fps ?? 24, false);
			else
				animation.addByPrefix('confirm', json?.confirm, json?.fps ?? 24, false);
		if (json?.idle?.length == 1)
		{
			if (json?.idleIndices != null)
				animation.addByIndices('idle', json?.idle[0], json?.idleIndices[0], '', json?.fps ?? 24, false);
			else
				animation.addByPrefix('idle', json?.idle[0], json?.fps ?? 24, false);
			animation.play('idle');
		}
		else
		{
			if (json?.idleIndices != null)
			{
				animation.addByIndices('danceLeft', json?.idle[0], json?.idleIndices[0], '', json?.fps ?? 24, false);
				animation.addByIndices('danceRight', json?.idle[1], json?.idleIndices[1], '', json?.fps ?? 24, false);
			}
			else
			{
				animation.addByPrefix('danceLeft', json?.idle[0], json?.fps ?? 24, false);
				animation.addByPrefix('danceRight', json?.idle[1], json?.fps ?? 24, false);
			}
			animation.play('danceLeft');
		}
		updateHitbox();
		centerOffsets(true);
	}
}
