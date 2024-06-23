package objects.game;

class Strumline extends FlxSpriteGroup
{
	static final angles = [270, 180, 0, 90];

	public var strums:FlxTypedSpriteGroup<StrumNote>;
	public var notes:Array<FlxTypedSpriteGroup<Note>> = [];
	public var covers:Array<FlxCopySprite> = [];
	public var splashes:FlxTypedSpriteGroup<FlxCopySprite>;
	public var uNoteData:Array<NoteJson> = [];

	public var noteUpdate:Note->Void;

	var updateNotes:Bool = false;

	public function new(x:Float, y:Float, ?mod:Mod)
	{
		Countdown.countdownEnded.add(() -> updateNotes = true);

		super(x, y);

		add(strums = new FlxTypedSpriteGroup<StrumNote>(x, 0));
		add(splashes = new FlxTypedSpriteGroup<FlxCopySprite>(0, 0));

		for (i in 0...4)
		{
			var strum = new StrumNote(i);
			strum.angle = strum.angleOffset = angles[i];
			strum.x = (strum.width * i) + 5;
			strums.add(strum);
			strums.x -= 5;
			notes.push(new FlxTypedSpriteGroup<Note>(x, 0));
		}

		for (i in 0...4)
			add(notes[i]);
	}

	public override function update(elapsed:Float)
	{
		if (updateNotes)
		{
			if (noteUpdate != null)
				for (i in 0...notes.length)
					notes[i].forEachAlive(note ->
					{
						note.move(strums.members[note.data % 4].y, strums.members[note.data % 4]);
						noteUpdate(note);
					});
			else
				for (i in 0...notes.length)
					notes[i].forEachAlive(note -> note.move(strums.members[note.data % 4].y, strums.members[note.data % 4]));
		}

		super.update(elapsed);
	}

	public function addNextNote()
	{
		var data = uNoteData.shift();
		if (data != null)
		{
			var n = notes[data.data % 4].recycle(Note, () -> new Note(data.data), false, false);
			n.y = -20000; // get sent into outer space idiot
			n.resetNote(data);
			n.revive();
		}
	}
}
