package modding;

@:structInit
@:publicFields
class Mod
{
	var name:String;
	var description:String;
	var version:String;
	var color:Array<Int>;
	var globalMod:Bool;
	var modSysVer:Int;

	var path:String;
	var icon:String;

	@:optional var enabled:Bool;
	@:optional var staticMod:Bool;
	@:optional var weeks:Map<String, Week>;
	@:optional var songs:Map<String, Song>;
	@:optional var ID:Int;
}
