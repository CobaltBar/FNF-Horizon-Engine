package objects;

class Strumline extends FlxSpriteGroup
{
	static final angles = [270, 180, 0, 90];

	public var strums:FlxTypedSpriteGroup<StrumNote>;
	public var notes:Array<FlxTypedSpriteGroup<Note>> = [];
	public var covers:Array<FlxCopySprite> = [];
	public var splashes:FlxTypedSpriteGroup<FlxCopySprite>;
	public var uNoteData:Array<NoteJson> = [];

	static var defaultNoteMove:Note->Void;

	public var noteMove:Note->Void;

	public var noteUpdate:Note->Void;

	public function new(x:Float, y:Float, ?mod:Mod)
	{
		defaultNoteMove = note -> note.y = y
			+ strums.members[note.data % 4].y - (0.45 * (Conductor.time - note.time) * PlayState.instance.scrollSpeed * note.mult) - note.height;
		noteMove = defaultNoteMove;

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
		if (noteUpdate != null)
			for (i in 0...notes.length)
				notes[i].forEachAlive(note ->
				{
					noteMove(note);
					noteUpdate(note);
				});
		else
			for (i in 0...notes.length)
				notes[i].forEachAlive(note -> noteMove(note));

		super.update(elapsed);
	}

	public function addNextNote()
	{
		var data = uNoteData.shift();
		if (data != null)
		{
			var n = notes[data.data % 4].recycle(Note, () -> new Note(data.data));
			n.y = -20000; // get sent into outer space idiot
			n.resetNote(data);
			n.x = ((strums.members[data.data % 4].width * data.data % 4) + 5) - 20;
			n.rgb.set(Settings.data.noteRGB[data.data % 4].base, Settings.data.noteRGB[data.data % 4].highlight, Settings.data.noteRGB[data.data % 4].outline);
			n.angle = n.angleOffset = strums.members[data.data % 4].angleOffset;
		}
	}
}
