package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;

	var text:FlxText;

	override function create()
	{
		#if (mobileC || mobileCweb) FlxG.save.data.mobileControls = ClientPrefs.mobileControls; #end

		if (!ClientPrefs.warnings)
		{
			MusicBeatState.switchState(new TitleState());
			leftState = true;
			return;
		}

		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);
		#if (mobileC || mobileCweb)
		warnText = new FlxText(0, 0, FlxG.width, "Hey, watch out!\n
			This Mod contains some flashing lights, \njumpscares, and disturbing content\n
			Press ENTER/A to disable them now or go to Options Menu.\n
			Press ESCAPE/B to ignore this message.\n\nWe hope you like it.", 32);
		#else
		warnText = new FlxText(0, 0, FlxG.width, "Hey, watch out!\n
			This Mod contains some flashing lights, \njumpscares, and disturbing content\n
			Press ENTER to disable them now or go to Options Menu.\n
			Press ESCAPE to ignore this message.\n\nWe hope you like it.", 32);
		#end
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
		text = new FlxText(0, warnText.y + 450, FlxG.width, "PS: Check out the options menu to disable this warning.", 16);
		text.screenCenter(X);
		text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER);
		add(text);
		#if (mobileC || mobileCweb)
		if (FlxG.save.data.mobileControls)
		{
			addVirtualPad(NONE, A_B);
		}
		#end
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!leftState)
		{
			var accept:Bool = controls.ACCEPT;
			var back:Bool = controls.BACK;
			if (accept || back)
			{
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if (!back)
				{
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					for (i in [warnText, text])
					{
						FlxFlicker.flicker(i, 1, 0.1, false, true, _ ->
						{
							new FlxTimer().start(0.5, _ ->
							{
								MusicBeatState.switchState(new TitleState());
							});
						});
					}
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
					for (i in [warnText, text])
						FlxTween.tween(i, {alpha: 0}, 1, {onComplete: _ -> MusicBeatState.switchState(new TitleState())});
				}
			}
		}
	}
}
