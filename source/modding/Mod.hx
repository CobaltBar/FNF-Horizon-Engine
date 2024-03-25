package modding;

class Mod
{
	public var name:String;
	public var description:String;
	public var version:String;
	public var color:Array<Int>;
	public var rpcChange:String;
	public var modSysVer:Int;

	public var path:String;
	public var icon:String;
	public var ID:Int;

	public function new(name:String, description:String, version:String, color:Array<Int>, rpcChange:String, modSysVer:Int, path:String, icon:String, ID:Int)
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

	@:op(A == B)
	public function aisB(a:Mod, b:Mod):Bool
	{
		trace('guh');
		return true;
	}

	// :3
	public static function isEqual(a:Mod, b:Mod):Bool
		return a.name == b.name && a.description == b.description && a.version == b.version && a.color == b.color && a.rpcChange == b.rpcChange
			&& a.modSysVer == b.modSysVer && a.path == b.path && a.icon == b.icon && a.ID == b.ID;
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
