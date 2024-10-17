package horizon.objects.game;

class Strumline
{
	public var strums:FlxTypedSpriteGroup<StrumNote>;
	public var notes:FlxTypedSpriteGroup<Note>;

	public var autoHit:Bool = false;
	public var uNoteData:Array<NoteJSON> = [];

	public function new(x:Float, y:Float, ?cameras:Array<FlxCamera>)
	{
		FlxG.state.add(strums = new FlxTypedSpriteGroup<StrumNote>(0, y, 4));
		FlxG.state.add(notes = new FlxTypedSpriteGroup<Note>(0, y));

		for (i in 0...4)
		{
			var strum = new StrumNote(i);
			strums.add(strum);

			strum.x = (strum.width + 5) * i;
		}

		strums.screenCenter(X);
		notes.screenCenter(X);
		strums.x += x;
		notes.x += x;

		if (cameras != null)
			strums.cameras = notes.cameras = cameras;
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
				if (n.scale.x != 1)
					n.scale.set(1, 1);
				notes.sort((Order:Int, Obj1:Note, Obj2:Note) -> FlxSort.byValues(Order, Obj1.time, Obj2.time)); */
		}
}
