package objects.game;

class Note extends NoteSprite
{
	public var data:Int = 0;
	public var time:Float = 0;
	public var length:Float = 0;
	public var type:String;
	public var mult:Float = 1;

	public function resetNote(?json:NoteJson, ?strum:Strumline):Void
	{
		data = json?.data ?? 0;
		time = json?.time ?? 0;
		length = json?.length ?? 0;
		type = json?.type;
		mult = json?.mult ?? 1;

		if (strum != null)
		{
			rgb.set(Settings.data.noteRGB.notes[data % 4].base, Settings.data.noteRGB.notes[data % 4].highlight, Settings.data.noteRGB.notes[data % 4].outline);
			angle = angleOffset = strum.strums.members[data % 4].angleOffset;
			x = ((strum.strums.members[data % 4].width * data % 4) + 5) - 20;
		}
	}

	public function move(strumY:Float, strumNote:StrumNote):Void
		y = strumY + strumNote.y - (0.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult) - height;
}
