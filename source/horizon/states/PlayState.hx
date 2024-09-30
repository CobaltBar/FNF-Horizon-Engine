package horizon.states;

@:publicFields
class PlayState extends MusicState
{
	static var mods:Array<Mod>;
	static var songs:Array<Song>;
	static var difficulty:String;
	static var week:Week;
	static var instance:PlayState;

	var audios:Map<String, FlxSound> = [];
	var comboGroup:Map<String, FlxSpriteGroup> = [];

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
		// loadAssets();
		bop = zoom = false;
		FlxG.sound.music.pause();

		for (thing in ['rating', 'combo', 'comboSpr'])
		{
			comboGroup.set(thing, new FlxSpriteGroup());
			add(comboGroup[thing]);
			comboGroup[thing].cameras = [camHUD];
		}

		add(new NoteSprite().screenCenter());
		var spr:NoteSprite;
		add(spr = new NoteSprite());
		spr.screenCenter();
		spr.y += 200;

		/*
			add(playerStrum = new Strumline(FlxG.width * .275, 150));
			add(opponentStrum = new Strumline(-FlxG.width * .275, 150));

			playerStrum.cameras = [camHUD];
			opponentStrum.cameras = [camHUD];
			opponentStrum.autoHit = true;
		 */

		Conductor.reset();
		Conductor.switchToMusic = false;

		loadChart();

		/*for (song in songs[0].audioFiles)
				audios.set(HaxePath.withoutExtension(HaxePath.withoutDirectory(song)).toLowerCase(), FlxG.sound.play(song).pause());

			add(new Countdown());

			new FlxTimer().start(1, timer -> for (key => val in audios)
				if (key != 'inst')
					if (Math.abs(audios['inst'].time - val.time) >= 10)
						val.time = audios['inst'].time, 0);

			PlayerInput.init(); */
		Path.clearUnusedMemory();
	}

	override function destroy():Void
	{
		// PlayerInput.deinit();
		instance = null;
		super.destroy();
	}

	function loadChart():Void
	{
		var chart:Chart = Path.json('SONG-${PathUtil.withoutDirectory(songs[0].folder)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed * 1.1 ?? 1.1;
		Conductor.bpm = chart.bpm;

		/*
			for (note in chart.notes)
				(note.data > 3 ? opponentStrum : playerStrum).uNoteData.push(note);

			ArraySort.sort(opponentStrum.uNoteData, (a, b) -> (a.time < b.time ? -1 : (a.time > b.time ? 1 : 0)));
			ArraySort.sort(playerStrum.uNoteData, (a, b) -> (a.time < b.time ? -1 : (a.time > b.time ? 1 : 0)));

			for (i in 0...50)
			{
				opponentStrum.addNextNote();
				
		 */
	}
}
