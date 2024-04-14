package modding;

typedef ModJsonData =
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var globalMod:Bool;
	public var modSysVer:Int;
}

typedef WeekJsonData =
{
	public var name:String;
	public var menuChars:Array<String>;
	public var menuBG:String;
	public var locked:Bool;
	public var songs:Array<String>;
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
	public var icon:String;
}

typedef ChartJsonData = {}

typedef TitleJsonData =
{
	bpm:Float,
	gfPosition:Array<Int>,
	logoPosition:Array<Int>,
	startPosition:Array<Int>
}
