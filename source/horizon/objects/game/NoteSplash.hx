package horizon.objects.game;

class NoteSplash extends FlxSprite
{
	var animNames:Array<String>;

	public function new()
	{
		super();
		frames = Path.atlas('note_splash', PlayState.mods);
		// TODO change this when fixed
		// animation.addByPrefix('splash1', 'splash1', 24, false);
		animation.addByPrefix('splash2', 'splash2', 24, false);
		updateHitbox();
		animNames = animation.getNameList();
		animation.onFinish.add(_ -> kill());
	}

	public function splash():Void
	{
		animation.play(FlxG.random.getObject(animNames));
	}
}
