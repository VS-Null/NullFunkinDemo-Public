package;

#if DISCORD_ALLOWED
#if desktop
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types;
class DiscordClient
{
	public static var isInitialized:Bool = false;

	public function new():Void
	{
		trace("Discord Client starting...");

		var dahandler:DiscordEventHandlers = DiscordEventHandlers.create();
		dahandler.ready = cpp.Function.fromStaticFunction(onReady);
		dahandler.disconnected = cpp.Function.fromStaticFunction(onDisconnected);
		dahandler.errored = cpp.Function.fromStaticFunction(onError);
		Discord.Initialize("1097525175341305889", cpp.RawPointer.addressOf(dahandler), 1, null);

		trace("Discord Client started.");

		while (true)
		{
			#if DISCORD_DISABLE_IO_THREAD
			Discord.UpdateConnection();
			#end
			Discord.RunCallbacks();
			Sys.sleep(2);
		}

		Discord.Shutdown();
	}

	public static function shutdown():Void
	{
		Discord.Shutdown();
	}

	public static function initialize():Void
	{
		sys.thread.Thread.create(function()
		{
			new DiscordClient();
		});

		trace("Discord Client initialized");

		isInitialized = true;
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float):Void
	{
		var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		var discordPresence:DiscordRichPresence = DiscordRichPresence.create();
		discordPresence.details = details;
		discordPresence.state = state;
		discordPresence.largeImageKey = "icon";
		discordPresence.largeImageText = "Vs Null";
		discordPresence.smallImageKey = smallImageKey;
		discordPresence.startTimestamp = Std.int(startTimestamp / 1000);
		discordPresence.endTimestamp = Std.int(endTimestamp / 1000);
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onReady(request:cpp.RawConstPointer<DiscordUser>):Void
	{
		var requestPtr:cpp.Star<DiscordUser> = cpp.ConstPointer.fromRaw(request).ptr;

		trace('Discord: Connected to User (' + cast(requestPtr.username, String) + '#' + cast(requestPtr.discriminator, String) + ')');

		var discordPresence:DiscordRichPresence = DiscordRichPresence.create();
		discordPresence.details = "Game Started";
		discordPresence.state = null;
		discordPresence.largeImageKey = "icon";
		discordPresence.largeImageText = "Vs Null";
		Discord.UpdatePresence(cpp.RawConstPointer.addressOf(discordPresence));
	}

	private static function onDisconnected(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Disconnected (' + errorCode + ': ' + cast(message, String) + ')');
	}

	private static function onError(errorCode:Int, message:cpp.ConstCharStar):Void
	{
		trace('Discord: Error (' + errorCode + ': ' + cast(message, String) + ')');
	}
}
#elseif android
import android.kizzy.KizzyClient;
import haxe.Json;
import sys.FileSystem;
import sys.io.File;

using StringTools;

typedef Kizzy =
{
	token:String,
	status:String
}

class DiscordClient
{
	public static var isInitialized:Bool = false;
	static var dakizzy:Kizzy;

	public static function initialize():Void
	{
		if (!FileSystem.exists(SUtil.getStorageDirectory() + 'dcstuff.json'))
		{
			File.saveContent(SUtil.getStorageDirectory() + 'dcstuff.json', '{"token":"Your god damn token","status":"online"}');
		}
		dakizzy = Json.parse(File.getContent(SUtil.getStorageDirectory() + 'dcstuff.json'));
		var kizzyClient:KizzyClient = new KizzyClient(dakizzy.token);
		kizzyClient.setApplicationID('378534231036395521');
		kizzyClient.setName('VS Null DEMO');
		kizzyClient.setDetails('Game Started');
		kizzyClient.setState(null);
		kizzyClient.setStatus(dakizzy.status);
		kizzyClient.rebuildClient();

		isInitialized = true;
	}

	public static function shutdown():Void
	{
	}

	public static function changePresence(details:String, state:Null<String>, ?smallImageKey:String, ?hasStartTimestamp:Bool, ?endTimestamp:Float):Void
	{
		var startTimestamp:Float = hasStartTimestamp ? Date.now().getTime() : 0;

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		dakizzy = Json.parse(File.getContent(SUtil.getStorageDirectory() + 'dcstuff.json'));
		var kizzyClient:KizzyClient = new KizzyClient(dakizzy.token);
		kizzyClient.setApplicationID('378534231036395521');
		kizzyClient.setName('VS Null DEMO');
		kizzyClient.setDetails(details);
		if (hasStartTimestamp)
		{
			kizzyClient.setStartTimeStamps(Std.int(startTimestamp / 1000), true);
			kizzyClient.setStopTimeStamps(Std.int(endTimestamp / 1000), true);
		}
		kizzyClient.setStatus(dakizzy.status);
		kizzyClient.setState(state);
		kizzyClient.rebuildClient();
	}
}
#end
#end
