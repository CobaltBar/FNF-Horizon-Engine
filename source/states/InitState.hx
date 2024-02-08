package states;

import modding.ModManager;

class InitState extends MusicState
{
	public override function create()
	{
		Settings.load();
		ModManager.loadMods();
		z

		// MusicState.switchState(new ModSelectionState(), true);

		super.create();
	}
}
