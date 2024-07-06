package states;

import flixel.util.FlxSort;
import haxe.io.Path as HaxePath;
import openfl.events.KeyboardEvent;

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
		bop = zoom = Conductor.switchToMusic = false;

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

		opponentStrum.noteUpdate = note -> if (Conductor.time > note.time)
		{
			note.kill();
			opponentStrum.strums.members[note.data % 4].confirm();
			opponentStrum.addNextNote();
		}
		playerStrum.noteUpdate = note -> if (Conductor.time > (note.time + 1000))
		{
			note.kill();
			playerStrum.addNextNote();
			miss();
		}

		FlxG.camera.bgColor = 0xFF9B9B9B;

		Conductor.reset();
		createChart();

		#if DISCORD_ENABLED
		DiscordRPC.change('In Game: ${songs[0].name}', 'Score: $score - Combo: $combo');
		#end

		countdown.start();
		PlayerInput.init();
		Path.clearUnusedMemory();
	}

	inline function createChart():Void
	{
		var chart:Chart = Path.json('song-${HaxePath.withoutDirectory(songs[0].folderName)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed ?? 1;
		Conductor.bpm = chart.bpm;
		for (song in songs[0].audioFiles)
		{
			var audio = FlxG.sound.play(song);
			audio.pause();
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
				n.y += 100000;
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
		FlxG.camera.bgColor = 0xFF000000;
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
		for (item in [
			'note', 'ready', 'set', 'go', 'combo', 'num0', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6', 'num7', 'num8', 'num9', 'sick', 'good', 'bad',
			'shit'
		])
			Path.image(item);
}
