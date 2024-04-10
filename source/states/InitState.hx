package states;

import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import modding.ModManager;

class InitState extends MusicState
{
	public static final modSysVer:Int = 1;

	public override function create()
	{
		Log.init();
		Settings.load();
		Toolkit.init();
		Toolkit.theme = 'dark';
		CursorHelper.useCustomCursors = false;
		Path.loadAssets();
		ModManager.loadMods();
		ModManager.reloadEnabledMods();
		DiscordRPC.init();

		FlxG.plugins.addPlugin(new Conductor());
		super.create();
		MusicState.switchState(new TitleState(), true);
	}
}
