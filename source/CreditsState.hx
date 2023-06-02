package;

#if DISCORD_ALLOWED
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	override function create()
	{
		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Credits", null);
		#end

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		#if MODS_ALLOWED
		var path:String = SUtil.getStorageDirectory() + 'modsList.txt';
		if (FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if (leMods.length > 1 && leMods[0].length > 0)
				{
					var modSplit:Array<String> = leMods[i].split('|');
					if (!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if (modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var pisspoop:Array<Array<String>> = [
			// Name - Icon name - Description - Link - BG Color
			['VS Null Team'],
			['MemeHoovy', 'sarv', 'Everything.', 'https://twitter.com/meme_hoovy', 'F592C4'],
			[
				'Wither362',
				'Wither',
				'Additional programming',
				'https://github.com/Wither362',
				'FF5F5F'
			],
			[
				'mcagabe19',
				'gabe',
				'Additional programming, and mobile port',
				'https://www.youtube.com/@mcagabe19',
				'7053A5'
			],
			[
				'pmcyt',
				'discord',
				'Charter and concept maker',
				'https://www.youtube.com/@portalmastercasper/',
				'8F0808'
			],
			['SonicYT', 'SonicYT', 'Charter', 'https://www.youtube.com/@SonicYT_1/', '4E72D2'],
			[
				'ohioAxolotl',
				'ohioaxolotl',
				'Artist',
				'https://www.youtube.com/@ohioaxolotlvr/',
				'FF228C'
			],
			[
				'Rey',
				'rey',
				'Musician',
				'https://www.youtube.com/@Reychronicallyonline/',
				'8F0094'
			],
			[''],
			['Special Thanks'],
			[
				'LeviXD',
				'discord',
				'Mental Support and being a good friend (And also my bestie)',
				'https://github.com/LEVIXDDLMAO',
				'FFFFFF'
			],
			[
				'AlongCameJosh',
				'discord',
				'Made the Null creepypasta and series',
				'https://www.youtube.com/@AlongCameJosh',
				'FFFFFF'
			],
			[
				'Hammler',
				'hammler',
				'Helped with some art',
				'https://www.youtube.com/c/BiancaKittyGamer/',
				'8F0808'
			],
			['The EXE Team', 'exe', 'Fight or flight, with some other stuff', '', '0058B7'],
			[''],
			['Psych Engine Team'],
			[
				'Shadow Mario',
				'shadowmario',
				'Main Programmer of Psych Engine',
				'https://twitter.com/Shadow_Mario_',
				'444444'
			],
			[
				'RiverOaken',
				'river',
				'Main Artist/Animator of Psych Engine',
				'https://twitter.com/RiverOaken',
				'B42F71'
			],
			[''],
			["Funkin' Crew"],
			[
				'ninjamuffin99',
				'ninjamuffin99',
				"Programmer of Friday Night Funkin'",
				'https://twitter.com/ninja_muffin99',
				'CF2D2D'
			],
			[
				'PhantomArcade',
				'phantomarcade',
				"Animator of Friday Night Funkin'",
				'https://twitter.com/PhantomArcade3K',
				'FADC45'
			],
			[
				'evilsk8r',
				'evilsk8r',
				"Artist of Friday Night Funkin'",
				'https://twitter.com/evilsk8r',
				'5ABD4B'
			],
			[
				'kawaisprite',
				'kawaisprite',
				"Composer of Friday Night Funkin'",
				'https://twitter.com/kawaisprite',
				'378FC7'
			]
		];

		for (i in pisspoop)
			creditsStuff.push(i);

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:Alphabet = new Alphabet(FlxG.width / 2, 300, creditsStuff[i][0], !isSelectable);
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if (isSelectable)
			{
				if (creditsStuff[i][5] != null)
					Paths.currentModDirectory = creditsStuff[i][5];

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if (curSelected == -1)
					curSelected = i;

				// fix for icons that are not the correct size
				if (icon.width > 150 && icon.height > 150)
				{
					icon.scale.set(0.5, 0.5);
					icon.x -= icon.xAdd - 10;
					icon.updateHitbox();
				}
			}
			else
				optionText.alignment = CENTERED;
		}

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		descText.scrollFactor.set();
		// descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		changeSelection();

		#if (mobileC || mobileCweb)
		if (FlxG.save.data.mobileControls)
		{
			addVirtualPad(UP_DOWN, A_B);
		}
		#end

		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (!quitting)
		{
			if (creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if (controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if (controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4))
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);

			if (controls.BACK)
			{
				if (colorTween != null)
					colorTween.cancel();

				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		for (item in grpOptions.members)
		{
			if (!item.bold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if (item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
			}
		}
		super.update(elapsed);
	}

	#if (flixel < "5.3.0")
	override function switchTo(nextState)
	{
		persistentUpdate = false;
		return super.switchTo(nextState);
	}
	#else
	override function startOutro(onOutroComplete:()->Void)
	{
		persistentUpdate = false;
		onOutroComplete();
	}
	#end

	var moveTween:FlxTween = null;

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do
		{
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		}
		while (unselectableCheck(curSelected));

		var newColor:Int = getCurrentBGColor();
		if (newColor != intendedColor)
		{
			if (colorTween != null)
				colorTween.cancel();

			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {onComplete: _ -> colorTween = null});
		}
		FlxG.log.add('intendedColor: $intendedColor');

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if (!unselectableCheck(bullShit - 1))
			{
				item.alpha = 0.6;
				if (item.targetY == 0)
					item.alpha = 1;
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if (moveTween != null)
			moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y: descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];

	function pushModCreditsToList(folder:String)
	{
		if (modsAdded.contains(folder))
			return;

		var creditsFile:String = null;
		if (folder != null && folder.trim().length > 0)
			creditsFile = Paths.mods(folder + '/data/credits.txt');
		else
			creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for (i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if (arr.length >= 5)
					arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}
		modsAdded.push(folder);
	}
	#end

	inline function getCurrentBGColor():Int
	{
		var bgColor:String = creditsStuff[curSelected][4];
		if (!bgColor.startsWith('0x'))
			bgColor = '0xFF' + bgColor;
		trace('Current color: ' + bgColor);
		return Std.parseInt(bgColor);
	}

	inline private function unselectableCheck(num:Int):Bool
		return creditsStuff[num].length <= 1;
}
