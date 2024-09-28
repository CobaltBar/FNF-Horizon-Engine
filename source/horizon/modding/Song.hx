package horizon.modding;

@:publicFields @:structInit class Song
{
	var name:String;

	var icon:String;
	var hide:Bool;
	var audios:Array<String>;
	var folder:String;
	var score:Int;
	var accuracy:Float;
}

typedef SongJSON =
{
	var name:Null<String>;
	var icon:Null<String>;
	var hide:Null<Bool>;
}
