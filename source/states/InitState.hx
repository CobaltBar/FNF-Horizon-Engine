package states;

import modding.ModManager;

class InitState extends MusicState
{
	public override function create()
	{
		Settings.load();
		ModManager.loadMods();

		MusicState.switchState(new ModSelectionState(), true);

		super.create();
	}
}
