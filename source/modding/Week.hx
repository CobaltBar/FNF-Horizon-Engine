package modding;

@:structInit
@:publicFields
class Week
{
	var name:String;
	var menuChars:Array<String>;
	var menuBG:String;
	var locked:Bool;
	var hideSongsFromFreeplay:Bool;
	var songs:Array<String>;

	private var modName:String;

	@:optional var difficulties:Array<String>;
	@:optional var score:Int;
}
