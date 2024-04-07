package modding;

class Week
{
	public var name:String;
	public var menuChars:Array<String> = [];
	public var menuBG:String;
	public var locked:Bool;
	public var hideSongsFromFreeplay:Bool;
	public var difficulties:Array<String> = [];

	public function new(name:String, menuChars:Array<String>, menuBG:String, locked:Bool, hideSongsFromFreeplay:Bool, difficulties:Array<String>)
	{
		this.name = name;
		this.menuChars = menuChars;
		this.menuBG = menuBG;
		this.locked = locked;
		this.hideSongsFromFreeplay = hideSongsFromFreeplay;
		this.difficulties = difficulties;
	}
}

