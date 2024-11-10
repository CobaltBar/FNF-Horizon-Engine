package horizon.backend;

@:publicFields
class Constants
{
	static var horizonVer:String = VersionMacro.get();
	static var modSysVer:Float = 1;
	static var verbose:Bool = false;
	static var debugDisplay:Bool = #if debug true #else false #end;

	static var notebindNames = ['note_left', 'note_down', 'note_up', 'note_right'];
}
