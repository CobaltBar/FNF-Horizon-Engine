package states;

import modding.ModManager;

class InitState extends MusicState
{
	public override function create()
	{
		Settings.load();
		ModManager.loadMods();
		Path.loadAssets();

		MusicState.switchState(new TitleState(), true);

		super.create();
	}
}
