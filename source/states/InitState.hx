package states;

import modding.ModManager;

class InitState extends MusicState
{
	public override function create()
	{
		Settings.load();
		ModManager.loadMods();
		Path.reloadAssets();

		MusicState.switchState(new TitleState(), true);

		super.create();
	}
}
