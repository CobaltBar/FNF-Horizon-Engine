package objects;

class Strumline extends FlxSpriteGroup
{
	static final angles = [270, 180, 0, 90];

	public var strums:FlxTypedSpriteGroup<StrumNote>;
	public var notes:Array<FlxTypedSpriteGroup<Note>> = [];
	public var covers:Array<FlxCopySprite> = [];
	public var splashes:FlxTypedSpriteGroup<FlxCopySprite>;
	public var uNoteData:Array<NoteJson> = [];

	public var noteMove:Note->Void;

	public function new(x:Float, y:Float, ?mod:Mod)
	{
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
		for (i in 0...notes.length)
			notes[i].forEachAlive(note -> noteMove(note));
		super.update(elapsed);
	}
}
