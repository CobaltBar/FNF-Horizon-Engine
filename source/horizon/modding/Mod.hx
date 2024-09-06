package horizon.modding;

@:publicFields @:structInit class Mod
{
	var name:String;

	var description:String;
	var version:String;
	var color:Array<Int>;
	var global:Bool;
	var staticMod:Bool;
	var modSysVer:Float;
	var ID:Int;
	var iconPath:String;

	// var awards:Array<Award>;
	var characters:Array<CharacterData>;

	// var events:Array<Event>;
	// var notes:Array<CustomNote>;
	// var scripts:Array<String>;
	var songs:Array<Song>;
	var stages:Array<StageData>;
	var weeks:Array<Week>;
	var path:String;
}

typedef ModJSON =
{
	var name:String;
	var description:String;
	var version:String;
	var color:Array<Int>;
	var global:Bool;
	var modSysVer:Float;
}
