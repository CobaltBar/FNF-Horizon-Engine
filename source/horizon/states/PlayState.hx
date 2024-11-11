package horizon.states;

import haxe.ds.ArraySort;

@:publicFields
class PlayState extends MusicState
{
	static var mods:Array<Mod>;
	static var songs:Array<Song>;
	static var difficulty:String;
	static var week:Week;
	static var instance:PlayState;

	var audios:Map<String, FlxSound> = [];

	// 1 for the rating and combo sprite, the other for the combo numbers
	var comboGroups:Array<FlxSpriteGroup> = [];

	var playerStrum:Strumline;
	var opponentStrum:Strumline;

	var scrollSpeed:Float = 1;
	var score:Int = 0;
	var accuracy:Float = 0;
	var misses:Int = 0;
	var combo:Int = 0;
	var scores:Map<String, Int> = ["sick" => 0, "good" => 0, "bad" => 0, "shit" => 0];

	var camGame:FlxCamera;
	var camHUD:FlxCamera;
	var camOther:FlxCamera;

	override function create():Void
	{
		Path.clearStoredMemory();

		camGame = Create.camera();
		camHUD = Create.camera();
		camOther = Create.camera();

		super.create();
		instance = this;
		bop = zoom = false;

		for (item in ['note', 'combo', 'num', 'sick', 'good', 'bad', 'shit'].concat(Countdown.countdownNameArr))
			Path.image(item, mods);
		for (item in Countdown.countdownSoundArr)
			Path.audio(item, mods);

		for (i in 0...2)
		{
			var grp = new FlxSpriteGroup();
			grp.cameras = [camHUD];
			add(grp);
			comboGroups.push(grp);
		}

		add(playerStrum = new Strumline(FlxG.width * .275, 50, [camHUD]));
		add(opponentStrum = new Strumline(-FlxG.width * .275, 50, [camHUD]));
		opponentStrum.autoHit = true;

		Conductor.reset();
		Conductor.switchToMusic = false;

		loadChart();
		for (song in songs[0].audios)
			audios.set(PathUtil.withoutExtension(PathUtil.withoutDirectory(song)).toLowerCase(), FlxG.sound.play(song).pause());

		Conductor.song = audios['inst'];

		new FlxTimer().start(1, timer -> for (key => val in audios)
			if (key != 'inst')
				if (Math.abs(audios['inst'].time - val.time) >= 10)
					val.time = audios['inst'].time, 0);

		add(new Countdown());

		playerStrum.introAnim(true);
		opponentStrum.introAnim();
		PlayerInput.init();

		Path.clearUnusedMemory();
	}

	function miss():Void
	{
		misses++;
		combo = 0;
		if (PlayState.instance.audios.exists('voices'))
			PlayState.instance.audios['voices'].volume = 0;
		else if (PlayState.instance.audios.exists('voices-player'))
			PlayState.instance.audios['voices-player'].volume = 0;
	}

	override function destroy():Void
	{
		instance = null;
		super.destroy();
	}

	// TODO ghost note filtering
	function loadChart():Void
	{
		var chart:Chart = Path.json('SONG-${PathUtil.withoutDirectory(songs[0].folder)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed * 1.1 ?? 1.1;
		Conductor.bpm = chart.bpm;

		for (note in chart.notes)
			(note.data > 3 ? opponentStrum : playerStrum).uNoteData.push(note);

		ArraySort.sort(opponentStrum.uNoteData, (a, b) -> (a.time < b.time ? -1 : (a.time > b.time ? 1 : 0)));
		ArraySort.sort(playerStrum.uNoteData, (a, b) -> (a.time < b.time ? -1 : (a.time > b.time ? 1 : 0)));

		for (_ in 0...50)
		{
			playerStrum.addNextNote();
			opponentStrum.addNextNote();
		}
	}
}
