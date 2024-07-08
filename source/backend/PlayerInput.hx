package backend;

import openfl.events.KeyboardEvent;

class PlayerInput
{
	static var keyTracker:Map<Int, Bool> = [];
	static var safeFrames:Float = 0;
	static var keyToData:Map<Int, Int> = [];

	static var inputEnabled:Bool = false;

	public static function init():Void
	{
		for (i in 0...Settings.data.keybinds['notes'].length)
		{
			keyToData.set(Settings.data.keybinds['notes'][i], i % 4);
			keyTracker.set(Settings.data.keybinds['notes'][i], false);
		}
		safeFrames = (10 / FlxG.drawFramerate) * 1000;
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
				if (inputEnabled)
					for (note in PlayState.instance.playerStrum.notes[keyToData[event.keyCode]].members)
					{
						if (!note.alive)
							continue;
						if (Math.abs(Conductor.time - note.time) <= (120 + safeFrames))
						{
							note.hit();
							if (PlayState.instance.audios.exists('Voices'))
								PlayState.instance.audios['Voices'].volume = 1;
							else if (PlayState.instance.audios.exists('Voices-Player'))
								PlayState.instance.audios['Voices-Player'].volume = 1;
							PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].confirm(false);
							PlayState.instance.combo += 1;
							PlayState.instance.playerStrum.addNextNote();
							judge(Math.abs(Conductor.time - note.time));
							return;
						}
					}
				PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].press(false);
				if (!Settings.data.ghostTapping)
					PlayState.instance.miss();
			}
	}

	@:noCompletion public static function onRelease(event:KeyboardEvent):Void
	{
		if (Settings.data.keybinds['notes'].contains(event.keyCode))
		{
			keyTracker.set(event.keyCode, false);
			PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].unPress();
			PlayState.instance.playerStrum.strums.members[keyToData[event.keyCode]].unConfirm();
		}
	}

	// Todo shrink the ratings and combos
	static inline function judge(time:Float):Void
	{
		var name:String;
		if (time <= (35 + safeFrames))
		{
			PlayState.instance.score += 350;
			name = 'sick';
		}
		else if (time <= (70 + safeFrames))
		{
			PlayState.instance.score += 200;
			name = 'good';
		}
		else if (time <= (90 + safeFrames))
		{
			PlayState.instance.score += 100;
			name = 'bad';
		}
		else
		{
			PlayState.instance.score += 50;
			name = 'shit';
		}

		var rating = PlayState.instance.comboGroup['rating'].recycle(FlxSprite, () -> Create.sprite(0, 0, Path.image(name)), false, false);
		rating.alpha = 1;
		rating.loadGraphic(Path.image(name));
		rating.updateHitbox();
		rating.screenCenter();
		rating.acceleration.y = 550;
		rating.velocity.y = -FlxG.random.int(140, 175);
		rating.velocity.x = -FlxG.random.int(0, 10);
		rating.revive();
		FlxTween.tween(rating, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> rating.kill(), startDelay: Conductor.beatLength * .001});

		var count:Int = 0;
		var arr = Std.string(PlayState.instance.combo).lpad('0', 3).split('');
		arr.reverse();
		for (num in arr)
		{
			var comboNum = PlayState.instance.comboGroup['combo'].recycle(FlxSprite, () -> Create.sprite(0, 0, Path.image('num$num')), false, false);
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
			comboNum.revive();
			FlxTween.tween(comboNum, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> comboNum.kill(), startDelay: Conductor.beatLength * .001});
			count++;
		}

		if (PlayState.instance.combo >= 10)
		{
			var comboSpr = PlayState.instance.comboGroup['comboSpr'].recycle(FlxSprite, () -> Create.sprite(0, 0, Path.image('combo')), false, false);
			comboSpr.alpha = 1;
			comboSpr.updateHitbox();
			comboSpr.screenCenter();
			comboSpr.offset.x = -comboSpr.width * .5;
			comboSpr.offset.y = -(comboSpr.height + 25);
			comboSpr.acceleration.y = FlxG.random.int(200, 300);
			comboSpr.velocity.y = -FlxG.random.int(140, 160);
			comboSpr.velocity.x = FlxG.random.int(1, 10);
			comboSpr.revive();
			FlxTween.tween(comboSpr, {alpha: 0}, .2, {type: ONESHOT, onComplete: tween -> comboSpr.kill(), startDelay: Conductor.beatLength * .001});
		}
	}
}
