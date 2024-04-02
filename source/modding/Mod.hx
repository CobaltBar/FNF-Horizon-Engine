package modding;

import flixel.system.FlxAssets.FlxGraphicAsset;

class Mod
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var rpcChange:String;
	public var modSysVer:Int;

	public var staticMod:Bool = false;
	public var enabled:Bool = false;

	public var path:String;
	public var icon:FlxGraphicAsset;
	public var ID:Int;

	public function new(name:String, description:String, version:String, color:Array<Int>, rpcChange:String, modSysVer:Int, path:String, icon:FlxGraphicAsset,
			ID:Int)
	{
		this.name = name;
		this.description = description;
		this.version = version;
		this.color = color;
		this.rpcChange = rpcChange;
		this.modSysVer = modSysVer;

		this.path = path;
		this.icon = icon;
		this.ID = ID;
	}
}

typedef ModJsonData =
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var rpcChange:String;
	public var modSysVer:Int;
}
