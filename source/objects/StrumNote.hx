package objects;

import flixel.graphics.frames.FlxFilterFrames;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;

class StrumNote extends NoteSprite
{
	var strumRGB:RGBPalette = new RGBPalette();
	var pressedRGB:RGBPalette = new RGBPalette();
	var confirmSpr:NoteSprite;
	var pressedSpr:NoteSprite;

	public var glowAlphaTarget:Float = 0;
	public var scaleTarget:Float = 1.1;
	public var lerpScale:Bool = true;

	public function new(noteData:Int = 2)
	{
		super(noteData);
		shader = strumRGB.shader;
		strumRGB.set(0x87A3AD, -1, 0);
		rgb.set(Settings.data.noteRGB[noteData].base, Settings.data.noteRGB[noteData].highlight, Settings.data.noteRGB[noteData].outline);
		confirmSpr = new NoteSprite(noteData);
		confirmSpr.targetSpr = this;
		confirmSpr.shader = rgb.shader;
		confirmSpr.blend = ADD;
		confirmSpr.alpha = glowAlphaTarget;
		FlxFilterFrames.fromFrames(confirmSpr.frames, 64, 64, [new BlurFilter(72, 72)]).applyToSprite(confirmSpr, false, true);
		var r = Settings.data.noteRGB[noteData].base;
		r.setRGB(r.red - 75, r.green - 75, r.blue - 75);
		var g = Settings.data.noteRGB[noteData].highlight;
		g.setRGB(g.red - 25, g.green - 25, g.blue - 25);
		var b = Settings.data.noteRGB[noteData].outline;
		b.setRGB(b.red - 50, b.green - 50, b.blue - 50);
		pressedRGB.set(r, g, b);
		pressedSpr = new NoteSprite(noteData);
		pressedSpr.targetSpr = this;
		pressedSpr.shader = pressedRGB.shader;
		pressedSpr.alpha = 0;
	}

	public override function update(elapsed:Float)
	{
		if (confirmSpr.alpha != glowAlphaTarget * alpha)
			confirmSpr.alpha = FlxMath.lerp(confirmSpr.alpha, glowAlphaTarget * alpha,
				FlxMath.bound(elapsed * (glowAlphaTarget * alpha > confirmSpr.alpha ? 40 : 10), 0, 1));

		if (lerpScale)
		{
			if (scale.x != scaleTarget)
			{
				scale.x = FlxMath.lerp(scale.x, scaleTarget, FlxMath.bound(elapsed * 5, 0, 1));
				updateHitbox();
			}
			if (scale.y != scaleTarget)
			{
				scale.y = FlxMath.lerp(scale.y, scaleTarget, FlxMath.bound(elapsed * 5, 0, 1));
				updateHitbox();
			}
		}

		if (pressedSpr.alpha != 0)
			pressedSpr.update(elapsed);
		if (confirmSpr.alpha != 0)
			confirmSpr.update(elapsed);

		super.update(elapsed);
	}

	public override function draw()
	{
		super.draw();
		if (pressedSpr.alpha != 0)
			pressedSpr.draw();
		if (confirmSpr.alpha != 0)
			confirmSpr.draw();
	}

	@:noCompletion override function set_cameras(val:Array<FlxCamera>):Array<FlxCamera>
	{
		confirmSpr.cameras = val;
		pressedSpr.cameras = val;
		return super.set_cameras(val);
	}

	@:noCompletion override function set_angle(val:Float):Float
	{
		confirmSpr.angle = val;
		pressedSpr.angle = val;
		return super.set_angle(val);
	}
}
