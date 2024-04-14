package states;

import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import lime.app.Application;
import modding.ModManager;

class InitState extends MusicState
{
	public static final modSysVer:Int = 1;

	// maybe add audio in the future if i ever add HTML5 support
	public static final extensions:Map<String, Array<String>> = ["script" => ["hx", "lua"]];

	public override function create()
	{
		Log.init();
		Settings.load();
		Toolkit.init();
		Toolkit.theme = 'dark';
		CursorHelper.useCustomCursors = false;
		Path.loadAssets();
		ModManager.reloadMods();
		DiscordRPC.init();

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
		MusicState.switchState(new TitleState(), true);
	}
}
