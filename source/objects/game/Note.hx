package objects.game;

import flixel.addons.display.FlxTiledSprite;
import flixel.math.FlxRect;

class Note extends NoteSprite
{
	public var data:Int;
	public var time:Float;
	public var length:Float;
	public var type:String;
	public var mult:Float;

	public var sustain:FlxTiledSprite;
	public var tail:FlxSprite;

	var sustainOffset:Float = 0;
	var sustaining:Bool = false;

	var strumline:Strumline;

	public function resetNote(json:NoteJSON, strum:Strumline):Void
	{
		data = json.data ?? 0;
		time = json.time ?? 0;
		length = json.length ?? 0;
		type = json.type;
		mult = json.mult ?? 1;
		sustainOffset = 0;
		sustaining = false;
		alpha = 1;
		strumline = strum;

		var rgbDat = Settings.data.noteRGB.notes[data % 4];
		rgb.set(rgbDat.base, rgbDat.highlight, rgbDat.outline);
		angle = angleOffset = strum.strums.members[data % 4].angleOffset;
		x = strum.strums.members[data % 4].x;

		if (length > 0)
		{
			sustain = new FlxTiledSprite(null, 50, 44 * (Math.floor(length / Conductor.stepLength) + 1),
				false).loadFrame(Path.sparrow('note', PlayState.mods).getByName('hold'));
			sustain.animation.addByPrefix('idle', 'hold', 24, true);
			sustain.animation.play('idle', true);
			sustain.shader = rgb.shader;
			sustain.antialiasing = Settings.data.antialiasing;
			sustain.moves = false;
			sustain.clipRect = new FlxRect(0, 0, sustain.width, sustain.height);
			sustain.clipRect = sustain.clipRect;
			sustain.offset.y = -height * .5;
			sustain.x = x + (width - sustain.width) * .5;

			tail = Create.sparrow(0, 0, Path.sparrow('note', PlayState.mods));
			tail.animation.addByPrefix('idle', 'tail', 24, true);
			tail.animation.play('idle', true);
			tail.shader = rgb.shader;
			tail.antialiasing = Settings.data.antialiasing;
			tail.moves = false;
			tail.clipRect = new FlxRect(0, 0, tail.width, tail.height);
			tail.clipRect = tail.clipRect;
			tail.offset.y = -height * .5 + 1;
			tail.x = x + (width - sustain.width) * .5;
		}
	}

	public function hit():Void
	{
		if (sustain != null && sustain.exists)
		{
			sustaining = true;
			alpha = 0;
		}
		else
		{
			kill();
			strumline.addNextNote();
		}
	}

	public function move(strum:StrumNote, autoHit:Bool = false):Void
	{
		if (sustaining)
			sustainOffset = 0.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult;
		else
			y = strum.y - (0.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult) - sustainOffset;

		if (autoHit)
			if (Conductor.time >= time)
				hit();

		if (sustain != null)
		{
			sustain.y = y - sustainOffset;
			tail.y = y + sustain.height - sustainOffset;

			if (sustain.y < strum.y)
			{
				sustain.clipRect.y = strum.y - sustain.y;
				sustain.clipRect = sustain.clipRect;
			}
			else
			{
				if (sustain.clipRect.y != 0)
				{
					sustain.clipRect.y = 0;
					sustain.clipRect = sustain.clipRect;
				}
			}

			if (tail.y < strum.y)
			{
				tail.clipRect.y = strum.y - tail.y;
				tail.clipRect = tail.clipRect;
			}
			else
			{
				if (tail.clipRect.y != 0)
				{
					tail.clipRect.y = 0;
					tail.clipRect = tail.clipRect;
				}
			}

			if (tail.y < strum.y - tail.height - 50)
			{
				sustain.destroy();
				sustain = null;
				tail.destroy();
				tail = null;
				sustaining = false;
			}
		}
	}

	public override function draw()
	{
		if (sustain != null)
		{
			sustain.draw();
			tail.draw();
		}
		super.draw();
	}

	public override function destroy()
	{
		if (sustain != null)
		{
			sustain.destroy();
			sustain = null;
			tail.destroy();
			tail = null;
		}
		super.destroy();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (sustain != null)
		{
			sustain.update(elapsed);
			tail.update(elapsed);
		}
	}

	public override function kill()
	{
		if (sustain != null)
		{
			sustain.destroy();
			sustain = null;
			tail.destroy();
			tail = null;
		}
		super.kill();
	}
}
