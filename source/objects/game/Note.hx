package objects.game;

import flixel.addons.display.FlxTiledSprite;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;

class Note extends NoteSprite
{
	public var data:Int;
	public var time:Float;
	public var length:Float;
	public var type:String;
	public var mult:Float;

	public var sustain:SustainSprite;

	static var sustainGroup:FlxTypedSpriteGroup<SustainSprite> = new FlxTypedSpriteGroup<SustainSprite>();

	var sustainOffset:Float = 0;
	var sustaining:Bool = false;

	var strumline:Strumline;
	var strum:StrumNote;

	public function resetNote(json:NoteJSON, line:Strumline):Void
	{
		data = json.data ?? 0;
		time = json.time ?? 0;
		length = json.length ?? 0;
		type = json.type;
		mult = json.mult ?? 1;
		sustainOffset = 0;
		sustaining = false;
		alpha = 1;
		strumline = line;
		strum = strumline.strums.members[data % 4];

		var rgbDat = Settings.data.noteRGB.notes[data % 4];
		rgb.set(rgbDat.base, rgbDat.highlight, rgbDat.outline);
		angle = angleOffset = strum.angleOffset;
		x = strum.x;

		if (length > 0)
		{
			trace(length);
			sustain = sustainGroup.recycle(SustainSprite, () ->
			{
				var s = new SustainSprite(FlxGraphic.fromFrame(Path.sparrow("note", PlayState.mods).getByName("hold")));
				s.antialiasing = Settings.data.antialiasing;
				s.tail.frames = Path.sparrow("note", PlayState.mods);
				s.tail.animation.addByPrefix('idle', "tail");
				s.tail.animation.play('idle');
				s.updateHitbox();
				return s;
			});
			sustain.tiles = Math.ffloor(length / Conductor.stepLength);
			sustain.updateHitbox();
			// sustain.clipRect = new FlxRect(0, 0, sustain.body.frameWidth * sustain.scale.x, sustain.body.frameHeight + sustain.tail.frameHeight);
			// sustain.clipRect = sustain.clipRect;
			sustain.x = strum.x + sustain.width * .5;
		}
	}

	public override function draw()
	{
		super.draw();
		if (sustain != null && sustain.alive)
			sustain.draw();
	}

	public override function destroy()
	{
		if (sustain != null)
			sustain.destroy();

		super.destroy();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sustaining)
			sustainOffset = .45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult;
		else
			y = strum.y - (.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult) - sustainOffset;

		if (strumline.autoHit)
			if (length > 0)
			{
				if (Conductor.time >= time && !sustaining)
				{
					strum.confirm(false);
					sustaining = true;
					// alpha = 0;
				}

				if (Conductor.time >= time + length)
				{
					strum.unConfirm();
					sustaining = false;
					kill();
					strumline.addNextNote();
				}
			}
			else
			{
				if (Conductor.time >= time)
				{
					strum.confirm();
					kill();
					strumline.addNextNote();
				}
			}

		if (sustain != null && sustain.alive)
		{
			sustain.update(elapsed);

			if (Conductor.time >= time + length)
			{
				sustain.kill();
				sustaining = false;
				strum.unConfirm();
				return;
			}

			sustain.y = y;

			/*if (sustain.y < strum.y)
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
			}*/
		}
	}

	public override function kill()
	{
		if (sustain != null)
			sustain.kill();

		super.kill();
	}
}
