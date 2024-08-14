package objects.game;

import flixel.util.FlxSort;

@:publicFields
class Strumline extends FlxSpriteGroup
{
	private static final angles = [270, 180, 0, 90];

	var strums:FlxTypedSpriteGroup<StrumNote>;
	var notes:FlxTypedSpriteGroup<Note>;

	var uNoteData:Array<NoteJSON> = [];

	var autoHit:Bool = false;

	function new(x:Float, y:Float)
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

	function addNextNote()
		if (uNoteData.length > 0)
		{
			var data = uNoteData.shift();
			var n = notes.recycle(Note, () ->
			{
				var n = new Note(data.data);
				n.cameras = cameras;
				n.visible = false;
				return n;
			});
			n.y = FlxG.height * 10;
			n.resetNote(data, this);
			notes.sort((Order:Int, Obj1:Note, Obj2:Note) -> FlxSort.byValues(Order, Obj1.time, Obj2.time));
		}
}
