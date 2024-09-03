package horizon.modding;

@:publicFields @:structInit class Song
{
	var name:String;

	var icon:String;
	var hide:Bool;
	var audios:Array<String>;
	var score:Float;
	var accuracy:Float;
}

typedef SongJSON =
{
	var name:String;
	var icon:String;
	var hide:Bool;
}
