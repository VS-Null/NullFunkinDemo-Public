package stages;

import flixel.ui.FlxBar;
import flixel.text.FlxText;
import flixel.util.FlxTimer;

// an idea/concept pmcyt had
class Stampy extends BaseStage
{
	var fearUi:FlxSprite;
	var fearUiBg:FlxSprite;
	var fearTween:FlxTween;
	var fearTimer:FlxTimer;

	public var fearNo:Float = 0;
	public var fearBar:FlxBar;

	public static var isFear:Bool = false;

	var doFearCheck = false;
	var fearNum:FlxText;

	// original idea from me :-)
	var dodgeTimer:FlxTimer = null;
	var didDodge:Bool = false;
	var willFire:Bool = false;
	var canFire(get, never):Bool;

	inline function get_canFire():Bool
		return dad.curCharacter == 'target';

	override function create()
	{
		var bg:BGSprite = new BGSprite('stages/stampy/stage', -100, -100, 1, 0.9);
		bg.setGraphicSize(Std.int(bg.width * 1.5));
		bg.scrollFactor.set(1, 1);
		add(bg);

		if (dad.curCharacter == 'target')
		{
			fearUi = new FlxSprite().loadGraphic(Paths.image('fearbar'));
			fearUi.scrollFactor.set();
			fearUi.screenCenter();
			fearUi.x += 580;
			fearUi.y -= 50;

			fearUiBg = new FlxSprite(fearUi.x, fearUi.y).loadGraphic(Paths.image('fearbarBG'));
			fearUiBg.scrollFactor.set();
			fearUiBg.screenCenter();
			fearUiBg.x += 580;
			fearUiBg.y -= 50;
			add(fearUiBg);

			fearBar = new FlxBar(fearUi.x + 30, fearUi.y + 5, BOTTOM_TO_TOP, 21, 275, this, 'fearNo', 0, 100);
			fearBar.scrollFactor.set();
			fearBar.visible = true;
			fearBar.numDivisions = 1000;
			fearBar.createFilledBar(0x00000000, 0xFFFF0000);
			trace('bar added.');

			add(fearBar);
			add(fearUi);
			fearUiBg.cameras = [camHUD];
			fearBar.cameras = [camHUD];
			fearUi.cameras = [camHUD];
		}
	}

	override function update(elapsed:Float)
	{
		if (dad.curCharacter == 'target')
		{
			isFear = true;
			fearBar.visible = true;
			fearBar.filledCallback = () -> game.doDeathCheck(true);

			// this is such a shitcan method i really should come up with something better tbf
			if (fearNo >= 50 && fearNo < 59)
				game.health -= 0.1 * elapsed;
			else if (fearNo >= 60 && fearNo < 69)
				game.health -= 0.13 * elapsed;
			else if (fearNo >= 70 && fearNo < 79)
				game.health -= 0.17 * elapsed;
			else if (fearNo >= 80 && fearNo < 89)
				game.health -= 0.20 * elapsed;
			else if (fearNo >= 90 && fearNo < 99)
				game.health -= 0.35 * elapsed;

			if (game.health <= 0.01)
				game.health = 0.01;
		}

		// random time to fire, so it's unpredictable
		if (canFire && FlxG.random.bool(FlxG.random.int(30, 50)) == true)
		{
			var dodgeText:FlxText = new FlxText(0, 0, 0, 'Dodge!', 26);
			dodgeText.screenCenter();
			// dodgeText.visible = true;
			add(dodgeText);

			dodgeTimer = new FlxTimer().start(Conductor.crochet / 1000, _ ->
			{
				FlxG.sound.play(Paths.sound('alert'));
				if (controls.ACCEPT)
				{
					didDodge = true;
					// TODO: add dodge anims and such
					if (boyfriend.animation.exists('dodge'))
						boyfriend.playAnim('dodge', true);
					boyfriend.animation.finishCallback = name -> boyfriend.dance();
				}
			});
		}
		super.update(elapsed);
	}

	override function goodNoteHit(note:Note)
	{
		if (isFear)
			fearNo -= 0.1;
		super.goodNoteHit(note);
	}

	override function opponentNoteHit(note:Note)
	{
		if (dad.curCharacter == 'target')
		{
			fearNo += 0.15;
		}
		super.opponentNoteHit(note);
	}

	override function noteMiss(note:Note)
	{
		if (dad.curCharacter == 'target')
		{
			fearNo += 5;
		}
		super.noteMiss(note);
	}
}
