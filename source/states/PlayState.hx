package states;

import flixel.util.FlxSort;
import haxe.io.Path as HaxePath;
import openfl.events.KeyboardEvent;
import sys.io.File;
import tjson.TJSON;

class PlayState extends MusicState
{
	public var playerStrum:Strumline;
	public var opponentStrum:Strumline;

	public static var instance:PlayState;

	public var scrollSpeed:Float = 1;
	public var audios:Map<String, FlxSound> = [];

	public static var mods:Array<Mod> = [];
	public static var songs:Array<Song> = [];
	public static var difficulty:String = "";
	public static var week:Week;

	public override function create()
	{
		Path.clearStoredMemory();
		super.create();
		instance = this;
		shouldBop = shouldZoom = Conductor.switchToMusic = false;

		DiscordRPC.change('In Game', 'Song: \nScore: 69');
		createUI();
		createChart();
		Conductor.reset();
		for (audio in audios)
			audio.play();
		Conductor.song = audios["Inst"];

		PlayerInput.init();
	}

	inline function createUI():Void
	{
		add(playerStrum = new Strumline(FlxG.width - 50, 150));
		playerStrum.x -= playerStrum.width;
		add(opponentStrum = new Strumline(50, 150));
		opponentStrum.noteUpdate = note ->
		{
			if (note.y < opponentStrum.strums.members[note.data % 4].y)
			{
				note.kill();
				opponentStrum.strums.members[note.data % 4].confirm();
				opponentStrum.addNextNote();
			}
		}
	}

	inline function createChart():Void
	{
		var chart:Chart = Path.json('song-${HaxePath.withoutDirectory(songs[0].path)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed ?? 1;
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
				n.resetNote(note);
				n.x = ((strum.strums.members[note.data % 4].width * note.data % 4) + 5) - 20;
				n.y = strum.y + strum.strums.members[note.data % 4].y - (0.45 * (Conductor.time - note.time) * scrollSpeed * note.mult) - n.height;
				n.rgb.set(Settings.data.noteRGB[note.data % 4].base, Settings.data.noteRGB[note.data % 4].highlight,
					Settings.data.noteRGB[note.data % 4].outline);
				n.angle = n.angleOffset = strum.strums.members[note.data % 4].angleOffset;
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
		instance = null;
		super.destroy();
	}
}
