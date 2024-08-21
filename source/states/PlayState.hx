package states;

import flixel.graphics.FlxGraphic;
import haxe.ds.ArraySort;
import haxe.io.Path as HaxePath;
import openfl.events.KeyboardEvent;

@:publicFields
class PlayState extends MusicState
{
	static var mods:Array<Mod> = [];
	static var songs:Array<Song> = [];
	static var difficulty:String = '';
	static var week:Week;
	static var instance:PlayState;

	var audios:Map<String, FlxSound> = [];
	var comboGroup:Map<String, FlxSpriteGroup> = [];

	var playerStrum:Strumline;
	var opponentStrum:Strumline;

	var scrollSpeed:Float = 1;
	var score:Int = 0;
	var accuracy:Float = 0;
	var misses:Int = 0;
	var combo:Int = 0;
	var scores:Map<String, Int> = ["sick" => 0, "good" => 0, "bad" => 0, "shit" => 0];

	var camOther:FlxCamera;
	var camHUD:FlxCamera;
	var camFunk:FlxCamera;

	override function create():Void
	{
		Path.clearStoredMemory();

		camFunk = Create.camera();
		camHUD = Create.camera();
		camOther = Create.camera();

		super.create();

		instance = this;
		loadAssets();
		bop = zoom = false;
		FlxG.sound.music.pause();

		for (thing in ['rating', 'combo', 'comboSpr'])
		{
			comboGroup.set(thing, new FlxSpriteGroup());
			add(comboGroup[thing]);
			comboGroup[thing].cameras = [camHUD];
		}

		add(playerStrum = new Strumline(FlxG.width * .275, 150));
		add(opponentStrum = new Strumline(-FlxG.width * .275, 150));

		playerStrum.cameras = [camHUD];
		opponentStrum.cameras = [camHUD];
		opponentStrum.autoHit = true;

		Conductor.reset();
		Conductor.switchToMusic = false;

		var chart:Chart = Path.json('song-${HaxePath.withoutDirectory(songs[0].folderName)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed * 1.1 ?? 1.1;
		Conductor.bpm = chart.bpm;

		for (note in chart.notes)
			(note.data > 3 ? opponentStrum : playerStrum).uNoteData.push(note);

		ArraySort.sort(opponentStrum.uNoteData, (a, b) -> (a.time < b.time ? -1 : (a.time > b.time ? 1 : 0)));
		ArraySort.sort(playerStrum.uNoteData, (a, b) -> (a.time < b.time ? -1 : (a.time > b.time ? 1 : 0)));

		for (i in 0...50)
		{
			opponentStrum.addNextNote();
			playerStrum.addNextNote();
		}

		for (song in songs[0].audioFiles)
			audios.set(HaxePath.withoutExtension(HaxePath.withoutDirectory(song)).toLowerCase(), FlxG.sound.play(song).pause());

		add(new Countdown());

		new FlxTimer().start(1, timer -> for (key => val in audios)
			if (key != 'inst')
				if (Math.abs(audios['inst'].time - val.time) >= 10)
					val.time = audios['inst'].time, 0);

		PlayerInput.init();

		Path.clearUnusedMemory();
	}

	override function destroy():Void
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayerInput.onPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, PlayerInput.onRelease);
		instance = null;
		super.destroy();
	}

	function miss()
	{
		if (PlayState.instance.audios.exists('voices'))
			PlayState.instance.audios['voices'].volume = 0;
		else if (PlayState.instance.audios.exists('voices-player'))
			PlayState.instance.audios['voices-player'].volume = 0;
		misses += 1;
		combo = 0;
	}

	private function loadAssets():Void
	{
		for (item in ['note', 'ready', 'set', 'go', 'combo', 'num', 'sick', 'good', 'bad', 'shit'].concat(Countdown.countdownNameArr))
			Path.image(item, mods);
		for (item in ['Three', 'Two', 'One', 'Go'].concat(Countdown.countdownSoundArr))
			Path.audio(item, mods);
	}
}
