package modding;

typedef ModJSON =
{
	var name:String;
	var description:String;
	var version:String;
	var color:Array<Int>;
	var global:Bool;
	var modSysVer:Float;
}

typedef TitleJSON =
{
	bpm:Float,
	gfPosition:Array<Int>,
	logoPosition:Array<Int>,
	startPosition:Array<Int>
}

typedef SongJSON =
{
	var name:String;
	var icon:String;
	var hide:Bool;
}

typedef WeekJSON =
{
	var name:String;
	var chars:Array<String>;
	var bg:String;
	var bgScale:Float;
	var locked:Bool;
	var unlocks:Array<String>;
	var songs:Array<String>;
	var difficulties:Array<String>;
}

typedef MenuCharJSON =
{
	var position:Array<Float>;
	var scale:Float;
	var idle:Array<String>;
	var confirm:String;
	var idleIndices:Array<Array<Int>>;
	var confirmIndices:Array<Int>;
	var repeatEvery:Int;
	var fps:Int;
}

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
	var length:Float;
	var type:String;
	var mult:Float;
}

typedef EventJSON =
{
	var name:String;
	var time:Float;
	var value:Array<String>;
}
