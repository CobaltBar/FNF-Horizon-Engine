package states;

import openfl.events.KeyboardEvent;

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
		add(playerStrum = new Strumline(FlxG.width - 50, 150));
		playerStrum.x -= playerStrum.width;
		for (note in playerStrum.members) // i dont like this either
			@:privateAccess add(note.blurSpr);
		add(opponentStrum = new Strumline(50, 150));
		for (note in opponentStrum.members)
			@:privateAccess add(note.blurSpr);

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, event ->
		{
			if (event.keyCode == Settings.data.keybinds.get("notes")[0] || event.keyCode == Settings.data.keybinds.get("notes")[4])
				playerStrum.members[0].glowAlphaTarget = 1;
			if (event.keyCode == Settings.data.keybinds.get("notes")[1] || event.keyCode == Settings.data.keybinds.get("notes")[5])
				playerStrum.members[1].glowAlphaTarget = 1;
			if (event.keyCode == Settings.data.keybinds.get("notes")[2] || event.keyCode == Settings.data.keybinds.get("notes")[6])
				playerStrum.members[2].glowAlphaTarget = 1;
			if (event.keyCode == Settings.data.keybinds.get("notes")[3] || event.keyCode == Settings.data.keybinds.get("notes")[7])
				playerStrum.members[3].glowAlphaTarget = 1;
		});
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, event ->
		{
			if (event.keyCode == Settings.data.keybinds.get("notes")[0] || event.keyCode == Settings.data.keybinds.get("notes")[4])
				playerStrum.members[0].glowAlphaTarget = 0;
			if (event.keyCode == Settings.data.keybinds.get("notes")[1] || event.keyCode == Settings.data.keybinds.get("notes")[5])
				playerStrum.members[1].glowAlphaTarget = 0;
			if (event.keyCode == Settings.data.keybinds.get("notes")[2] || event.keyCode == Settings.data.keybinds.get("notes")[6])
				playerStrum.members[2].glowAlphaTarget = 0;
			if (event.keyCode == Settings.data.keybinds.get("notes")[3] || event.keyCode == Settings.data.keybinds.get("notes")[7])
				playerStrum.members[3].glowAlphaTarget = 0;
		});
	}
}
