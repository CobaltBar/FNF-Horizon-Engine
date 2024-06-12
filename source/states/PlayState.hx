package states;

import flixel.util.FlxSort;
import haxe.io.Path as HaxePath;
import openfl.events.KeyboardEvent;
import sys.io.File;
import tjson.TJSON;

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
		shouldBop = shouldZoom = Conductor.switchToMusic = false;

		for (thing in ['rating', 'combo', 'comboSpr'])
		{
			comboGroup.set(thing, new FlxSpriteGroup());
			add(comboGroup[thing]);
		}

		add(playerStrum = new Strumline(FlxG.width - 50, 150));
		playerStrum.x -= playerStrum.width;
		add(opponentStrum = new Strumline(50, 150));
		opponentStrum.noteUpdate = note -> if (note.y < opponentStrum.strums.members[note.data % 4].y)
		{
			note.kill();
			opponentStrum.strums.members[note.data % 4].confirm();
			opponentStrum.addNextNote();
		}
		playerStrum.noteUpdate = note -> if (note.y < -note.height)
		{
			note.kill();
			playerStrum.addNextNote();
			miss();
		}

		DiscordRPC.change('In Game', 'Song: ${songs[0].name}\n');

		Conductor.reset();
		createChart();
		for (audio in audios)
			audio.play();
		Conductor.song = audios["Inst"];
		Conductor.song.onComplete = () ->
		{
			songs.shift();
			if (songs.length == 0)
			{
				Conductor.reset();
				Conductor.bpm = @:privateAccess TitleState.titleData.bpm;
				Conductor.song = FlxG.sound.music;
				FlxG.sound.music.resume();
				FlxG.sound.music.fadeIn(.75);
				MusicState.switchState(new MainMenuState());
			}
			else
				MusicState.switchState(new PlayState(), true, true);
		}
		PlayerInput.init();
	}

	inline function createChart():Void
	{
		var chart:Chart = Path.json('song-${HaxePath.withoutDirectory(songs[0].path)}-${difficulty}', mods);
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
				n.y = -10000;
				n.resetNote(note);
				n.rgb.set(Settings.data.noteRGB[note.data % 4].base, Settings.data.noteRGB[note.data % 4].highlight,
					Settings.data.noteRGB[note.data % 4].outline);
				n.angle = n.angleOffset = strum.strums.members[note.data % 4].angleOffset;
				n.x = ((strum.strums.members[note.data % 4].width * note.data % 4) + 5) - 20;
				n.y = strum.y + strum.strums.members[note.data % 4].y - (0.45 * (Conductor.time - note.time) * scrollSpeed * note.mult) - n.height;
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

	@:keep public inline function miss()
	{
		misses += 1;
		combo = 0;
	}
}
