package states;

import modding.Mod;
import modding.ModManager;

class ModsMenuState extends MusicMenuState
{
	public override function create()
	{
		setupMenu();
		createMenuBG();
		createModUI();
		createModOptions(ModManager.discoveredMods, ModManager.enabledMods);
		super.create();
	}

	public override function returnState()
	{
		super.returnState();
		MusicState.switchState(new MainMenuState());
	}

	public override function changeSelection(change:Int, sound:Bool = true, set:Bool = false) {}

	public override function exitState() {}

	public function createModOptions(allMods:Array<Mod>, enabledMods:Array<Mod>):Void {}

	public function createMenuBG():Void
	{
		bg = Util.createBackdrop(Path.image("menuBG"), 1.7);
		bg.cameras = [menuCam];
		add(bg);
	}

	public function createModUI():Void
	{
		var modBG:FlxSprite = Util.makeSprite(50, 50, Std.int(FlxG.width / 2 - 80), Std.int(FlxG.height - 320), 0xBB000000);
		modBG.cameras = [otherCam];
		add(modBG);

		var modBG:FlxSprite = Util.makeSprite(50, 50, Std.int(FlxG.width / 2 - 80), Std.int(FlxG.height - 320), 0xBB000000);
		modBG.cameras = [otherCam];
		modBG.x = FlxG.width - 50 - modBG.width;
		add(modBG);

		var modBG:FlxSprite = Util.makeSprite(50, 50, Std.int(FlxG.width - 100), 180, 0xBB000000);
		modBG.cameras = [otherCam];
		modBG.y = FlxG.height - 50 - modBG.height;
		add(modBG);
	}
}
