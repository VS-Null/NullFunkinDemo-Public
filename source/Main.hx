package;

import flixel.FlxG;
import flixel.FlxGame;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;
import lime.app.Application;
import lime.system.System as LimeSystem;
#if DISCORD_ALLOWED
import Discord.DiscordClient;
#end
import SSPlugin as ScreenShotPlugin;

using StringTools;

class Main extends Sprite
{
	var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: TitleState, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPS;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
		openfl.system.System.gc();
		#if cpp
		cpp.NativeGc.enable(true);
		cpp.NativeGc.run(true);
		#end
	}

	public function new()
	{
		super();

		SUtil.uncaughtErrorHandler();

		#if windows
		@:functionCode("
		#include <windows.h>
		setProcessDPIAware() // allows for more crisp visuals
		")
		#end

		final stageWidth:Int = Lib.current.stage.stageWidth;
		final stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			final ratioX:Float = stageWidth / game.width;
			final ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		ClientPrefs.loadDefaultKeys();
		SUtil.checkFiles();
		addChild(new FlxGame(game.width, game.height, game.initialState, #if (flixel < "5.0.0") game.zoom, #end game.framerate, game.framerate,
			game.skipSplash, game.startFullscreen));

		#if !web FlxG.plugins.add(new ScreenShotPlugin()); #end

		fpsVar = new FPS(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		if (fpsVar != null)
			fpsVar.visible = ClientPrefs.showFPS;

		#if html5
		FlxG.autoPause = FlxG.mouse.visible = false;
		#end

		#if DISCORD_ALLOWED
		if (!DiscordClient.isInitialized)
		{
			DiscordClient.initialize();
			Application.current.window.onClose.add(function()
			{
				DiscordClient.shutdown();
			});
		}
		#end
	}
}
