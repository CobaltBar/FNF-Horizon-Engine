package states;

class ModsMenuState extends MusicMenuState
{
	public override function create()
	{
		setupMenu();
		createMenuBG();

		super.create();
	}

	public override function returnState()
	{
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false) {}

	public override function exitState() {}

	public function createMenuBG():Void
	{
		bg = Util.createBackdrop(Path.image("menuBG"), 1.7);
		bg.cameras = [menuCam];
		add(bg);
	}
}
