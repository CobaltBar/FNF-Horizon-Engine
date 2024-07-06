package objects.game;

import flixel.addons.display.FlxTiledSprite;

class Note extends NoteSprite
{
	public var data:Int = 0;
	public var time:Float = 0;
	public var length:Float = 0;
	public var type:String;
	public var mult:Float = 1;

	public var sustain:FlxTiledSprite;

	var shouldMove:Bool = true;
	var sustainOffset:Float = 0;

	public function resetNote(?json:NoteJSON, ?strum:Strumline):Void
	{
		data = json?.data ?? 0;
		time = json?.time ?? 100;
		length = json?.length ?? 0;
		type = json?.type;
		mult = json?.mult ?? 1;

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
			sustain.x = x + strum.x + sustain.width;
		}
	}

	public override function draw()
	{
		super.draw();
		if (sustain != null)
			sustain.draw();
	}

	public override function destroy()
	{
		if (sustain != null)
			sustain.destroy();
		super.destroy();
	}

	public override function kill()
	{
		if (sustain != null)
			sustain.destroy();
		super.kill();
	}

	public function move(strumNote:StrumNote):Void
	{
		if (shouldMove)
			y = strumNote.y - (0.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult);
		else
			sustainOffset = (strumNote.y - (0.45 * (Conductor.time - time) * PlayState.instance.scrollSpeed * mult)) - y;
		if (sustain != null)
		{
			sustain.y = y + sustainOffset - (height * .25);
			if (sustain.y < strumNote.y - sustain.height && !shouldMove)
				kill();
		}
	}

	public function hit():Void
	{
		if (sustain == null)
			kill();
		else
		{
			shouldMove = false;
			alpha = 0;
		}
	}
}
