package backend;

import cpp.Function;
import cpp.RawConstPointer;
import cpp.RawPointer;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types.DiscordEventHandlers;
import hxdiscord_rpc.Types.DiscordRichPresence;
import hxdiscord_rpc.Types.DiscordUser;
import sys.thread.Thread;

class DiscordRPC
{
	private static final defaultID = '1226704469312409692';
	public static var clientID:String = defaultID;
	private static var presence:DiscordRichPresence = DiscordRichPresence.create();

	public static function init():Void
	{
		var handlers:DiscordEventHandlers = DiscordEventHandlers.create();
		handlers.ready = Function.fromStaticFunction(onReady);
		Discord.Initialize(clientID, RawPointer.addressOf(handlers), 1, null);
		Thread.create(() ->
		{
			while (true)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end
				Discord.RunCallbacks();

				Sys.sleep(1);
			}
		});
	}

	public static function change(?state:String, ?details:String):Void
	{
		if (state != null)
			presence.state = state;
		if (details != null)
			presence.details = details;
		Discord.UpdatePresence(RawConstPointer.addressOf(presence));
	}

	private static function onReady(request:RawConstPointer<DiscordUser>):Void
	{
		presence.state = 'Initializing...';
		presence.startTimestamp = Std.int(Date.now().getTime() / 1000);
		Discord.UpdatePresence(RawConstPointer.addressOf(presence));
	}
}
