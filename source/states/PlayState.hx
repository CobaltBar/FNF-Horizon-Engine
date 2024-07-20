package states;

import haxe.io.Path as HaxePath;

class PlayState extends MusicState
{
	public static var mods:Array<Mod> = [];
	public static var songs:Array<Song> = [];
	public static var difficulty:String = '';
	public static var week:Week;
	public static var instance:PlayState;

	public var audios:Map<String, FlxSound> = [];
	public var comboGroup:Map<String, FlxSpriteGroup> = [];

	public var playerStrum:Strumline;
	public var opponentStrum:Strumline;

	public var scrollSpeed:Float = 1;
	public var score:Int = 0;
	public var accuracy:Float = 0;
	public var misses:Int = 0;
	public var combo:Int = 0;
	public var scores:Map<String, Int> = ["sick" => 0, "good" => 0, "bad" => 0, "shit" => 0];

	public var curSection:Int = -1;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		instance = this;
		bop = zoom = false;

		for (item in [
			'note', 'ready', 'set', 'go', 'combo', 'num0', 'num1', 'num2', 'num3', 'num4', 'num5', 'num6', 'num7', 'num8', 'num9', 'sick', 'good', 'bad',
			'shit'
		])
			Path.image(item, mods);
		for (item in ['Three', 'Two', 'One', 'Go'])
			Path.audio(item, mods);

		for (thing in ['rating', 'combo', 'comboSpr'])
		{
			comboGroup.set(thing, new FlxSpriteGroup());
			add(comboGroup[thing]);
		}

		add(playerStrum = new Strumline(FlxG.width * .275, 150));
		add(opponentStrum = new Strumline(-FlxG.width * .275, 150));

		Conductor.reset();
		Conductor.switchToMusic = false;

		var chart:Chart = Path.json('song-${HaxePath.withoutDirectory(songs[0].folderName)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed ?? 1;
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

		Conductor.song = audios["Inst"];
		Conductor.time = 0;

		for (song in audios)
			song.resume();
	}
}
