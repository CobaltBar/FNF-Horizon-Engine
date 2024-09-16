package horizon.backend;

@:publicFields
class Constants
{
	static final horizonVer:String = VersionMacro.get();
	static final modSysVer:Float = 1;
	static var verbose:Bool = false;
	static var debugDisplay:Bool = #if debug true #else false #end;
}
