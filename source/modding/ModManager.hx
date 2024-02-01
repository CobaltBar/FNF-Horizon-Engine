package modding;

class ModManager
{
	final folders:Array<String> = [
		"achievements", "characters", "charts", "custom_events", "custom_notetypes", "fonts", "images", "menu_scripts", "scripts", "shaders", "songs",
		"sounds", "stages", "videos", "weeks"
	];

	public static var mods:Array<Mod> = [];
	public static var staticMod:Mod;

	public static function loadMods():Void {}
}
