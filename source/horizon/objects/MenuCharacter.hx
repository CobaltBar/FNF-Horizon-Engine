package horizon.objects;

class MenuCharacter extends FlxAnimSprite
{
	var bop:Bool;

	public function new(jsonPath:String)
	{
		super(jsonPath);

		bop = animation.exists('danceLeft') && animation.exists('danceRight');
	}

	public function dance():Void
		if (bop)
			if (Conductor.curBeat % 2 == 0)
				playAnim('danceLeft');
			else
				playAnim('danceRight');
		else
			playAnim('idle');
}
