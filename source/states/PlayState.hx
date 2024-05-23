package states;

class PlayState extends MusicState
{
	var playerStrum:Strumline;
	var opponentStrum:Strumline;

	public override function create()
	{
		Path.clearStoredMemory();
		super.create();
		shouldBop = shouldZoom = false;
		Conductor.switchToMusic = false;
		FlxG.sound.music.destroy();
		DiscordRPC.change('In Game', 'Song: \nScore: 69');
		add(playerStrum = new Strumline(FlxG.width - 50, 100));
		playerStrum.x -= playerStrum.width;
		add(opponentStrum = new Strumline(50, 100));
	}
}
