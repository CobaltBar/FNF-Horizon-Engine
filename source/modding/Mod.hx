package modding;

class Mod
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var globalMod:Bool;
	public var rpcChange:String;
	public var path:String;
	public var icon:String;
	public var ID:Int;

	public function new(name:String, description:String, version:String, color:Array<Int>, globalMod:Bool, rpcChange:String, path:String, icon:String)
	{
		this.name = name;
		this.description = description;
		this.version = version;
		this.color = color;
		this.globalMod = globalMod;
		this.rpcChange = rpcChange;
		this.path = path;
		this.icon = icon;
	}
}

typedef ModJsonData =
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var globalMod:Bool;
	public var rpcChange:String;
}
