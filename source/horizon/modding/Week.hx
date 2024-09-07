package horizon.modding;

@:publicFields @:structInit class Week
{
	var name:String;

	var menuChars:Array<String>;
	var bg:String;
	var bgScale:Float;
	var locked:Bool;
	var unlocks:Array<String>;
	var songs:Array<String>;
	var folder:String;
	var difficulties:Array<String>;
	var score:Int;
	var accuracy:Float;
}

typedef WeekJSON =
{
	var name:String;
	var menuChars:Array<String>;
	var bg:String;
	var bgScale:Float;
	var locked:Bool;
	var unlocks:Array<String>;
	var songs:Array<String>;
	var difficulties:Array<String>;
}
