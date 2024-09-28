package horizon.objects;

class MenuCharacter extends FlxAnimSprite
{
	var leftAndRight:Bool;

	public function new(jsonPath:String, ?mods:Array<Mod>)
	{
		super(jsonPath, mods);

		leftAndRight = animation.exists('danceLeft') && animation.exists('danceRight');
	}

	public function bop():Void
		if (leftAndRight)
			if (Conductor.curBeat % 2 == 0)
				playAnim('danceLeft', true);
			else
				playAnim('danceRight', true);
		else
			playAnim('idle', true);
}
