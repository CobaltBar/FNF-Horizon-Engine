package horizon.modding;

typedef Chart =
{
	var notes:Array<NoteJSON>;
	var events:Array<EventJSON>;
	var bpm:Float;
	var scrollSpeed:Float;
	var characters:Array<String>;
}

typedef NoteJSON =
{
	var data:Int;
	var time:Float;
	@:optional var length:Float;
	@:optional var type:String;
	@:optional var mult:Float;
}

typedef EventJSON =
{
	var name:String;
	var time:Float;
	var value:Array<Dynamic>;
}
