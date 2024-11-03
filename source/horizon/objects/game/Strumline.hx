package horizon.objects.game;

import flixel.util.FlxSort;
import haxe.CallStack;

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

		for (i in 0...4)
		{
			var strum = new StrumNote(i);
			strum.x = (strum.width + 5) * i;
			strum.y = -350;
			strum.alpha = 0;
			add(strum);
			strums.push(strum);
		}

		add(notes = new FlxTypedSpriteGroup<Note>());

		screenCenter(X);
		this.x += x;

		if (cameras != null)
			this.cameras = cameras;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		for (note in notes.members)
			if (note != null && note.exists && note.alive)
			{
				if (autoHit && Conductor.time > note.time)
				{
					note.hit(strums[note.data % strums.length]);
					addNextNote();
					continue;
				}
				if (Conductor.time > note.time + 350)
				{
					note.kill();
					addNextNote();
					continue;
				}
				note.move(strums[note.data % strums.length]);
			}
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
			var n = notes.recycle(() ->
			{
				var n = new Note();
				n.cameras = cameras;
				n.visible = n.active = false;
				return n;
			});
			n.y = FlxG.height * 4;
			n.resetNote(noteData);
			notes.sort((Order:Int, Obj1:Note, Obj2:Note) -> FlxSort.byValues(Order, Obj1.time, Obj2.time));
		}
}
