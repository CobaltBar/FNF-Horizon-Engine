package;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import openfl.display.Sprite;
import states.TitleState;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxTransitionableState.skipNextTransIn = true;
		addChild(new FlxGame(0, 0, TitleState));
	}
}
