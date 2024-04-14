package modding;

@:structInit
@:publicFields
class Song
{
	var name:String;
	var difficulties:Array<String>;
	var icon:String;

	var audioFiles:Array<String> = [];
	
	@:optional var score:Int;
	@:optional var accuracy:Float;
}
