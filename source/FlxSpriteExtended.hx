package;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.FlxSprite;

/**
 * @author Duskiewhy
 * @author MemeHoovy
 */
// based on duskies code
class FlxSpriteExtended extends FlxSprite
{
	override function makeGraphic(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSpriteExtended
		return cast super.makeGraphic(Width, Height, Color, Unique, Key);

	inline public function makeSolid(Width:Int, Height:Int, Color:FlxColor = FlxColor.WHITE, Unique:Bool = false, ?Key:String):FlxSpriteExtended
	{
		var graphic:FlxGraphic = FlxG.bitmap.create(1, 1, Color, Unique, Key);
		frames = graphic.imageFrame;
		scale.set(Width, Height);
		updateHitbox();
		return this;
	}

	inline public function isAlive():Bool
		return alive == true;

	inline public function hideFull()
		alpha = 0;

	inline public function hide()
		alpha = 0.00001;

	inline public function show()
		alpha = 1;
}
