package states;

import modding.ModManager;

class InitState extends MusicState
{
	public override function create()
	{
		Settings.load();
		ModManager.loadMods();
		Path.loadAssets();
		Path.reloadEnabledMods();

		MusicState.switchState(new TitleState(), true);

		super.create();
	}
}
