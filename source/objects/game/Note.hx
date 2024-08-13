package objects.game;

class Note extends NoteSprite
{
	public var data:Int;
	public var time:Float;
	public var len:Float;
	public var type:String;
	public var mult:Float;

	var strumline:Strumline;
	var strum:StrumNote;

	public function resetNote(json:NoteJSON, line:Strumline):Void
	{
		data = json.data ?? 0;
		time = json.time ?? 0;
		len = json.length ?? 0;
		type = json.type;
		mult = json.mult ?? 1;
		strumline = line;
		strum = strumline.strums.members[data % 4];

		x = strum.x;
		var rgbDat = Settings.data.noteRGB.notes[data % 4];
		rgb.set(rgbDat.base, rgbDat.highlight, rgbDat.outline);
		angle = angleOffset = strum.angleOffset;
		visible = true;
	}

	public override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		y = strum.y - (.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult);

		if (strumline.autoHit)
			if (Conductor.time >= time)
			{
				strumline.addNextNote();
				strum.confirm();
				kill();
			}
	}
}
