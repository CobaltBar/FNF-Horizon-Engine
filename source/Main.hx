package;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
import haxe.CallStack.StackItem;
import haxe.CallStack;
import haxe.Exception;
import lime.app.Application;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;

class Main extends Sprite
{
	public static final modSysVer:Float = 1;
	public static var inputEnabled:Bool = true;
	@:noCompletion public static var _console:Console = null;
	@:noCompletion public static var _showConsole:Bool = false;

	public static var verbose:Bool = false;

	public function new()
	{
		super();

		if (Sys.args().contains('--verbose'))
		{
			#if windows Sys.print('\n'); #end
			verbose = true;
			if (verbose)
				Log.info('Verbose Logging Enabled');
		}

		FlxTransitionableState.skipNextTransIn = true;
		addChild(new FlxSafeGame(1920, 1080, InitState, 90, 60, true));
		addChild(new EngineInfo());

		#if linux Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile('icon.png')); #end

		if (Sys.args().contains('--start-small'))
		{
			Log.info('Starting in 1280x720');
			FlxG.resizeWindow(1280, 720);
			Application.current.window.resize(1280, 720);
			Application.current.window.maximized = false;
			Application.current.window.x += Std.int(Application.current.window.displayMode.width * .5);
			Application.current.window.y += Std.int(Application.current.window.displayMode.height * .5);
		}

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
			Misc.error('Uncaught Error\n$err', true);
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
			Misc.error('FlxGame: create', true, e);

	override function onEnterFrame(_)
		try
		{
			super.onEnterFrame(_);
		}
		catch (e:Exception)
			Misc.error('FlxGame: onEnterFrame', true, e);

	override function update()
		try
		{
			super.update();
		}
		catch (e:Exception)
			Misc.error('FlxGame: update', true, e);

	override function draw()
		try
		{
			super.draw();
		}
		catch (e:Exception)
			Misc.error('FlxGame: draw', true, e);

	override function onFocus(_)
		try
		{
			super.onFocus(_);
		}
		catch (e:Exception)
			Misc.error('FlxGame: onFocus', true, e);

	override function onFocusLost(_)
		try
		{
			super.onFocusLost(_);
		}
		catch (e:Exception)
			Misc.error('FlxGame: onFocusLost', true, e);
}
