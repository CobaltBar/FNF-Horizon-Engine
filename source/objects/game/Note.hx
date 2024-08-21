package objects.game;

import flixel.math.FlxRect;

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

	var sustain:Sustain;
	var sustaining = false;

	public function resetNote(json:NoteJSON, line:Strumline):Void
	{
		data = json.data ?? 0;
		time = json.time ?? 0;
		len = json.length ?? 0;
		type = json.type;
		mult = json.mult ?? 1;
		strumline = line;
		strum = strumline.strums.members[data % 4];
		killing = sustaining = false;

		x = strum.x;
		var rgbDat = Settings.data.noteRGB.notes[data % 4];
		rgb.set(rgbDat.base, rgbDat.highlight, rgbDat.outline);
		angle = angleOffset = strum.angleOffset;

		if (len > 0)
		{
			sustain = new Sustain(this);
			sustain.height = len * PlayState.instance.scrollSpeed * .45;
			sustain.offset.y = -height * .5;
			sustain.x = x + (width - sustain.width) * .5;
			sustain.clipRegion = new FlxRect(0, 0, sustain.width, sustain.height);
		}

		visible = true;
	}

	public override function update(elapsed:Float):Void
	{
		y = strum.y - (.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult);

		if (len > 0 && sustain != null)
		{
			sustain.update(elapsed);
			sustain.y = y;
			if (sustain.y < strum.y)
				sustain.clipRegion.y = strum.y - sustain.y;
		}

		super.update(elapsed);

		if (strumline.autoHit)
		{
			if (len > 0)
			{
				if (Conductor.time >= time && !sustaining)
				{
					strum.confirm(false);
					visible = false;
					sustaining = true;
				}

				if (Conductor.time >= time + len)
				{
					strumline.addNextNote();
					strum.unConfirm();
					kill();
				}
			}
			else
			{
				if (Conductor.time >= time)
				{
					strum.confirm();
					strumline.addNextNote();
					strum.confirm();
					kill();
				}
			}
		}
		else
		{
			if (Conductor.time >= time + len + 200 && !killing)
			{
				killing = true;
				rgb.r.saturation = .2;
				rgb.g.saturation = .2;
				rgb.b.saturation = .2;
				rgb.set(rgb.r, rgb.g, rgb.b);
				PlayState.instance.miss();
				FlxTween.num(mult, mult * 3, .5, {
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

	@:noCompletion override function draw()
	{
		if (sustain != null && len > 0)
			sustain.draw();
		super.draw();
	}

	@:noCompletion override function destroy()
	{
		if (sustain != null && len > 0)
			sustain.destroy();
		super.destroy();
	}

	@:noCompletion override function kill()
	{
		if (sustain != null && len > 0)
			sustain.kill();
		super.kill();
	}
}
