package backend;

import flixel.util.FlxSort;
import openfl.events.KeyboardEvent;

class PlayerInput
{
	static var keyTracker:Map<Int, Bool> = [];
	static var safeFrames:Float = 0;
	static var keyToData:Map<Int, Int> = [];

	static var curScore:Int = 0;

	static var inputEnabled:Bool = false;

	public static function init():Void
	{
		for (i in 0...Settings.data.keybinds['notes'].length)
		{
			keyToData.set(Settings.data.keybinds['notes'][i], i % 4);
			keyTracker.set(Settings.data.keybinds['notes'][i], false);
		}
		safeFrames = (Settings.data.safeFrames / 60) * 250;
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, onPress);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, onRelease);
		Countdown.countdownEnded.add(() -> inputEnabled = true);
	}

	@:noCompletion public static function onPress(event:KeyboardEvent):Void
	{
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
			if (!keyTracker[event.keyCode])
			{
				keyTracker.set(event.keyCode, true);
				var strum = PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]];
				if (inputEnabled)
				{
					for (note in PlayState.instance.playerStrum.notes.members)
					{
						if (!note.alive || note.data != keyToData[event.keyCode])
							continue;
						if (Math.abs(Conductor.time - note.time) <= Settings.data.hitWindows[3] + safeFrames)
						{
							PlayState.instance.playerStrum.addNextNote();
							strum.confirm(false);
							if (PlayState.instance.audios.exists('voices'))
								PlayState.instance.audios['voices'].volume = 1;
							else if (PlayState.instance.audios.exists('voices-player'))
								PlayState.instance.audios['voices-player'].volume = 1;
							PlayState.instance.combo += 1;
							judge(Math.abs(Conductor.time - note.time));
							note.kill();
							return;
						}
					}
				}
				strum.press(false);
				if (!Settings.data.ghostTapping)
					PlayState.instance.miss();
			}
	}

	@:noCompletion public static function onRelease(event:KeyboardEvent):Void
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
		{
			keyTracker.set(event.keyCode, false);
			PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].unPress();
			PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].unConfirm();
		}

	static function judge(time:Float):Void
	{
		var name:String;
		if (time <= Settings.data.hitWindows[0] + safeFrames)
		{
			name = 'sick';
			PlayState.instance.score += 350;
		}
		else if (time <= Settings.data.hitWindows[1] + safeFrames)
		{
			name = 'good';
			PlayState.instance.score += 200;
		}
		else if (time <= Settings.data.hitWindows[2] + safeFrames)
		{
			name = 'bad';
			PlayState.instance.score += 100;
		}
		else
		{
			name = 'shit';
			PlayState.instance.score += 50;
		}

		var rating = PlayState.instance.comboGroup['rating'].recycle(FlxSprite, () ->
		{
			var spr = Create.sprite(0, 0, Path.image(name));
			spr.cameras = [PlayState.instance.camHUD];
			return spr;
		});
		rating.alpha = 1;
		rating.loadGraphic(Path.image(name));
		rating.updateHitbox();
		rating.screenCenter();
		rating.acceleration.y = 550;
		rating.velocity.y = -FlxG.random.int(140, 175);
		rating.velocity.x = -FlxG.random.int(0, 10);
		FlxTween.tween(rating, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> rating.kill(), startDelay: Conductor.beatLength * .001});
		rating.ID = curScore;
		PlayState.instance.comboGroup['rating'].sort((Order:Int, Obj1:FlxSprite, Obj2:FlxSprite) -> FlxSort.byValues(Order, Obj1.ID, Obj2.ID));

		var count:Int = 0;
		var arr = Std.string(PlayState.instance.combo).lpad('0', 3).split('');
		arr.reverse();
		for (num in arr)
		{
			var comboNum = PlayState.instance.comboGroup['combo'].recycle(FlxSprite, () ->
			{
				var spr = Create.sprite(0, 0, Path.image('num$num'));
				spr.cameras = [PlayState.instance.camHUD];
				return spr;
			});
			comboNum.alpha = 1;
			comboNum.loadGraphic(Path.image('num$num'));
			comboNum.scale.set(.8, .8);
			comboNum.updateHitbox();
			comboNum.screenCenter();
			comboNum.offset.x = (comboNum.width + 5) * count + 50;
			comboNum.offset.y = -(comboNum.height + 25);
			comboNum.acceleration.y = FlxG.random.int(200, 300);
			comboNum.velocity.y = -FlxG.random.int(140, 160);
			comboNum.velocity.x = FlxG.random.float(-5, 5);
			FlxTween.tween(comboNum, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> comboNum.kill(), startDelay: Conductor.beatLength * .001});
			count++;

			comboNum.ID = curScore;
			PlayState.instance.comboGroup['combo'].sort((Order:Int, Obj1:FlxSprite, Obj2:FlxSprite) -> FlxSort.byValues(Order, Obj1.ID, Obj2.ID));
		}

		if (PlayState.instance.combo >= 10)
		{
			var comboSpr = PlayState.instance.comboGroup['comboSpr'].recycle(FlxSprite, () ->
			{
				var spr = Create.sprite(0, 0, Path.image('combo'));
				spr.cameras = [PlayState.instance.camHUD];
				return spr;
			});
			comboSpr.alpha = 1;
			comboSpr.updateHitbox();
			comboSpr.screenCenter();
			comboSpr.offset.x = -comboSpr.width * .5;
			comboSpr.offset.y = -(comboSpr.height + 25);
			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			comboSpr.velocity.y = -FlxG.random.int(140, 160);
			comboSpr.velocity.x = FlxG.random.int(1, 10);
			FlxTween.tween(comboSpr, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> comboSpr.kill(), startDelay: Conductor.beatLength * .001});

			comboSpr.ID = curScore;
			PlayState.instance.comboGroup['comboSpr'].sort((Order:Int, Obj1:FlxSprite, Obj2:FlxSprite) -> FlxSort.byValues(Order, Obj1.ID, Obj2.ID));
		}

		curScore++;
	}
}
