package horizon.objects.game;

import flixel.util.FlxSort;

@:publicFields
class Strumline extends FlxSpriteGroup
{
	var strums:Array<StrumNote> = [];
	var notes:FlxTypedSpriteGroup<Note>;
	var sustains:FlxTypedSpriteGroup<Sustain>;
	var splashes:FlxTypedSpriteGroup<NoteSplash>;

	var autoHit:Bool = false;
	var uNoteData:Array<NoteJSON> = [];

	function new(x:Float, y:Float, ?cams:Array<FlxCamera>)
	{
		super(0, y);

		for (i in 0...4)
		{
			var strum = new StrumNote(i);
			strum.x = (strum.width + 5) * i;
			strum.y = -350;
			strum.alpha = 0;
			add(strum);
			strums.push(strum);
		}

		add(sustains = new FlxTypedSpriteGroup<Sustain>());
		add(notes = new FlxTypedSpriteGroup<Note>());
		add(splashes = new FlxTypedSpriteGroup<NoteSplash>());

		if (cams != null)
			cameras = cams;

		screenCenter(X);
		this.x += x;
	}

	function introAnim(invert:Bool = false):Void
	{
		FlxTimer.loop(0.1,
			loop -> FlxTween.tween(strums[invert ? strums.length - loop : loop - 1], {y: y, alpha: 1}, .5, {type: ONESHOT, ease: FlxEase.circOut}), 4);
	}

	function addNextNote()
		if (uNoteData.length > 0)
		{
			var noteData = uNoteData.shift();
			var n = notes.recycle(Note, createNote);
			n.y = FlxG.height * 4;
			n.setup(noteData, this);
			notes.sort((Order:Int, Obj1:Note, Obj2:Note) -> FlxSort.byValues(Order, Obj1.time, Obj2.time));
		}

	function createNote()
	{
		var n = new Note();
		n.cameras = cameras;
		n.visible = false;
		return n;
	}
}
