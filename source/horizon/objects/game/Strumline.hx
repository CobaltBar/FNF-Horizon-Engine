package horizon.objects.game;

class Strumline extends FlxSpriteGroup
{
	public var strums:Array<StrumNote> = [];
	public var notes:FlxTypedSpriteGroup<Note>;

	public var autoHit:Bool = false;
	public var uNoteData:Array<NoteJSON> = [];

	public function new(x:Float, y:Float, ?cameras:Array<FlxCamera>)
	{
		super(0, y);

		notes = new FlxTypedSpriteGroup<Note>();
		for (i in 0...4)
		{
			var strum = new StrumNote(i);
			add(strum);

			strum.x = (strum.width + 5) * i;
			add(strum);
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
				if (n.scale.x != 1)
					n.scale.set(1, 1);
				notes.sort((Order:Int, Obj1:Note, Obj2:Note) -> FlxSort.byValues(Order, Obj1.time, Obj2.time)); */
		}
}
