package;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import haxe.CallStack;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.ErrorEvent;
import openfl.events.UncaughtErrorEvent;

class Main extends Sprite
{
	public function new()
	{
		super();

		FlxTransitionableState.skipNextTransIn = true;
		addChild(new FlxGame(0, 0, InitState, 60, 60, true));
		addChild(new EngineInfo(10, 10, 0xFFFFFF));
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e:UncaughtErrorEvent) ->
		{
			var cs:Array<StackItem> = CallStack.exceptionStack(true);
			var err = "";

			for (item in cs)
				switch (item)
				{
					case FilePos(s, file, line, column):
						err += '$s File: $file Line: $line Column: $column\n';
					default: Sys.println(item);
				}
			Application.current.window.alert(err, "Crash!");
			Sys.exit(1);
		});
	}
}
