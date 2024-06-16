package;

import flixel.FlxGame;
import flixel.addons.transition.FlxTransitionableState;
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
	public static var horizonVer(get, null):String;
	@:noCompletion public static var verboseLogging:Bool = false;

	public function new()
	{
		super();

		if (Sys.args().contains('--verbose'))
		{
			#if windows Sys.println(''); #end // because my console was being goofy
			verboseLogging = true;
			Log.info('Verbose Logging Enabled');
		}

		FlxTransitionableState.skipNextTransIn = true;
		addChild(new FlxSafeGame(1920, 1080, InitState, 90, 60, true));
		addChild(new EngineInfo(10, 10, 0xFFFFFFFF));

		#if linux Lib.current.stage.window.setIcon(lime.graphics.Image.fromFile('icon.png')); #end

		if (Sys.args().contains('--start-small'))
		{
			#if windows Sys.println(''); #end // because my console was being goofy
			Log.info('Starting in 1280x720');
			FlxG.resizeWindow(1280, 720);
			Application.current.window.resize(1280, 720);
			Application.current.window.maximized = false;
		}

		// shader coords fix (stolen from PsychEngine)
		FlxG.signals.gameResized.add(function(w, h)
		{
			if (FlxG.cameras != null)
				for (cam in FlxG.cameras.list)
					if (cam != null && cam.filters != null)
						@:privateAccess {
						cam.flashSprite.__cacheBitmap = null;
						cam.flashSprite.__cacheBitmapData = null;
					};

			if (FlxG.game != null)
				@:privateAccess {
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
			Util.error(null, 'Uncaught Error\n$err', true);
		});
	}

	@:noCompletion @:keep public static inline function get_horizonVer():String
		return Application.current.meta.get('version');
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
			Util.error(e, 'FlxGame: create', true);

	override function onEnterFrame(_)
		try
		{
			super.onEnterFrame(_);
		}
		catch (e:Exception)
			Util.error(e, 'FlxGame: onEnterFrame', true);

	override function update()
		try
		{
			super.update();
		}
		catch (e:Exception)
			Util.error(e, 'FlxGame: update', true);

	override function draw()
		try
		{
			super.draw();
		}
		catch (e:Exception)
			Util.error(e, 'FlxGame: draw', true);

	override function onFocus(_)
		try
		{
			super.onFocus(_);
		}
		catch (e:Exception)
			Util.error(e, 'FlxGame: onFocus', true);

	override function onFocusLost(_)
		try
		{
			super.onFocusLost(_);
		}
		catch (e:Exception)
			Util.error(e, 'FlxGame: onFocusLost', true);
}
