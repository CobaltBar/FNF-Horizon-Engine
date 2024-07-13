package states;

import flixel.math.FlxRect;
import flixel.util.FlxSort;
import haxe.io.Path as HaxePath;
import openfl.events.KeyboardEvent;
import sys.FileSystem;

class PlayState extends MusicState
{
	public static var instance:PlayState;
	public static var mods:Array<Mod> = [];
	public static var songs:Array<Song> = [];
	public static var difficulty:String = "";
	public static var week:Week;

	public var audios:Map<String, FlxSound> = [];

	public var playerStrum:Strumline;
	public var opponentStrum:Strumline;

	public var curSection:Int = -1;

	public var scrollSpeed:Float = 1;
	public var score:Int = 0;
	public var accuracy:Float = 0;
	public var misses:Int = 0;
	public var combo:Int = 0;
	public var scores:Map<String, Int> = ["sick" => 0, "good" => 0, "bad" => 0, "shit" => 0];

	public var comboGroup:Map<String, FlxSpriteGroup> = [];

	public override function create()
	{
		Path.clearStoredMemory();
		super.create();
		instance = this;
		bop = zoom = false;
		loadAssets();

		for (thing in ['rating', 'combo', 'comboSpr'])
		{
			comboGroup.set(thing, new FlxSpriteGroup());
			add(comboGroup[thing]);
		}

		var countdown = new Countdown();

		add(playerStrum = new Strumline(0, 150));
		playerStrum.screenCenter(X);
		playerStrum.x += 500;
		add(opponentStrum = new Strumline(0, 150));
		opponentStrum.screenCenter(X);
		opponentStrum.x -= 500;
		// i am too lazy to do it another way
		@:privateAccess opponentStrum.unconfirm = true;

		opponentStrum.noteUpdate = note -> if (Conductor.time > note.time)
		{
			if (audios.exists('Voices'))
				audios['Voices'].volume = 1;
			if (!note.isHit)
			{
				opponentStrum.strums.members[note.data % 4].confirm(note.length <= 0);
				note.hit();
				opponentStrum.addNextNote();
			}
		}
		playerStrum.noteUpdate = note -> if (Conductor.time > (note.time + 1000))
		{
			if (audios.exists('Voices'))
				audios['Voices'].volume = 0;
			else if (audios.exists('Voices-Player'))
				audios['Voices-Player'].volume = 0;

			note.kill();
			playerStrum.addNextNote();
			miss();
		}

		Conductor.reset();
		Conductor.switchToMusic = Conductor.enabled = false;
		createChart();

		countdown.start();

		#if DISCORD_ENABLED
		DiscordRPC.change('In Game: ${songs[0].name}', 'Score: $score - Combo: $combo');
		#end

		PlayerInput.init();
		Path.clearUnusedMemory();
	}

	override function onBeat()
	{
		if (curBeat % 4 == 0)
			onSection();
		super.onBeat();
	}

	function onSection() {}
	
	function createChart():Void
	{
		var chart:Chart = Path.json('song-${HaxePath.withoutDirectory(songs[0].folderName)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed ?? 1;
		Conductor.bpm = chart.bpm;
		for (song in songs[0].audioFiles)
		{
			var audio = FlxG.sound.play(song).pause();
			audios.set(HaxePath.withoutExtension(HaxePath.withoutDirectory(song)), audio);
		}

		var noteCount:Array<Int> = [0, 0];
		for (note in chart.notes)
		{
			var strum = note.data > 3 ? opponentStrum : playerStrum;
			if (noteCount[note.data > 3 ? 0 : 1] < 50)
			{
				var n = new Note(note.data);
				n.resetNote(note, strum);
				n.move(strum.strums.members[note.data % 4]);
				n.y += 20000;
				strum.notes[note.data % 4].add(n);
				noteCount[note.data > 3 ? 0 : 1] += 1;
			}
			else
				strum.uNoteData.push(note);
		}

		for (note in playerStrum.notes)
			note.sort(FlxSort.byY, FlxSort.DESCENDING);
		for (note in opponentStrum.notes)
			note.sort(FlxSort.byY, FlxSort.DESCENDING);
	}

	public override function destroy()
	{
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, PlayerInput.onPress);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, PlayerInput.onRelease);
		instance = null;
		super.destroy();
	}

	public function miss()
	{
		misses += 1;
		combo = 0;
	}

	inline function loadAssets():Void
	{
		for (item in [
			'note', 'ready', 'set', 'go', 'combo', 'num0', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6', 'num7', 'num8', 'num9', 'sick', 'good', 'bad',
			'shit'
		])
			Path.image(item, mods);
		for (item in ['Three', 'Two', 'One', 'Go'])
			Path.audio(item, mods);
	}
}
