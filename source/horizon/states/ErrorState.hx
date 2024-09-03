package horizon.states;

import haxe.ui.containers.ScrollView;

class ErrorState extends MusicState
{
	public static var errs:Array<String> = [];

	public override function create():Void
	{
		Path.clearStoredMemory();
		super.create();
		bop = false;

		#if DISCORD_ENABLED
		DiscordRPC.change('In the Menus', 'Error Screen');
		#end

		var errorTitle:FlxText;
		add(errorTitle = Create.text(0, Settings.reducedMotion ? 50 : -100, 'Error Caught', 32, Path.font('vcr'), 0xFFFF0000, CENTER));
		errorTitle.screenCenter(X);

		var errorDescription = new ErrorDescription();
		add(errorDescription);

		var errorControls:FlxText;
		add(errorControls = Create.text(0, Settings.reducedMotion ? FlxG.height + 40 : FlxG.height + 100,
			'Restart Engine: ${Settings.keybinds.get('accept')[0].toString()}/${Settings.keybinds.get('accept')[1].toString()}\nCreate Log and Restart: ${Settings.keybinds.get('back')[0].toString()}/${Settings.keybinds.get('back')[1].toString()}',
			18, Path.font('vcr'), 0xFF00FF00, CENTER));
		errorControls.screenCenter(X);

		if (!Settings.reducedMotion)
		{
			FlxTween.tween(errorTitle, {y: 50}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
			var oldY = errorDescription.y;
			errorDescription.y = FlxG.height + 100;
			FlxTween.tween(errorDescription, {y: oldY}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
			FlxTween.tween(errorControls, {y: FlxG.height - 40}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
		}

		Controls.onPress(Settings.keybinds['accept'], () -> resetGame());
		Controls.onPress(Settings.keybinds['back'], () ->
		{
			File.saveContent('log.txt', @:privateAccess Log.log.join('\n'));
			resetGame();
		});

		Path.clearUnusedMemory();
	}

	public function resetGame():Void
	{
		Log.warn('RESETTING GAME');
		@:privateAccess TitleState.comingBack = false;
		@:privateAccess TitleState.titleData = null;
		Conductor.reset();
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.destroy();
			FlxG.sound.music = null;
		}
		Path.clearStoredMemory();
		Path.clearUnusedMemory();
		FlxG.plugins.removeAllByType(Conductor);
		@:privateAccess Log.log = [];
		FlxG.resetGame();
	}
}

@:xml('
<scrollview contentWidth="100%" height="1080">
	<label id="output" text="" />
</scrollview>
')
class ErrorDescription extends ScrollView
{
	public function new()
	{
		super();
		width = output.width = FlxG.width;
		height = FlxG.height * .7;
		output.text = ErrorState.errs.join('\n');
		output.customStyle.fontName = 'VCR OSD Mono';
		output.fontSize = 18;
		output.invalidateComponentStyle();

		screenCenter();
	}
}
