package horizon.objects.game;

import flixel.math.FlxRect;

@:publicFields
class Note extends NoteSprite
{
	var data:Int;
	var time:Float;
	var length(default, set):Float;
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
			sustain = strumline.sustains.recycle(Sustain, createSustain.bind(this));
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

			length += (time - Conductor.time);
			time = Conductor.time;
			alpha = 0;
			sustaining = true;
		}
		else
		{
			parent.confirm(unconfirm);

			if (Math.abs(Conductor.time - time) > Settings.hitWindows[1] + PlayerInput.safeMS)
			{
				PlayState.instance.miss();
				desaturate();
			}
			else
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
			if (!strumline.autoHit && hittable)
				PlayState.instance.miss();
			return;
		}

		if (sustaining)
		{
			PlayState.instance.score += Std.int(250 * elapsed);
			if (Conductor.time >= time + length)
			{
				parent.autoReset = true;
				parent.animation.resume();
				kill();
				return;
			}
			if (!strumline.autoHit)
				if (Settings.keybinds[Constants.notebindNames[data % Constants.notebindNames.length]].foreach(key -> !Controls.pressed.contains(key)))
					kill();
		}

		if (strumline.autoHit && Conductor.time >= time && !sustaining)
			hit(true);

		if (sustain != null && sustain.angle != parent.direction - 90)
			sustain.angle = parent.direction - 90;

		// TODO precalculate scrollSpeed * .45
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

	function desaturate():Void
	{
		alpha = .6;
		setRGB(NoteSprite.desatColors[data % NoteSprite.desatColors.length]);
		if (sustain != null)
		{
			sustain.shader = shader;
			sustain.alpha = .6;
		}
	}

	override function draw()
	{
		if (sustain != null && sustain.exists && sustain.visible)
			sustain.draw();
		super.draw();
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

	// TODO the precalculated scrollSpeed * .45 here
	@:noCompletion function set_length(val:Float):Float
	{
		if (sustain != null)
			sustain.height = val * PlayState.instance.scrollSpeed * .45;
		return length = val;
	}

	override function kill()
	{
		strumline.addNextNote();
		if (sustain != null)
		{
			sustain.kill();
			sustain = null;
		}
		super.kill();
	}

	static function createSustain(note:Note)
	{
		var spr = new Sustain(note);
		spr.cameras = note.cameras;
		return spr;
	}
}
