package;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import haxe.CallStack;
import haxe.Exception;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.ErrorEvent;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;

class Main extends Sprite
{
	public function new()
	{
		super();

		FlxTransitionableState.skipNextTransIn = true;
		addChild(new FlxModdedGame(0, 0, InitState, 60, 60, true));
		addChild(new EngineInfo(10, 10, 0xFFFFFF));

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e:UncaughtErrorEvent) ->
		{
			var cs:Array<StackItem> = CallStack.exceptionStack(true);
			var err = "";

			for (item in cs)
				switch (item)
				{
					case FilePos(s, file, line, column):
						err += '$file: Line: $line\n';
					default: trace(item);
				}
			ErrorState.error(null, "Uncaught Error", true);
		});
	}
}

// Referenced from Super Engine lmao
class FlxModdedGame extends FlxGame
{
	override function create(_:Event)
		try
		{
			super.create(_);
		}
		catch (e:Exception)
			ErrorState.error(e, "FlxGame: create", true);

	override function onEnterFrame(_)
		try
		{
			super.onEnterFrame(_);
		}
		catch (e:Exception)
			ErrorState.error(e, "FlxGame: onEnterFrame", true);

	override function update()
		try
		{
			super.update();
		}
		catch (e:Exception)
			ErrorState.error(e, "FlxGame: update", true);

	override function draw()
		try
		{
			super.draw();
		}
		catch (e:Exception)
			ErrorState.error(e, "FlxGame: draw", true);

	override function onFocus(_)
		try
		{
			super.onFocus(_);
		}
		catch (e:Exception)
			ErrorState.error(e, "FlxGame: onFocus", true);

	override function onFocusLost(_)
		try
		{
			super.onFocusLost(_);
		}
		catch (e:Exception)
			ErrorState.error(e, "FlxGame: onFocusLost", true);
}
