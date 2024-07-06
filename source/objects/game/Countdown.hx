package objects.game;

import flixel.util.FlxSignal;

class Countdown
{
	var countdownNameArr = ['ready', 'set', 'go'];
	var countdownSoundArr = ['Three', 'Two', 'One', 'Go'];

	public static var countdownEnded:FlxSignal;

	public function new()
	{
		countdownEnded = new FlxSignal();
		@:privateAccess
		PlayState.instance.curBeat = -4;
	}

	public function start():Void
	{
		new FlxTimer().start(Conductor.beatLength * .001, timer ->
		{
			@:privateAccess PlayState.instance.curBeat++;
			switch (timer.elapsedLoops)
			{
				case 1:
					FlxG.sound.play(Path.audio(countdownSoundArr[timer.elapsedLoops - 1]));
				case 2 | 3 | 4:
					FlxG.sound.play(Path.audio(countdownSoundArr[timer.elapsedLoops - 1]));
					var countdownItem = Create.sprite(0, 0, Path.image(countdownNameArr[timer.elapsedLoops - 2]), 1.2);
					countdownItem.screenCenter();
					PlayState.instance.add(countdownItem);
					FlxTween.tween(countdownItem.scale, {x: 1.4, y: 1.4}, Conductor.beatLength * .001,
						{type: ONESHOT, ease: FlxEase.expoOut, onComplete: tween -> countdownItem.destroy()});
					FlxTween.tween(countdownItem, {alpha: 0}, Conductor.beatLength * .001, {type: ONESHOT, ease: FlxEase.expoOut});
				case 5:
					countdownEnded.dispatch();
					for (audio in PlayState.instance.audios)
						audio.play();
					Conductor.song = PlayState.instance.audios["Inst"];
					Conductor.time = 0;
					Conductor.song.onComplete = () ->
					{
						PlayState.songs.shift();
						if (PlayState.songs.length == 0)
						{
							Conductor.reset();
							Conductor.bpm = @:privateAccess TitleState.titleData.bpm;
							Conductor.song = FlxG.sound.music;
							FlxG.sound.music.resume();
							FlxG.sound.music.fadeIn(.75);
							// TODO replace with StoryMenuState and FreeplayState
							MusicState.switchState(new MainMenuState());
						}
						else
							MusicState.switchState(new PlayState(), true, true);
					}
			}
		}, 5);
	}
}
