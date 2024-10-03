package horizon.backend;

import lime.app.Application;

class OSUtil
{
	#if windows
	public static function setDPIAware():Void
	{
		#if cpp
		if (!Windows.setDPIAware())
			Log.warn('Failed to set DPI Awareness');
		#else
		Log.warn('setDPIAware is not supported on this platform');
		#end
	}

	public static function setWindowDarkMode(dark:Bool):Void
	{
		#if cpp
		if (!Windows.setWindowDarkMode(Application.current.window.title, dark))
			Log.warn('Failed to set Dark Mode');
		#else
		Log.warn('setWindowDarkMode is not supported on this platform');
		#end
	}
	#end
}

// Based on CDEV Engine's Windows.hx
#if cpp
#if windows
@:cppInclude('windows.h')
@:cppInclude('dwmapi.h')
@:buildXml('
<target id="haxe">
  <lib name="dwmapi.lib" />
</target>
')
#end
#end
@:publicFields
private class Windows
{
	@:functionCode('return SetProcessDPIAware();')
	static function setDPIAware():Bool
		return false;

	@:functionCode('
		int darkMode = enable ? 1 : 0;

		HWND window = FindWindowA(NULL, windowTitle.c_str());
		
		if (window == NULL) window = FindWindowExA(GetActiveWindow(), NULL, NULL, windowTitle.c_str());

		if (window != NULL) {
			if (DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)) != S_OK) {
				return DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)) == S_OK;
			}else return FALSE;
		}else return FALSE;
	')
	static function setWindowDarkMode(windowTitle:String, enable:Bool):Bool
		return false;
}
