package states;

import openfl.events.KeyboardEvent;
import sys.io.File;
import tjson.TJSON;

class PlayState extends MusicState
{
	var playerStrum:Strumline;
	var opponentStrum:Strumline;

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
		shouldBop = shouldZoom = Conductor.switchToMusic = false;

		DiscordRPC.change('In Game', 'Song: \nScore: 69');
		createUI();
		createChart();
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

		for (note in chart.notes)
		{
			var n = new Note(note.data);
			var strum = note.data > 3 ? playerStrum : opponentStrum;
			n.x = strum.members[note.data % 4].x;
			n.rgb.set(Settings.data.noteRGB[note.data % 4].base, Settings.data.noteRGB[note.data % 4].highlight, Settings.data.noteRGB[note.data % 4].outline);
			n.angle = n.angleOffset = cast(strum.members[note.data % 4], Note).angleOffset;
		}
	}
}
