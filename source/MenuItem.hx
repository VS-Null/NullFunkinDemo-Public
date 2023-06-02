package;

import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class MenuItem extends FlxSprite
{
	public var targetY:Float = 0;

	public function new(x:Float, y:Float, weekName:String = '')
	{
		super(x, y);
		loadGraphic(Paths.image('storymenu/' + weekName));
		// trace('Test added: ' + WeekData.getWeekNumber(weekNum) + ' (' + weekNum + ')');
		antialiasing = ClientPrefs.globalAntialiasing;
	}

	private var isFlashing:Bool = false;

	inline public function startFlashing():Void
		isFlashing = true;

	var time:Float = 0;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		y = FlxMath.lerp(y, (targetY * 120) + 480, CoolUtil.boundTo(elapsed * 10.2, 0, 1));

		time += elapsed;

		if (isFlashing)
			color = (time % 0.1 > 0.05) ? FlxColor.WHITE : 0xFF33ffff;
	}
}
