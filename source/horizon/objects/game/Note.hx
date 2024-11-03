package horizon.objects.game;

@:publicFields
class Note extends NoteSprite
{
	var data:Int;
	var time:Float;
	var length:Float;
	var mult:Float;
	var type:String;

	function resetNote(json:NoteJSON)
	{
		data = json.data ?? 0;
		time = json.time ?? 0;
		length = json.length ?? 0;
		type = json.type;
		mult = json.mult ?? 1;
		alpha = 1;
		visible = true;
		rgb = RGBEffect.get(Settings.noteRGB[data % Settings.noteRGB.length], 1);
		shader = rgb.shader;

		angleOffset = NoteSprite.angleOffsets[data % NoteSprite.angleOffsets.length];
	}

	function hit(strum:StrumNote, unconfirm:Bool = true):Void
	{
		strum.confirm(unconfirm);
		kill();
	}

	function move(strum:StrumNote):Void
	{
		var dist = (.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult);

		y = strum.y - strum.sinDir * dist;
		x = strum.x - strum.cosDir * dist;
	}
}
