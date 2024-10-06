package horizon.objects.game;

class StrumNote extends NoteSprite
{
	public function new(data:Int = 2)
	{
		super(data);
		animation.play('strum');
		rgb = new RGBEffect();
		rgb.r = Settings.noteRGB[data][0];
		rgb.g = Settings.noteRGB[data][1];
		rgb.b = Settings.noteRGB[data][2];
		rgb.enabled = false;
		shader = rgb.shader;
		centerOffsets();
		updateHitbox();
	}
}
