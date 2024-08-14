package objects.game;

class Note extends NoteSprite
{
	public var data:Int;
	public var time:Float;
	public var len:Float;
	public var type:String;
	public var mult:Float;

	var killing:Bool = false;

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
		killing = false;

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
		{
			if (Conductor.time >= time)
			{
				strumline.addNextNote();
				strum.confirm();
				kill();
			}
		}
		else
		{
			if (Conductor.time >= time + 200 && !killing)
			{
				killing = true;
				rgb.r.saturation = .2;
				rgb.g.saturation = .2;
				rgb.b.saturation = .2;
				rgb.set(rgb.r, rgb.g, rgb.b);
				PlayState.instance.miss();
				FlxTween.num(mult, mult * 5, .5, {
					type: ONESHOT,
					onComplete: tween ->
					{
						strumline.addNextNote();
						kill();
					}
				}, num -> mult = num);
			}
		}
	}
}
