package horizon.objects;

class MenuCharacter extends FlxAnimSprite
{
	public var posX:Float = 0;
	public var posY:Float = 0;

	var leftAndRight:Bool;

	public function new(jsonPath:String, ?mods:Array<Mod>)
	{
		var json:AnimatedChracterData = Path.json(jsonPath, mods);
		posX = json.position[0] ?? 0;
		posY = json.position[1] ?? 0;
		super(posX, posY, jsonPath, mods, json);

		// TODO change to enum abstract(String)
		leftAndRight = animation.exists('danceLeft') && animation.exists('danceRight');
	}

	public function bop():Void
		if (animation.curAnim?.name != 'confirm')
			if (leftAndRight)
				if (Conductor.curBeat % 2 == 0)
					playAnim('danceLeft', true);
				else
					playAnim('danceRight', true);
			else
				playAnim('idle', true);
}
