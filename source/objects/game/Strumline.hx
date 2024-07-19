package objects.game;

class Strumline extends FlxSpriteGroup
{
	static final angles = [270, 180, 0, 90];

	public var strums:FlxTypedSpriteGroup<StrumNote>;

	public var notes:Array<FlxTypedSpriteGroup<Note>> = [];
	public var uNoteData:Array<NoteJSON> = [];

	public var autoHit:Bool = false;

	var updateNotes:Bool = true; // TODO CHANGE THIS

	public function new(x:Float, y:Float)
	{
		// Countdown.countdownEnded.add(() -> updateNotes = true);

		super(0, y);

		add(strums = new FlxTypedSpriteGroup<StrumNote>(-5, 0));

		for (i in 0...4)
		{
			var strum = new StrumNote(i);
			strum.angle = strum.angleOffset = angles[i];
			strum.x = (strum.width * i) + 5;
			strums.add(strum);
			notes.push(new FlxTypedSpriteGroup<Note>(-5, 0));
		}

		for (i in 0...4)
			add(notes[i]);

		screenCenter(X);
		this.x += x;
	}

	public override function update(elapsed:Float):Void
	{
		if (updateNotes)
			for (i in 0...4)
				notes[i].forEachAlive(note -> note.move(strums.members[note.data % 4], true));
		super.update(elapsed);
	}

	public function addNextNote()
		if (uNoteData.length > 0)
		{
			var data = uNoteData.shift();
			var n = notes[data.data % 4].recycle(Note, () -> new Note(data.data), false, false);
			n.y = -n.height;
			n.resetNote(data, this);
			n.revive();
		}
}
