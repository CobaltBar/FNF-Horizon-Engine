package states;

import haxe.ui.Toolkit;
import haxe.ui.backend.flixel.CursorHelper;
import modding.ModManager;

class InitState extends MusicState
{
	public override function create()
	{
		Toolkit.init();
		Toolkit.theme = 'dark';
		CursorHelper.useCustomCursors = false;
		Settings.load();
		ModManager.loadMods();
		Path.loadAssets();
		Path.reloadEnabledMods();

		MusicState.switchState(new TitleState(), true);

		super.create();
	}
}
