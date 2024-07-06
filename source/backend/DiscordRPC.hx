package backend;

#if DISCORD_ENABLED
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
		Thread.create(() -> while (true)
		{
			#if DISCORD_DISABLE_IO_THREAD
			Discord.UpdateConnection();
			#end
			Discord.RunCallbacks();

			Sys.sleep(1);
		});
	}

	public static function change(?details:String, ?state:String):Void
	{
		if (details != null)
			presence.details = details;
		if (state != null)
			presence.state = state;
		Discord.UpdatePresence(RawConstPointer.addressOf(presence));
	}

	private static function onReady(request:RawConstPointer<DiscordUser>):Void
	{
		presence.state = 'In The Menus';
		presence.startTimestamp = Std.int(Date.now().getTime() / 1000);
		presence.largeImageKey = 'icon';
		Discord.UpdatePresence(RawConstPointer.addressOf(presence));
	}
}
#end
