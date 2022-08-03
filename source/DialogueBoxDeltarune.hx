package;

import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import haxe.Json;
import haxe.format.JsonParser;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.utils.Assets;

using StringTools;

class DialogueBoxDeltarune extends FlxSpriteGroup
{
	var dialogue:FlxTypeText;
	var dots:FlxTypeText;

	public var finishThing:Void->Void;
	public var nextDialogueThing:Void->Void = null;
	public var skipDialogueThing:Void->Void = null;

	public var box:FlxSprite;
	public var character:FlxSprite;
	public var dialogueDelay:Float = 0.04;

	public var isEnding:Bool = false;

	public var arrayText:Array<String> = [];
	public var arrayCharacters:Array<String> = [];

	public var curCharacter:String = "";

	public function new(curSong:String = '', ?song:String = null)
	{
		super();

		if (song == null || song.length <= 0)
			song = 'backgroundDialogueSong';

		if(song != null && song != '') {
			FlxG.sound.playMusic(Paths.music(song), 0);
			FlxG.sound.music.fadeIn(1, 0, 0.6);
		}

		setupText(curSong);
		curCharacter = arrayCharacters[0];

		box = new FlxSprite();
		box.frames = Paths.getSparrowAtlas('deltarunebox-box');
		box.animation.addByPrefix('BOXdeltarune', 'speech bubble normal0', 24);
		box.animation.play('BOXdeltarune', true);
		box.scrollFactor.set();
		box.antialiasing = false;
		box.scale.set(1.4, 1.4);
		box.updateHitbox();
		box.screenCenter();
		box.y += 200;
		add(box);

		character = new FlxSprite().loadGraphic(Paths.image('dialogue/' + curCharacter));
		character.scrollFactor.set();
		character.antialiasing = false;
		character.setGraphicSize(Std.int(character.width * 1.4));
		character.updateHitbox();
		character.setPosition(box.x + 38, box.y + 40);
		add(character);

		dialogue = new FlxTypeText(box.x + 245, box.y + 42, 555, "");
		dialogue.scrollFactor.set();
		dialogue.setFormat(Paths.font('determination.ttf'), 27, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dialogue.sounds = [FlxG.sound.load(Paths.sound('queen'), 0.6)];
		dialogue.antialiasing = false;
		add(dialogue);

		dots = new FlxTypeText(dialogue.x + 490, dialogue.y + 117, 80, 'Press Enter To Skip');
		dots.scrollFactor.set();
		dots.setFormat(Paths.font('determination.ttf'), 35, FlxColor.RED, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		dots.antialiasing = false;
		dots.waitTime = 2;
		dots.eraseCallback = function(){
			dots.start(0.45, true, true);
		};
		add(dots);

		startDialogue();
	}

	var holdTime:Float = 0;
	var dialogueStarted:Bool = false;
	var dialogueEnded:Bool = false;
	override function update(elapsed:Float)
	{
		if (!isEnding)
		{
			if (FlxG.keys.justPressed.ENTER || FlxG.keys.justPressed.SPACE)
			{
				if (!dialogueEnded)
				{
					dialogue.skip();
				}
				else
				{
					startDialogue();
				}
			}
			else if (FlxG.keys.pressed.ENTER || FlxG.keys.pressed.SPACE)
			{
				var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
				holdTime += elapsed;
				var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

				if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
				{
					if (!dialogueEnded)
					{
						dialogue.skip();
					}
					else
					{
						startDialogue();
					}
				}
			}
		}

		super.update(elapsed);
	}

	function startDialogue():Void
	{	
		if (dialogue != null && arrayText[0] != null)
		{
			dialogueStarted = true;
			dots.visible = false;

			changeCharacter();

			dialogue.resetText(arrayText.shift());
			dialogue.start(dialogueDelay, true);

			dialogueEnded = false;
			dialogue.completeCallback = function() {
				dialogueEnded = true;
				dots.visible = true;
				dots.start(0.45, true, true);
			};
		}
		else
		{
			endDialogue();
		}
		
		if(nextDialogueThing != null) {
			nextDialogueThing();
		}
	}

	function changeCharacter():Void
	{
		if (arrayCharacters[0] != null)
		{
			curCharacter = arrayCharacters.shift();
			character.loadGraphic(Paths.image('dialogue/' + curCharacter));

			switch(curCharacter)
			{
				case 'boyfriend':
					dialogue.sounds = [FlxG.sound.load(Paths.sound('boyfriend'), 0.6)];
					dialogueDelay = 0.042;
					box.animation.play('BOXdeltarune');
					dialogue.color = FlxColor.WHITE;
				default:
					dialogue.sounds = [FlxG.sound.load(Paths.sound('queen'), 0.6)];
					dialogueDelay = 0.042;
					box.animation.play('BOXdeltarune');
					dialogue.color = FlxColor.WHITE;
			}
			dots.color = dialogue.color;
		}
	}

	function endDialogue():Void
	{
		if (!isEnding)
		{
			isEnding = true;

			dots.visible = false;
			// escapeTextFade = true;

			if (FlxG.sound.music != null && FlxG.sound.music.playing)
				FlxG.sound.music.fadeOut(1.2, 0);

			FlxTween.tween(box, {alpha: 0}, 1);
			FlxTween.tween(character, {alpha: 0}, 1);
			FlxTween.tween(dialogue, {alpha: 0}, 1);

			new FlxTimer().start(3.2, function(tmr:FlxTimer)
			{
				finishThing();
				kill();
			});
		}
	}

	function setupText(curSong:String):Void
	{
		switch(curSong)
		{
			case 'queen':
				arrayText = [
					"How fun!!!",
					"Bap!",
					"Another round?",
					"Ok!",
					"Beep!!"
				];
				arrayCharacters = [
					'queenExcited',
					'boyHype',
					'queenPog',
					'queenHappy',
					'boyHype'
				];
			case 'boss attack':
				arrayText = [
					"How fun!!!",
					"Bap!",
					"Another round?",
					"Ok!",
					"Beep!!"
					];
				arrayCharacters = [
					'queenExcited',
					'boyHype',
					'queenPog',
					'queenHappy',
					'boyHype'
				];
			default:
				arrayText = [
					'HAHA Crimson was here'
				];
				arrayCharacters = [
					'queenPog'
				];
		}
	}
}