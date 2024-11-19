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

	public static function toggleWindowDarkMode():Void
	{
		#if cpp
		if (!Windows.toggleWindowDarkMode(Application.current.window.title))
			Log.warn('Failed to toggle Dark Mode');
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
		int darkMode = 0;
		HWND window = FindWindowA(NULL, windowTitle.c_str());
		if (window == NULL)
			window = FindWindowExA(GetActiveWindow(), NULL, NULL, windowTitle.c_str());
		if (window != NULL)
		{
			if (DwmGetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)) != S_OK)
				DwmGetWindowAttribute(window, 20, &darkMode, sizeof(darkMode));

			darkMode ^= 1;
			
			if (DwmSetWindowAttribute(window, 19, &darkMode, sizeof(darkMode)) != S_OK)
				return DwmSetWindowAttribute(window, 20, &darkMode, sizeof(darkMode)) == S_OK;
			else return TRUE;
		}else return FALSE;
	')
	static function toggleWindowDarkMode(windowTitle:String):Bool
		return false;
}
