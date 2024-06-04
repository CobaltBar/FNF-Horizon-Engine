package states;

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
		add(opponentStrum = new Strumline(50, 150));
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
		for (note in chart.notes)
		{
			var n = new Note(note.data);
			n.data = note.data;
			n.time = note.time;
			n.length = note.length;
			n.type = note.type;
			n.mult = note.mult;
			var strum = note.data > 3 ? opponentStrum : playerStrum;
			n.x = ((strum.strums.members[note.data % 4].width * note.data % 4) + 5) - 20;
			n.rgb.set(Settings.data.noteRGB[note.data % 4].base, Settings.data.noteRGB[note.data % 4].highlight, Settings.data.noteRGB[note.data % 4].outline);
			n.angle = n.angleOffset = strum.strums.members[note.data % 4].angleOffset;
			strum.notes[note.data % 4].add(n);
		}
	}

	public override function destroy()
	{
		instance = null;
		super.destroy();
	}
}
