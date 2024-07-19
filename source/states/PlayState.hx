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

		FlxG.camera.zoom = .5;

		Conductor.reset();
		Conductor.switchToMusic = Conductor.enabled = false;

		var chart:Chart = Path.json('song-${HaxePath.withoutDirectory(songs[0].folderName)}-${difficulty}', mods);
		scrollSpeed = chart.scrollSpeed ?? 1;
		Conductor.bpm = chart.bpm;
		for (note in chart.notes)
			(note.data > 3 ? opponentStrum : playerStrum).uNoteData.push(note);

		for (i in 0...4)
		{
			playerStrum.uNoteData.unshift({
				time: 50 * i,
				data: i % 4,
				length: 750,
				mult: 1,
				type: null
			});
			playerStrum.addNextNote();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (FlxG.keys.anyPressed([Y]))
			Conductor.time += elapsed * 1000;
		if (FlxG.keys.anyPressed([H]))
			Conductor.time -= elapsed * 1000;
	}
}
