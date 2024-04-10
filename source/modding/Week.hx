package modding;

class Week
{
	public var name:String;
	public var menuChars:Array<String> = [];
	public var menuBG:String;
	public var locked:Bool;
	public var songs:Array<String> = [];
	public var hideSongsFromFreeplay:Bool;
	public var difficulties:Array<String> = [];

	public function new(name:String, menuChars:Array<String>, menuBG:String, locked:Bool, songs:Array<String>, hideSongsFromFreeplay:Bool,
			difficulties:Array<String>)
	{
		this.name = name;
		this.menuChars = menuChars;
		this.menuBG = menuBG;
		this.locked = locked;
		this.songs = songs;
		this.hideSongsFromFreeplay = hideSongsFromFreeplay;
		this.difficulties = difficulties;
	}
}
