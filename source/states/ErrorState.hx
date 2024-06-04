package states;

import sys.FileSystem;
import sys.io.File;

class ErrorState extends MusicState
{
	var errorTitle:FlxText;
	var errorDescription:FlxText;
	var errorControls:FlxText;

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		DiscordRPC.change('In The Menus', 'Error Screen');
		shouldBop = false;
		add(errorTitle = Util.createText(FlxG.width * .5, Settings.data.reducedMotion ? 75 : -100, 'Error Caught', 36, Path.font('vcr'), 0xFFFF0000, CENTER));
		errorTitle.screenCenter(X);
		add(errorDescription = Util.createText(0, Settings.data.reducedMotion ? 175 : FlxG.height + 100, @:privateAccess Log.log, 18, Path.font('vcr'),
			0xFFFFFFFF, LEFT));
		add(errorControls = Util.createText(0, Settings.data.reducedMotion ? FlxG.height + 40 : FlxG.height + 100,
			'Restart Engine: ${Settings.data.keybinds.get('accept')[0].toString()}/${Settings.data.keybinds.get('accept')[1].toString()}\nCreate Log and Restart: ${Settings.data.keybinds.get('back')[0].toString()}/${Settings.data.keybinds.get('back')[1].toString()}',
			18, Path.font('vcr'), 0xFF00FF00, LEFT));
		if (!Settings.data.reducedMotion)
		{
			FlxTween.tween(errorTitle, {y: 75}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
			FlxTween.tween(errorDescription, {y: 175}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
			FlxTween.tween(errorControls, {y: FlxG.height - 40}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
		}
	}

	public override function update(elapsed:Float):Void
	{
		if (Controls.accept)
			resetGame();
		if (Controls.back)
		{
			if (!FileSystem.exists('log'))
				FileSystem.createDirectory('log');
			Log.info('Log Written');
			File.saveContent('log/log.txt', @:privateAccess Log.log);
			resetGame();
		}
		super.update(elapsed);
	}

	public function resetGame():Void
	{
		Log.info('Resetting Game\n');
		@:privateAccess TitleState.comingBack = false;
		@:privateAccess TitleState.titleData = null;
		Conductor.reset();
		@:bypassAccessor Conductor.song = null;
		FlxG.sound.music.destroy();
		FlxG.sound.music = null;
		Path.clearStoredMemory();
		Path.clearUnusedMemory();
		FlxG.plugins.removeAllByType(Conductor);
		FlxG.resetGame();
	}
}
