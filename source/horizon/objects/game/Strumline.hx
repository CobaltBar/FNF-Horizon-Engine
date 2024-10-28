package horizon.objects.game;

@:publicFields
class Strumline extends FlxSpriteGroup
{
	var strums:Array<StrumNote> = [];
	var notes:FlxTypedSpriteGroup<Note>;

	var autoHit:Bool = false;
	var uNoteData:Array<NoteJSON> = [];

	function new(x:Float, y:Float, ?cameras:Array<FlxCamera>)
	{
		super(0, y);

		notes = new FlxTypedSpriteGroup<Note>();
		for (i in 0...4)
		{
			var strum = new StrumNote(i);
			strum.x = (strum.width + 5) * i;
			add(strum);
			strums.push(strum);
		}

		screenCenter(X);
		this.x += x;

		if (cameras != null)
			this.cameras = cameras;
	}

	function addNextNote()
		if (uNoteData.length > 0)
		{
			/*var data = uNoteData.shift();
				var n = notes.recycle(Note, () ->
				{
					var n = new Note(data.data);
					n.cameras = cameras;
					n.visible = false;
					return n;
				});
				n.y = FlxG.height * 10;
				n.resetNote(data, this);
				notes.sort((Order:Int, Obj1:Note, Obj2:Note) -> FlxSort.byValues(Order, Obj1.time, Obj2.time)); */
		}
}
