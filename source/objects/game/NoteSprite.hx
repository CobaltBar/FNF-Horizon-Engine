package objects.game;

class NoteSprite extends FlxCopySprite
{
	public var rgb:RGBPalette = new RGBPalette();

	public function new(noteData:Int = 2)
	{
		super();
		frames = Path.sparrow('note', PlayState.mods);
		animation.addByNames('idle', ['idle'], 24);
		animation.addByNames('hold', ['hold'], 24);
		animation.addByNames('tail', ['tail'], 24);
		animation.play('idle', true);
		updateHitbox();
		antialiasing = Settings.data.antialiasing;
		moves = false;

		shader = rgb.shader;
		rgb.set(0x717171, -0x000001, 0x333333);
	}
}
