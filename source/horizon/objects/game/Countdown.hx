package horizon.objects.game;

@:publicFields
class Countdown extends FlxSpriteGroup
{
	static var countdownNameArr = ['ready', 'set', 'go'];
	static var countdownSoundArr = ['three', 'two', 'one', 'go'];

	static var countdownEnded:FlxSignal = new FlxSignal();

	var effectOnly:Bool = false;

	function new(effectOnly:Bool = false)
	{
		super();
		Conductor.beatSignal.add(countdown);
		this.effectOnly = effectOnly;
		if (!effectOnly)
		{
			@:privateAccess Conductor.time = Conductor.beatTracker = -Conductor.beatLength * 5;
			Conductor.curBeat = -4;
		}
		cameras = [PlayState.instance.camHUD];
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (!effectOnly)
			Conductor.time += elapsed * 1000;
	}

	function countdown():Void
	{
		if (Conductor.curBeat < 1)
		{
			if (Conductor.curBeat > -3)
			{
				var countdownItem = Create.sprite(0, 0, Path.image(countdownNameArr[Conductor.curBeat + 2]));
				countdownItem.screenCenter();
				add(countdownItem);
				FlxTween.tween(countdownItem.scale, {x: 1.1, y: 1.1}, Conductor.beatLength * .002,
					{type: ONESHOT, ease: FlxEase.expoOut, onComplete: tween -> countdownItem.destroy()});
				FlxTween.tween(countdownItem, {alpha: 0}, Conductor.beatLength * .002, {type: ONESHOT, ease: FlxEase.expoOut});
			}

			FlxG.sound.play(Path.audio(countdownSoundArr[Conductor.curBeat + 3]));
		}

		if (Conductor.curBeat > 0)
		{
			@:privateAccess Conductor.time = Conductor.beatTracker = 0;
			Conductor.song = PlayState.instance.audios['inst'];
			Conductor.beatSignal.remove(countdown);
			Conductor.song.onComplete = () -> if (PlayState.songs.length > 0)
			{
				PlayState.songs.shift();
				if (PlayState.songs.empty())
				{
					Conductor.reset();
					Conductor.bpm = @:privateAccess TitleState.titleData.bpm;
					Conductor.song = FlxG.sound.music;
					FlxG.sound.music.resume();
					FlxG.sound.music.fadeIn();
					// TODO replace with StoryMenuState and FreeplayState
					MusicState.switchState(new MainMenuState());
				}
				else
					MusicState.switchState(new PlayState(), true, true);
			}
			countdownEnded.dispatch();
			for (val in PlayState.instance.audios)
				val.play(true);

			destroy();
		}
	}

	override function destroy():Void
	{
		Conductor.beatSignal.remove(countdown);
		super.destroy();
	}
}
