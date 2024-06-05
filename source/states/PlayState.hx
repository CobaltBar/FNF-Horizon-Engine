package states;

import flixel.util.FlxSort;
import openfl.events.KeyboardEvent;
import sys.io.File;
import tjson.TJSON;

class PlayState extends MusicState
{
	var playerStrum:Strumline;
	var opponentStrum:Strumline;

	public static var instance:PlayState;

	public var scrollSpeed:Float = 1;
	public var audios:Array<FlxSound> = [];

	public static var config:
		{
			mods:Array<Mod>,
			songs:Array<Song>,
			difficulty:String
		};

	static var notesToSpawn:Array<NoteJson> = [];

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
		Conductor.song = audios[0];
	}

	inline function createUI():Void
	{
		add(playerStrum = new Strumline(FlxG.width - 50, 150));
		playerStrum.x -= playerStrum.width;
		playerStrum.noteMove = note ->
		{
			note.y = playerStrum.y
				+ playerStrum.strums.members[note.data % 4].y - (0.45 * (Conductor.time - note.time) * PlayState.instance.scrollSpeed) - note.height;
		}
		add(opponentStrum = new Strumline(50, 150));
		opponentStrum.noteMove = note ->
		{
			note.y = opponentStrum.y
				+ opponentStrum.strums.members[note.data % 4].y - (0.45 * (Conductor.time - note.time) * PlayState.instance.scrollSpeed) - note.height;
			if (note.y < opponentStrum.y)
			{
				note.kill();
				opponentStrum.strums.members[note.data % 4].glowAlphaTarget = 1;
				FlxTimer.wait(.15, () -> opponentStrum.strums.members[note.data % 4].glowAlphaTarget = 0);
			}
		}
	}

	inline function createChart():Void
	{
		var chart:Chart = TJSON.parse(File.getContent(Path.combine([config.songs[0].path, '${config.difficulty}.json'])));
		scrollSpeed = chart.scrollSpeed ?? 1;
		for (song in config.songs[0].audioFiles)
		{
			var audio = FlxG.sound.play(song);
			audio.pause();
			audios.push(audio);
		}

		var noteCount:Array<Int> = [0, 0, 0, 0, 0, 0, 0, 0];
		for (note in chart.notes)
			if (noteCount[note.data] < 100)
			{
				var strum = note.data > 3 ? opponentStrum : playerStrum;
				var n = strum.notes[note.data % 4].recycle(Note, () -> new Note(note.data));
				n.data = note.data;
				n.time = note.time;
				n.length = note.length;
				n.type = note.type;
				n.mult = note.mult;
				n.x = ((strum.strums.members[note.data % 4].width * note.data % 4) + 5) - 20;
				n.rgb.set(Settings.data.noteRGB[note.data % 4].base, Settings.data.noteRGB[note.data % 4].highlight,
					Settings.data.noteRGB[note.data % 4].outline);
				n.angle = n.angleOffset = strum.strums.members[note.data % 4].angleOffset;
				strum.notes[note.data % 4].add(n);
				noteCount[note.data] += 1;
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
