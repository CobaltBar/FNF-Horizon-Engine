package horizon.objects.game;

@:publicFields
class Note extends NoteSprite
{
	var data:Int;
	var time:Float;
	var length:Float;
	var mult:Float;
	var type:String;

	var parent:StrumNote;
	var sustain:Sustain;

	/*
		ig i'll leave the todo here

		- repack note assets again WITHOUT rotation this time
		- figure out why the tiles are disappearing
		- hold + clipping logic
		- input? but how?
	 */
	function setup(json:NoteJSON, strumline:Strumline)
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
		parent = strumline.strums[data % strumline.strums.length];

		if (length > 0)
		{
			sustain = strumline.sustains.recycle(Sustain, () -> new Sustain(this));
			sustain.setup(this);
		}
	}

	function hit(unconfirm:Bool = true):Void
	{
		parent.confirm(unconfirm);
		kill();
	}

	function move():Void
	{
		var dist = (.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult);

		x = parent.x - parent.cosDir * dist;
		y = parent.y - parent.sinDir * dist;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (sustain != null && sustain.exists && sustain.active)
			sustain.update(elapsed);
	}

	override function draw()
	{
		super.draw();
		if (sustain != null && sustain.exists && sustain.visible)
			sustain.draw();
	}

	@:noCompletion override function set_x(val:Float):Float
	{
		if (sustain != null)
			sustain.x = val;
		return super.set_x(val);
	}

	@:noCompletion override function set_y(val:Float):Float
	{
		if (sustain != null)
			sustain.y = val;
		return super.set_y(val);
	}

	override function kill()
	{
		if (sustain != null)
		{
			sustain.kill();
			sustain = null;
		}
		super.kill();
	}
}
