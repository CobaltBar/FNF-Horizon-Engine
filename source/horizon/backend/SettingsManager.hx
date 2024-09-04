package horizon.backend;

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
		if (Main.verbose)
			Log.info('Settings saved');
	}

	public static function load()
	{
		for (setting in Type.getClassFields(Settings))
			if (Reflect.hasField(FlxG.save.data, setting))
				Reflect.setField(Settings, setting, Reflect.field(FlxG.save.data, setting));

		FlxG.fullscreen = Settings.fullscreen;
		FlxG.updateFramerate = FlxG.drawFramerate = Settings.framerate;
		FlxG.sound.volumeUpKeys = Settings.keybinds['volume_increase'];
		FlxG.sound.volumeDownKeys = Settings.keybinds['volume_decrease'];
		FlxG.sound.muteKeys = Settings.keybinds['volume_mute'];
		FlxG.sound.volume = FlxG.save.data.volume ?? 1;
		FlxG.sound.muted = FlxG.save.data.muted ?? false;

		if (Main.verbose)
			Log.info('Settings Loaded');
	}
}
