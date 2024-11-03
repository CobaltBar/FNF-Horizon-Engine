package horizon.backend;

class PlayerInput
{
	static var safeMS:Float;
	static var idTracker:Int = 0;
	static var inputEnabled:Bool = false;

	static var ratingScores:Array<Int> = [350, 200, 100, 50];

	public static function init():Void
	{
		safeMS = (Settings.safeFrames / 60) * 250;
		Countdown.countdownEnded.addOnce(() -> inputEnabled = true);

		for (i => bind in ['note_left', 'note_down', 'note_up', 'note_right'])
		{
			Controls.onPress(Settings.keybinds[bind], () -> onPress(i));
			Controls.onRelease(Settings.keybinds[bind], () -> PlayState.instance.playerStrum.strums[i].resetAnim());
		}
	}

	static function onPress(id:Int):Void
	{
		var strum = PlayState.instance.playerStrum.strums[id];
		if (inputEnabled)
		{
			for (note in PlayState.instance.playerStrum.notes.members)
			{
				if (note == null || !note.exists || !note.alive || note.data % 4 != id)
					continue;

				if (Math.abs(Conductor.time - note.time) <= Settings.hitWindows[3] + safeMS)
				{
					PlayState.instance.playerStrum.addNextNote();
					if (PlayState.instance.audios.exists('voices'))
						PlayState.instance.audios['voices'].volume = 1;
					else if (PlayState.instance.audios.exists('voices-player'))
						PlayState.instance.audios['voices-player'].volume = 1;
					PlayState.instance.combo++;
					note.hit(strum, false);
					judge(Math.abs(Conductor.time - note.time));
					return;
				}
			}
		}
		strum.press();
		if (!Settings.ghostTapping)
			PlayState.instance.miss();
	}

	// TODO
	static function judge(diff:Float):Void
	{
		/*var ratingName:String;
			if (diff <= Settings.hitWindows[0] + safeMS)
			{
				ratingName = 'sick';
				PlayState.instance.score += 350;
			}
			else if (diff <= Settings.hitWindows[1] + safeMS)
			{
				ratingName = 'good';
				PlayState.instance.score += 200;
			}
			else if (diff <= Settings.hitWindows[2] + safeMS)
			{
				ratingName = 'bad';
				PlayState.instance.score += 100;
			}
			else
			{
				ratingName = 'shit';
				PlayState.instance.score += 50;
		}*/
	}
}
/*
	static function judge(time:Float):Void
	{
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
				var spr = Create.sparrow(0, 0, Path.sparrow('num', PlayState.mods));
				spr.animation.addByNames('idle', ['num$num'], 24);
				spr.animation.play('idle');
				spr.cameras = [PlayState.instance.camHUD];
				return spr;
			});
			comboNum.alpha = 1;
			comboNum.animation.addByNames('idle', ['num$num'], 24);
			comboNum.animation.play('idle');
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
 */
