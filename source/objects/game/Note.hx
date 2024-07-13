package objects.game;

import flixel.addons.display.FlxTiledSprite;
import flixel.math.FlxRect;

class Note extends NoteSprite
{
	public var data:Int = 0;
	public var time:Float = 0;
	public var length:Float = 0;
	public var type:String;
	public var mult:Float = 1;

	public var sustain:FlxTiledSprite;
	public var tail:FlxSprite;

	var shouldMove:Bool = true;
	var sustainOffset:Float = 0;

	public var isHit:Bool = false;

	public function resetNote(?json:NoteJSON, ?strum:Strumline):Void
	{
		data = json?.data ?? 0;
		time = json?.time ?? 100;
		length = json?.length ?? 0;
		type = json?.type;
		mult = json?.mult ?? 1;
		isHit = false;
		shouldMove = true;

		if (sustain != null)
		{
			sustain.destroy();
			tail.destroy();
		}

		if (strum != null)
		{
			rgb.set(Settings.data.noteRGB.notes[data % 4].base, Settings.data.noteRGB.notes[data % 4].highlight, Settings.data.noteRGB.notes[data % 4].outline);
			angle = angleOffset = strum.strums.members[data % 4].angleOffset;
			x = ((strum.strums.members[data % 4].width * data % 4) + 5) - 20;
		}

		var flooredLength = Math.floor(length / Conductor.stepLength);
		if (flooredLength > 0)
		{
			sustain = new FlxTiledSprite(null, 50, 43 * (flooredLength + 1), false).loadFrame(Path.sparrow('note', PlayState.mods).getByName('hold'));
			sustain.animation.addByPrefix('idle', 'hold', 24, true);
			sustain.animation.play('idle', true);
			sustain.shader = rgb.shader;
			sustain.offset.y = -200;
			sustain.updateHitbox();
			sustain.antialiasing = Settings.data.antialiasing;
			sustain.moves = false;
			sustain.clipRect = new FlxRect(0, 0, sustain.width, sustain.height);
			sustain.clipRect = sustain.clipRect;
			sustain.x = x + strum.x + sustain.width * .75;

			tail = Create.sparrow(0, 0, Path.sparrow('note', PlayState.mods));
			tail.animation.addByPrefix('idle', 'tail', 24, true);
			tail.animation.play('idle', true);
			tail.shader = rgb.shader;
			tail.offset.y = -201;
			tail.updateHitbox();
			tail.antialiasing = Settings.data.antialiasing;
			tail.moves = false;
			tail.clipRect = new FlxRect(0, 0, tail.width, tail.height);
			tail.clipRect = tail.clipRect;
			tail.x = x + strum.x + tail.width * 1.25;
		}
	}

	public function move(strumNote:StrumNote, unconfirm:Bool = false):Void
	{
		if (shouldMove)
			y = strumNote.y - (0.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult) - sustainOffset;
		else
		{
			sustainOffset = (strumNote.y - (0.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult)) - y;
			if (sustain != null)
			{
				if (sustain.y < strumNote.y - 50)
				{
					sustain.clipRect.y = strumNote.y - 50 - sustain.y;
					sustain.clipRect = sustain.clipRect;
				}
				if (tail.y < strumNote.y + strumNote.height - 50)
				{
					tail.clipRect.y = (strumNote.y + strumNote.height) - 50 - (tail.y + tail.height * .6);
					tail.clipRect = tail.clipRect;
				}

				if (Conductor.time >= time + length && !shouldMove)
				{
					kill();
					if (unconfirm)
						strumNote.unConfirm();
				}
			}
		}
		if (sustain != null)
		{
			sustain.y = y + sustainOffset;
			tail.y = sustain.y + sustain.height + tail.height * 2;
		}
	}

	public function hit():Void
	{
		isHit = true;
		if (sustain == null)
			kill();
		else
		{
			shouldMove = false;
			alpha = 0;
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
			tail.destroy();
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
			sustain.kill();
			tail.kill();
		}
		super.kill();
	}

	public override function revive()
	{
		if (sustain != null)
		{
			sustain.revive();
			tail.revive();
		}
		super.revive();
	}
}
