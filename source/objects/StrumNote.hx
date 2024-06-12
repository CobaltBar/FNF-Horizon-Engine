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

	var confirmAlphaTarget:Float = 0;
	var pressedAlphaTarget:Float = 0;

	public var targetScaleX:Float = 1.1;
	public var targetScaleY:Float = 1.1;

	public function new(noteData:Int = 2)
	{
		super(noteData);
		shader = strumRGB.shader;
		strumRGB.set(0x87A3AD, -1, 0);
		rgb.set(Settings.data.noteRGB[noteData].base, Settings.data.noteRGB[noteData].highlight, Settings.data.noteRGB[noteData].outline);

		confirmSpr = new NoteSprite(noteData);
		confirmSpr.targetSpr = this;
		confirmSpr.copyScale = true;
		confirmSpr.shader = rgb.shader;
		confirmSpr.blend = ADD;
		confirmSpr.alpha = 0;

		FlxFilterFrames.fromFrames(confirmSpr.frames, 64, 64, [new BlurFilter(72, 72)]).applyToSprite(confirmSpr, false, true);

		var r = Settings.data.noteRGB[noteData].base;
		r.setRGB(r.red - 50, r.green - 50, r.blue - 75);
		var g = Settings.data.noteRGB[noteData].highlight;
		g.setRGB(g.red - 50, g.green - 50, g.blue - 75);
		var b = Settings.data.noteRGB[noteData].outline;
		b.setRGB(b.red - 50, b.green - 50, b.blue - 75);
		pressedRGB.set(r, g, b);

		pressedSpr = new NoteSprite(noteData);
		pressedSpr.targetSpr = this;
		pressedSpr.copyScale = true;
		pressedSpr.shader = pressedRGB.shader;
		pressedSpr.alpha = 0;
	}

	public override function update(elapsed:Float)
	{
		if (scale.x != targetScaleX || scale.y != targetScaleY)
			scale.set(FlxMath.lerp(scale.x, targetScaleX, FlxMath.bound(elapsed * 10, 0, 1)),
				FlxMath.lerp(scale.y, targetScaleY, FlxMath.bound(elapsed * 10, 0, 1)));

		if (confirmSpr.alpha != confirmAlphaTarget * alpha)
			confirmSpr.alpha = FlxMath.lerp(confirmSpr.alpha, confirmAlphaTarget * alpha, FlxMath.bound(elapsed * 10, 0, 1));

		if (pressedSpr.alpha != pressedAlphaTarget * alpha)
			pressedSpr.alpha = FlxMath.lerp(pressedSpr.alpha, pressedAlphaTarget * alpha, FlxMath.bound(elapsed * 10, 0, 1));

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

	@:keep public inline function confirm(unconfirm:Bool = true):Void
	{
		scale.set(targetScaleX * 1.1, targetScaleY * 1.1);

		confirmAlphaTarget = confirmSpr.alpha = 1;
		if (unconfirm)
			FlxTimer.wait(.1, () -> confirmAlphaTarget = 0);
	}

	@:keep public inline function press(unconfirm:Bool = true):Void
	{
		scale.set(targetScaleX * .9, targetScaleY * .9);
		pressedAlphaTarget = pressedSpr.alpha = 1;
		if (unconfirm)
			FlxTimer.wait(.1, () -> pressedAlphaTarget = 0);
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
