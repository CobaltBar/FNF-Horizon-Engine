package objects.game;

class Strumline extends FlxSpriteGroup
{
	static final angles = [270, 180, 0, 90];

	public var strums:FlxTypedSpriteGroup<StrumNote>;

	public var notes:FlxTypedSpriteGroup<Note>;
	public var uNoteData:Array<NoteJSON> = [];

	public var autoHit:Bool = false;

	public function new(x:Float, y:Float)
	{
		super(0, y);

		add(strums = new FlxTypedSpriteGroup<StrumNote>(-5, 0));
		add(notes = new FlxTypedSpriteGroup<Note>(-5, 0));

		for (i in 0...4)
		{
			var strum = new StrumNote(i);
			strum.angle = strum.angleOffset = angles[i];
			strum.x = (strum.width * i) + 5;
			strums.add(strum);
		}

		screenCenter(X);
		this.x += x;
	}

	public function addNextNote()
		if (uNoteData.length > 0)
		{
			var data = uNoteData.shift();
			var n = notes.recycle(Note, () ->
			{
				var n = new Note(data.data);
				n.visible = false;
				return n;
			});
			n.y = FlxG.height * 10;
			n.resetNote(data, this);
			n.visible = true;
		}
}
