package modding;

@:structInit
@:publicFields
class Song
{
	var name:String;
	var icon:String;
	var hide:Bool;

	var folderName:String;
	var audioFiles:Array<String>;
	var score:Int;
	var accuracy:Float;
}
