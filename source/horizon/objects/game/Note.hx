package horizon.objects.game;

import flixel.math.FlxRect;

@:publicFields
class Note extends NoteSprite
{
	var data:Int;
	var time:Float;
	var length:Float;
	var mult:Float;
	var type:String;

	var parent:StrumNote;
	var strumline:Strumline;
	var sustain:Sustain;

	var timeOffset:Float;
	var sustaining:Bool;
	var hittable:Bool;

	function setup(json:NoteJSON, strumline:Strumline)
	{
		data = json.data ?? 0;
		time = json.time ?? 0;
		length = json.length ?? 0;
		type = json.type;
		mult = json.mult ?? 1;
		timeOffset = 0;
		alpha = 1;
		sustaining = false;
		hittable = visible = true;
		setRGB(Settings.noteRGB[data % Settings.noteRGB.length]);

		angleOffset = NoteSprite.angleOffsets[data % NoteSprite.angleOffsets.length];
		parent = strumline.strums[data % strumline.strums.length];
		this.strumline = strumline;

		if (length > 0)
		{
			sustain = strumline.sustains.recycle(Sustain, () ->
			{
				var spr = new Sustain(this);
				spr.cameras = cameras;
				return spr;
			});
			sustain.clipRegion = FlxRect.get(0, 0, sustain.width, sustain.height);
			sustain.setup(this);
		}
	}

	function hit(unconfirm:Bool = false):Void
	{
		hittable = false;

		if (length > 0)
		{
			parent.confirm(false);
			if (!parent.animation.paused)
				parent.animation.pause();
			timeOffset = Conductor.time - time;
			alpha = 0;
			sustaining = true;
		}
		else
		{
			parent.confirm(unconfirm);
			kill();
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (sustain != null && sustain.exists && sustain.active)
			sustain.update(elapsed);

		if (Conductor.time >= time + length + 350)
		{
			kill();
			strumline.addNextNote();
			if (!strumline.autoHit)
				PlayState.instance.miss();
			return;
		}

		if (sustaining)
		{
			if (Conductor.time >= time + length)
			{
				parent.autoReset = true;
				parent.animation.resume();
				kill();
				return;
			}
			if (!strumline.autoHit)
				if (Lambda.foreach(Settings.keybinds[Constants.notebindNames[data % Constants.notebindNames.length]], key -> !Controls.pressed.contains(key)))
				{
					sustaining = false;
					alpha = sustain.alpha = .6;
					setRGB(NoteSprite.desatColors[data % NoteSprite.desatColors.length]);
					sustain.shader = shader;
				}
		}

		if (strumline.autoHit && Conductor.time >= time && !sustaining)
		{
			hit(true);
			strumline.addNextNote();
		}

		if (sustain != null && sustain.angle != parent.direction - 90)
			sustain.angle = parent.direction - 90;

		var dist = (.45 * (Conductor.time - time - timeOffset) * PlayState.instance.scrollSpeed * mult);
		var posX = parent.x - parent.cosDir * dist;
		var posY = parent.y - parent.sinDir * dist;

		if (sustaining && sustain != null && sustain.exists && sustain.visible)
		{
			sustain.x = posX + (width - sustain.width) * .5;
			sustain.y = posY;
			sustain.clipRegion.y = parent.y - posY;
		}
		else
		{
			x = posX;
			y = posY;
		}
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
			sustain.x = val + (width - sustain.width) * .5;
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
