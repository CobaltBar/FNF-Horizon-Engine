package horizon.objects.game;

import flixel.util.FlxDestroyUtil;

// Some code is taken from https://github.com/Sword352/FnF-Eternal/blob/dev/source/funkin/gameplay/notes/Sustain.hx#L52
class Sustain extends TiledSprite
{
	public function new(note:Note)
	{
		super();
		active = false;
		frames = note.frames;
		animation.copyFrom(note.animation);
		animation.play('hold');
		setTail('tail');
	}

	public function setup(note:Note)
	{
		scale = note.scale;
		shader = note.shader;
		updateHitbox();
		height = note.length * PlayState.instance.scrollSpeed * .45;
		offset.y = -note.height * .5;
	}

	override function kill():Void
	{
		clipRegion = FlxDestroyUtil.put(clipRegion);
		super.kill();
	}
}
