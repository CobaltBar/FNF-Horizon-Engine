package states;

import flixel.graphics.FlxGraphic;
import haxe.io.Path as HaxePath;

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

	override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		instance = this;
		loadAssets();
		bop = zoom = false;
		FlxG.sound.music.pause();

		for (thing in ['rating', 'combo', 'comboSpr'])
		{
			comboGroup.set(thing, new FlxSpriteGroup());
			add(comboGroup[thing]);
		}

		add(playerStrum = new Strumline(FlxG.width * .275, 150));
		add(opponentStrum = new Strumline(-FlxG.width * .275, 150));
		opponentStrum.autoHit = true;

		Conductor.reset();
		Conductor.switchToMusic = false;

		var chart:Chart = Path.json('song-${HaxePath.withoutDirectory(songs[0].folderName)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed * 1.1 ?? 1.1;
		Conductor.bpm = chart.bpm;
		for (note in chart.notes)
			(note.data > 3 ? opponentStrum : playerStrum).uNoteData.push(note);

		for (i in 0...50)
		{
			opponentStrum.addNextNote();
			playerStrum.addNextNote();
		}

		for (song in songs[0].audioFiles)
		{
			var audio = FlxG.sound.play(song).pause();
			audio.time = 0;
			audios.set(HaxePath.withoutExtension(HaxePath.withoutDirectory(song)), audio);
		}

		add(new Countdown());
	}

	private function loadAssets():Void
	{
		for (item in [
			'note', 'ready', 'set', 'go', 'combo', 'num0', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6', 'num7', 'num8', 'num9', 'sick', 'good', 'bad',
			'shit'
		].concat(Countdown.countdownNameArr))
			Path.image(item, mods);
		for (item in ['Three', 'Two', 'One', 'Go'].concat(Countdown.countdownSoundArr))
			Path.audio(item, mods);
	}
}
