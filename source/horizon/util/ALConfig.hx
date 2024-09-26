package horizon.util;

// https://github.com/ShadowMario/FNF-PsychEngine/pull/15536
@:keep class ALConfig
{
	#if desktop
	static function __init__():Void
	{
		var configPath:String = PathUtil.directory(PathUtil.withoutExtension(Sys.programPath()));

		#if windows
		configPath += "/plugins/alsoft.ini";
		#elseif mac
		configPath = PathUtil.directory(configPath) + "/Resources/plugins/alsoft.conf";
		#elseif linux
		configPath += "/plugins/alsoft.conf";
		#end

		Sys.putEnv("ALSOFT_CONF", configPath);
	}
	#end
}
