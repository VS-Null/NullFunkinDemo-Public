package;

import flixel.util.FlxSave;
import flixel.FlxG;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.utils.Assets;
#end
#if cpp
import cpp.vm.Gc;
#end

using StringTools;

class CoolUtil
{
	public static final defaultDifficulties:Array<String> = ['Normal', 'Hard'];
	public static final defaultDifficulty:String = 'Normal'; // The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float)
	{
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}

	inline public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null)
			num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if (fileSuffix != defaultDifficulty)
			fileSuffix = '-' + fileSuffix;
		else
			fileSuffix = '';

		return Paths.formatToSongPath(fileSuffix);
	}

	inline public static function difficultyString():String
	{
		return difficulties[PlayState.storyDifficulty].toUpperCase();
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
	{
		return Math.max(min, Math.min(max, value));
	}

	inline public static function coolTextFile(path:String):Array<String>
	{
		#if sys
		if (FileSystem.exists(path))
			return [for (i in File.getContent(path).trim().split('\n')) i.trim()];
		#else
		if (Assets.exists(path))
			return [for (i in Assets.getText(path).trim().split('\n')) i.trim()];
		#end

		return [];
	}

	inline public static function listFromString(string:String):Array<String>
		return string.trim().split('\n').map(str -> str.trim());

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
					{
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					}
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
					{
						countByColor[colorOfThisPixel] = 1;
					}
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		return [
			for (i in min...max)
				i
		];
	}

	// uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void
	{
		Paths.sound(sound, library);
	}

	public static function precacheMusic(sound:String, ?library:String = null):Void
	{
		Paths.music(sound, library);
	}

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	public static function getSavePath(folder:String = 'MemeHoovy'):String
	{
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}

	public static function getTotalRam():RAMType
	{
		#if (android || linux)
		try
		{
			var f = File.read('/proc/meminfo');
			var result = f.readAll().toString();
			if (result == "" || result == null || result.charAt(0) != "M")
				return null;
			var memTotalLine = result.split('\n')[0];
			memTotalLine = memTotalLine.replace(' ', '');
			memTotalLine = memTotalLine.replace('kB', '');
			memTotalLine = memTotalLine.replace('MemTotal:', '');

			return Std.parseInt(memTotalLine);
		}
		#elseif cpp
		return Math.abs(Gc.memInfo(0));
		#elseif sys
		return cast(cast(System.totalMemory, UInt), Float);
		#end
		return null;
	}
}

typedef RAMType = #if (android || linux) Null<Int>; #else Null<Float>; #end
