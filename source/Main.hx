package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import haxe.CallStack;
import haxe.Exception;
import horizon.backend.Constants;
import horizon.objects.EngineInfo;
import horizon.states.InitState;
import horizon.util.Log;
import horizon.util.Util;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;

using StringTools;

#if (cpp && linux)
// I stole this from Psych
@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('#define GAMEMODE_AUTO')
#end
@:publicFields
class Main extends Sprite
{
	@:noCompletion static var fps:EngineInfo;

	function new()
	{
		super();

		if (Sys.args().contains('--verbose'))
		{
			#if windows Sys.print('\n'); #end
			Constants.verbose = Constants.debugDisplay = true;
			if (Constants.verbose)
				Log.info('Verbose Logging Enabled');
		}

		#if linux Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile('icon.png')); #end
		FlxTransitionableState.skipNextTransIn = true;

		addChild(new FlxSafeGame(1280, 720, InitState, 120, 120, true));
		addChild(fps = new EngineInfo());

		// shader coords fix (stolen from PsychEngine)
		FlxG.signals.gameResized.add((w, h) ->
		{
			if (FlxG.cameras != null)
				for (cam in FlxG.cameras.list)
					if (cam != null && cam.filters != null)
					{
						cam.flashSprite.__cacheBitmap = null;
						cam.flashSprite.__cacheBitmapData = null;
					};

			if (FlxG.game != null)
			{
				FlxG.game.__cacheBitmap = null;
				FlxG.game.__cacheBitmapData = null;
			}
		});

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, (e:UncaughtErrorEvent) ->
		{
			var cs:Array<StackItem> = CallStack.exceptionStack(true);
			var err = '';

			for (item in cs)
				switch (item)
				{
					case FilePos(s, file, line, column):
						err += '$file: Line: $line\n';
					default: Log.error(item);
				}
			Util.error('Uncaught Error\n$err', true);
		});
	}
}

// Referenced from Super Engine lmao
class FlxSafeGame extends FlxGame
{
	override function create(_:Event)
		try
		{
			super.create(_);
		}
		catch (e:Exception)
			Util.error('FlxGame: create', true, e);

	override function onEnterFrame(_)
		try
		{
			super.onEnterFrame(_);
		}
		catch (e:Exception)
			Util.error('FlxGame: onEnterFrame', true, e);

	override function update()
		try
		{
			super.update();
		}
		catch (e:Exception)
			Util.error('FlxGame: update', true, e);

	override function draw()
		try
		{
			super.draw();
		}
		catch (e:Exception)
			Util.error('FlxGame: draw', true, e);

	override function onFocus(_)
		try
		{
			super.onFocus(_);
		}
		catch (e:Exception)
			Util.error('FlxGame: onFocus', true, e);

	override function onFocusLost(_)
		try
		{
			super.onFocusLost(_);
		}
		catch (e:Exception)
			Util.error('FlxGame: onFocusLost', true, e);
}
