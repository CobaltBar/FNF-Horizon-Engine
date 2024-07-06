package states;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import lime.app.Application;

class InitState extends MusicState
{
	override public function create()
	{
		Log.init();
		Settings.load();

		Toolkit.init();
		Toolkit.theme = 'dark';
		CursorHelper.useCustomCursors = false;
		if (Main.verbose)
			Log.info('HaxeUI Initialized');

		Mods.load();
		Path.loadAssets();

		if (Main._console == null)
			Main._console = new Console();

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, .35, FlxPoint.weak(-1, 0));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, .35, FlxPoint.weak(1, 0));

		// Thanks superpowers04
		if (Settings.data.framerate == 0)
		{
			var rf = Application.current.window.displayMode.refreshRate;
			var fr = Application.current.window.frameRate;
			var frameRate = rf > 60 ? rf : fr > 60 ? fr : 60;
			FlxG.updateFramerate = Std.int(frameRate * 1.5);
			FlxG.drawFramerate = Std.int(frameRate);
		}

		FlxG.plugins.addPlugin(new Conductor());
		super.create();

		FlxG.signals.preStateSwitch.add(() ->
		{
			Main._showConsole = !Main._console.hidden;
			Main._console.shouldDestroy = false;
		});
		FlxG.signals.postStateSwitch.add(() ->
		{
			Main._console.cameras = [Create.camera()];
			if (Main._showConsole)
				Main._console.show();
			Main._console.shouldDestroy = false;
		});

		MusicState.switchState(Settings.data.accessibilityConfirmed ? new TitleState() : new AccessibilityState(), true);
	}
}
