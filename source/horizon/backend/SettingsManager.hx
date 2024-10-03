package horizon.backend;

import lime.app.Application;

class SettingsManager
{
	public static function save():Void
	{
		Settings.fullscreen = FlxG.fullscreen;
		FlxG.save.data.volume = FlxG.sound.volume;
		FlxG.save.data.muted = FlxG.sound.muted;
		for (setting in Type.getClassFields(Settings))
			Reflect.setField(FlxG.save.data, setting, Reflect.field(Settings, setting));
		FlxG.save.flush();
		if (Constants.verbose)
			Log.info('Settings saved');
	}

	public static function load()
	{
		for (setting in Type.getClassFields(Settings))
			if (Reflect.hasField(FlxG.save.data, setting))
				Reflect.setField(Settings, setting, Reflect.field(FlxG.save.data, setting));

		FlxG.fullscreen = Settings.fullscreen;
		FlxG.sound.volumeUpKeys = Settings.keybinds['volume_increase'];
		FlxG.sound.volumeDownKeys = Settings.keybinds['volume_decrease'];
		FlxG.sound.muteKeys = Settings.keybinds['volume_mute'];
		FlxG.sound.volume = FlxG.save.data.volume ?? 1;
		FlxG.sound.muted = FlxG.save.data.muted ?? false;
		FlxSprite.defaultAntialiasing = Settings.antialiasing;
		FlxG.fixedTimestep = FlxObject.defaultMoves = false;

		// Thanks superpowers04
		if (Settings.framerate == 0)
			FlxG.drawFramerate = FlxG.updateFramerate = (Settings.framerate == 0 ? Std.int(Application.current.window.displayMode.refreshRate > 120 ? Application.current.window.displayMode.refreshRate : Application.current.window.frameRate > 120 ? Application.current.window.frameRate : 120) : Settings.framerate);

		if (Constants.verbose)
			Log.info('Settings Loaded');
	}
}
