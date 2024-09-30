package horizon.objects.game;

class NoteSprite extends FlxSprite
{
	public var rgb:RGBEffect;

	public function new(data:Int = 2)
	{
		super();
		frames = Path.sparrow('note', PlayState.mods);
		animation.addByNames('note', ['note'], 24);
		animation.addByNames('hold', ['hold'], 24);
		animation.addByNames('tail', ['tail'], 24);
		animation.addByNames('confirm', ['confirm'], 24);
		animation.play('note', true);
		updateHitbox();

		rgb = RGBEffect.get(Settings.noteRGB.strum[data]);
		shader = rgb.shader;
	}
}
