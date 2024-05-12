package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import lime.app.Application;

class InitState extends MusicState
{
	public override function create()
	{
		Log.init();
		Settings.load();
		Toolkit.init();
		Toolkit.theme = 'dark';
		CursorHelper.useCustomCursors = false;
		Path.loadAssets();
		Mods.load();
		Path.loadModAssets();

		DiscordRPC.init();

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, .5, FlxPoint.weak(-1, 0));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, .5, FlxPoint.weak(1, 0));

		// Thanks superpowers04
		if (Settings.data.framerate == 0)
		{
			var rf = Application.current.window.displayMode.refreshRate;
			var fr = Application.current.window.frameRate;
			var frameRate = rf > 60 ? rf : fr > 60 ? fr : 60;
			FlxG.updateFramerate = Std.int(frameRate * 1.5);
			FlxG.drawFramerate = Std.int(frameRate);
		}

		if (Main.verboseLogging)
			Log.info('HaxeUI Setup Complete');

		FlxG.plugins.addPlugin(new Conductor());
		super.create();
		MusicState.switchState(Settings.data.accessibilityConfirmed ? new TitleState() : new AccessibilityState(), true);
	}
}
