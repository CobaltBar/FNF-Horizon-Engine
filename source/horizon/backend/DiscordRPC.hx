package horizon.backend;

#if cpp
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
#elseif hl
import hashcord.Discord;
#end
import lime.app.Application;
import sys.thread.Thread;

class DiscordRPC
{
	public static var rpcID(default, set) = defaultID;
	public static var presence:DiscordRichPresence = DiscordRichPresence.create();

	static inline final defaultID = "1226704469312409692";
	static var thread:Thread;
	static var handlers = DiscordEventHandlers.create();

	public static function init():Void
	{
		if (thread == null)
		{
			handlers.ready = cpp.Function.fromStaticFunction(ready);
			handlers.disconnected = cpp.Function.fromStaticFunction(disconnected);
			handlers.errored = cpp.Function.fromStaticFunction(errored);
			Application.current.onExit.add(_ -> Discord.Shutdown());
			thread = Thread.create(() -> while (true)
			{
				#if DISCORD_DISABLE_IO_THREAD
				Discord.UpdateConnection();
				#end

				Discord.RunCallbacks();

				Sys.sleep(5);
			});
			Log.info('Discord RPC Initialized');
		}

		Discord.Initialize(cpp.ConstCharStar.fromString(rpcID), cpp.RawPointer.addressOf(handlers), 1, null);
	}

	public static function change(?details:String, ?state:String, ?smallImageKey:String, ?smallImageText:String, ?largeImageKey:String):Void
	{
		presence.details = details;
		presence.state = state;
		presence.smallImageKey = smallImageKey;
		presence.smallImageText = smallImageText;
		if (largeImageKey != null)
			presence.largeImageKey = largeImageKey;
		update();
	}

	static function ready(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		var username:String = request[0].username;
		final globalName:String = request[0].globalName;
		final discriminator:Int = Std.parseInt(request[0].discriminator);

		if (discriminator != 0)
			username += '#$discriminator';

		Log.info('Discord RPC Connected: $globalName ($username)');

		presence.startTimestamp = Std.int(Date.now().getTime() * 0.001);
		change('Initializing...', null, null, null, 'icon');
	}

	static function disconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		var msg = cast(message, String);
		Log.warn('Discord RPC Disconnected: Code $errorCode, message: $msg');
	}

	static function errored(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		var msg = cast(message, String);
		Log.error('Discord RPC Error: Code $errorCode, message: $msg');
	}

	static function update():Void
	{
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(presence));
	}

	static function set_rpcID(val:String):String
	{
		var change = rpcID != val;
		rpcID = val;
		if (change)
		{
			Discord.Shutdown();
			init();
		}
		return val;
	}
}
