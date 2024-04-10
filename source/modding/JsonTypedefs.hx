package modding;

typedef ModJsonData =
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var rpcChange:String;
	public var modSysVer:Int;
}

typedef WeekJsonData =
{
	public var name:String;
	public var menuChars:Array<String>;
	public var menuBG:String;
	public var locked:Bool;
	public var songs:Array<Array<String>>;
	public var hideSongsFromFreeplay:Bool;
}

typedef MenuCharJsonData =
{
	public var position:Array<Int>;
	public var scale:Float;
	public var idle:String;
	public var confirm:String;
}

typedef SongJsonData =
{
	public var name:String;
	public var difficulties:Array<String>;
	public var icon:String;
}

typedef TitleJsonData =
{
	bpm:Float,
	gfPosition:Array<Int>,
	logoPosition:Array<Int>,
	startPosition:Array<Int>
}
