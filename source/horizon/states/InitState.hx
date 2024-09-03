package horizon.states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import lime.app.Application;

class InitState extends MusicState
{
	public override function create():Void
	{
		Log.init();
		SettingsManager.load();
		Controls.init();

		Toolkit.init();
		Toolkit.theme = 'horizon';
		CursorHelper.useCustomCursors = false;
		if (Main.verbose)
			Log.info('HaxeUI Setup Complete');

		Mods.load();
		Path.loadAssets();

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, .25, FlxPoint.get(-1, 0));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, .25, FlxPoint.get(1, 0));

		// Thanks superpowers04
		if (Settings.framerate == 0)
			FlxG.updateFramerate = FlxG.drawFramerate = Std.int(Application.current.window.displayMode.refreshRate > 120 ? Application.current.window.displayMode.refreshRate : Application.current.window.frameRate > 120 ? Application.current.window.frameRate : 120);

		FlxG.plugins.addPlugin(new Conductor());
		super.create();
		MusicState.switchState(new TitleState(), true, true);
	}
}
