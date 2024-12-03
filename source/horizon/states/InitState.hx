package horizon.states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import haxe.Http;
import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import horizon.util.ALConfig;
import lime.app.Application;

class InitState extends MusicState
{
	public static var onlineVer:String;
	public static var shouldUpdate:Bool = false;

	public override function create():Void
	{
		#if windows
		OSUtil.setDPIAware();
		OSUtil.toggleWindowDarkMode();
		#end

		Log.init();
		SettingsManager.load();
		Controls.init();

		Toolkit.init();
		Toolkit.theme = 'horizon';
		CursorHelper.useCustomCursors = false;
		if (Constants.verbose)
			Log.info('HaxeUI Setup Complete');

		Mods.load();
		Path.loadAssets();
		Path.init();

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, 0xFF000000, .25, new FlxPoint(-1));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, 0xFF000000, .25, new FlxPoint(1));

		Alphabet.init();

		FlxG.plugins.addPlugin(new Conductor());
		super.create();

		var request = new Http('https://raw.githubusercontent.com/CCobaltDev/FNF-Horizon-Engine/main/.build');
		request.onData = data ->
		{
			onlineVer = data.trim();
			if (Std.parseFloat(onlineVer) > Std.parseFloat(Constants.horizonVer))
			{
				shouldUpdate = true;
				Log.info('Update prompt will be displayed ($onlineVer > ${Constants.horizonVer})');
			}
			else
				Log.info('Update prompt will not be displayed (${Constants.horizonVer} >= $onlineVer)');
		}
		request.onError = msg -> Log.error('Update Check Error: $msg');
		request.request();

		MusicState.switchState(new TitleState(), true, true);
	}
}
