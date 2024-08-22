package objects.game.eternal;

import flixel.util.FlxDestroyUtil;

// See NOTE.txt
class Sustain extends TiledSprite
{
	public function new(note:Note)
	{
		super();

		frames = note.frames;
		animation.copyFrom(note.animation);
		animation.play('hold');
		setTail('tail');
		scale = note.scale;
		updateHitbox();
		antialiasing = note.antialiasing;
		cameras = note.cameras;

		shader = note.rgb.shader;
	}

	override function kill():Void
	{
		clipRegion = FlxDestroyUtil.put(clipRegion);
		super.kill();
	}
}
