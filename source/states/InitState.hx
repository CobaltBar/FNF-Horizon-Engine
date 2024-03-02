package states;

import haxe.ui.Toolkit;
import modding.ModManager;

class InitState extends MusicState
{
	public override function create()
	{
		Toolkit.init();
		Settings.load();
		ModManager.loadMods();
		Path.loadAssets();
		Path.reloadEnabledMods();

		MusicState.switchState(new TitleState(), true);

		super.create();
	}
}
