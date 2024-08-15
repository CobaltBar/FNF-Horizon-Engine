package objects.game;

import flixel.graphics.frames.FlxFilterFrames;
import openfl.filters.BlurFilter;

class StrumNote extends NoteSprite
{
	var strumRGB:RGBPalette = new RGBPalette();
	var pressedRGB:RGBPalette = new RGBPalette();

	var confirmSpr:NoteSprite;
	var pressedSpr:NoteSprite;

	var confirmAlphaTarget:Float = 0;
	var pressedAlphaTarget:Float = 0;

	var targetScaleX:Float = 1.0;
	var targetScaleY:Float = 1.0;
	var restoreScaleX:Float = 1.0;
	var restoreScaleY:Float = 1.0;
	var lerpMultiplier:Float = 25;

	var playingAnim:Bool = false;

	public function new(noteData:Int = 2)
	{
		super(noteData);
		shader = strumRGB.shader;
		strumRGB.set(0x87A3AD, -1, 0);

		var noteRGB = Settings.data.noteRGB.notes[noteData];
		rgb.set(noteRGB.base, noteRGB.highlight, noteRGB.outline);

		confirmSpr = new NoteSprite(noteData);
		confirmSpr.targetSpr = this;
		confirmSpr.copyScale = true;
		confirmSpr.shader = rgb.shader;
		confirmSpr.blend = ADD;
		confirmSpr.alpha = 0.0001;

		confirmSpr.setFrames(FlxFilterFrames.fromFrames(confirmSpr.frames, 64, 64, [new BlurFilter(72, 72)]));
		confirmSpr.updateHitbox();
		confirmSpr.offset.x = (confirmSpr.width - width) * .5;
		confirmSpr.offset.y = (confirmSpr.height - height) * .5;

		var pressRGB = Settings.data.noteRGB.press[noteData];
		pressedRGB.set(pressRGB.base, pressRGB.highlight, pressRGB.outline);
		pressedSpr = new NoteSprite(noteData);
		pressedSpr.targetSpr = this;
		pressedSpr.copyScale = true;
		pressedSpr.shader = pressedRGB.shader;
		pressedSpr.alpha = 0.0001;
	}

	public override function update(elapsed:Float)
	{
		if (scale.x != targetScaleX || scale.y != targetScaleY)
			scale.set(FlxMath.lerp(scale.x, targetScaleX, FlxMath.bound(elapsed * lerpMultiplier, 0, 1)),
				FlxMath.lerp(scale.y, targetScaleY, FlxMath.bound(elapsed * lerpMultiplier, 0, 1)));

		if (confirmSpr.alpha != confirmAlphaTarget * alpha)
			confirmSpr.alpha = FlxMath.lerp(confirmSpr.alpha, confirmAlphaTarget * alpha, FlxMath.bound(elapsed * lerpMultiplier, 0, 1));

		if (pressedSpr.alpha != pressedAlphaTarget * alpha)
			pressedSpr.alpha = FlxMath.lerp(pressedSpr.alpha, pressedAlphaTarget * alpha, FlxMath.bound(elapsed * lerpMultiplier, 0, 1));

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

	public function confirm(unconfirm:Bool = true):Void
	{
		if (playingAnim)
			return;
		playingAnim = true;
		confirmAlphaTarget = confirmSpr.alpha = 1;
		targetScaleX *= 1.05;
		targetScaleY *= 1.05;
		lerpMultiplier = 25;
		scale.set(scale.x * 1.15, scale.y * 1.15);
		if (unconfirm)
			FlxTimer.wait(.15, () -> unConfirm());
	}

	public function press(unconfirm:Bool = true):Void
	{
		if (playingAnim)
			return;
		playingAnim = true;
		pressedAlphaTarget = pressedSpr.alpha = 1;
		targetScaleX *= .95;
		targetScaleY *= .95;
		lerpMultiplier = 20;
		scale.set(scale.x * .85, scale.y * .85);
		if (unconfirm)
			FlxTimer.wait(.15, () -> unPress());
	}

	public function unConfirm():Void
	{
		playingAnim = false;
		confirmAlphaTarget = 0;
		lerpMultiplier = 10;
		targetScaleX = restoreScaleX;
		targetScaleY = restoreScaleY;
	}

	public function unPress():Void
	{
		playingAnim = false;
		pressedAlphaTarget = 0;
		lerpMultiplier = 10;
		targetScaleX = restoreScaleX;
		targetScaleY = restoreScaleY;
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
