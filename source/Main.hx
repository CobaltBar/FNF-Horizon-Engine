package;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.UncaughtErrorEvent;
import states.TitleState;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxTransitionableState.skipNextTransIn = true;
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e:UncaughtErrorEvent) ->
		{ // based off of the PsychEngine crash handler by sqirra-sng
			var callstack:Array<StackItem> = CallStack.exceptionStack(true);
			var errorMessage = "";

			for (item in callstack)
			{
				switch (item)
				{
					case FilePos(s, file, line, column):
						errorMessage += file + " (line " + line + ")\n";
					default: trace(item);
				}
			}

			trace(errorMessage);
			Application.current.window.alert(errorMessage, "Error!");
		});
		addChild(new FlxGame(0, 0, TitleState));
	}
}
