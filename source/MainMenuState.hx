package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.util.FlxTimer;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

using StringTools;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.5.2h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	
	var optionShit:Array<String> = [
		'story mode',
		'freeplay',
		'options',
		'donate',
		'deltarune'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var debugKeys:Array<FlxKey>;

	var colorBlack:FlxSprite;
	var soulThing:FlxSprite;

	override function create()
	{
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end
		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite();
		bg.frames = Paths.getSparrowAtlas('menu/AnimatedBG','preload');
		bg.animation.addByPrefix('idle', "bg", 24);
		bg.animation.play('idle');
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.02;
		bg.x = 166.3;
		bg.y = -26.05;
		bg.setGraphicSize(Std.int(bg.width = 949.85));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = false;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		var select = new FlxSprite(306, 144.4).loadGraphic(Paths.image('menu/file','preload'));
		select.updateHitbox();
		select.antialiasing = false;
		select.scrollFactor.set();
		add(select);

		colorBlack = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, 0xFF04021C);
		colorBlack.scrollFactor.set();
		colorBlack.updateHitbox();
		colorBlack.alpha = 0.05;
		add(colorBlack);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);
		var scale:Float = 1;

		var tex = Paths.getSparrowAtlas('menu/MainMenu','preload');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite();
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = false;

			menuItem.x = 346.8;
			switch(menuItem.ID)
			{
				case 0:
					menuItem.x = 346;
					menuItem.y = 202.9;
				case 1:
					menuItem.x = 346;
					menuItem.y = 327.8;
				case 2:
					menuItem.x = 346;
					menuItem.y = 454.45;
				case 3:
					menuItem.x = 345.9;
					menuItem.y = 591.2;
				case 4:
					menuItem.x = 345.9;
					menuItem.y = 645.7;
				case 5:
					menuItem.x = 763.1;
					menuItem.y = 586.75;
				case 6:
					menuItem.x = 763.1;
					menuItem.y = 645.7;
			}
		}

		FlxG.camera.follow(camFollowPos, null, 1);

		soulThing = new FlxSprite().loadGraphic(Paths.image('menu/soul','preload'));
		soulThing.x = 377;
		soulThing.updateHitbox();
		soulThing.setGraphicSize(Std.int(bg.width = 26.3));
		soulThing.antialiasing = false;
		soulThing.scrollFactor.set();
		add(soulThing);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Determination Sans", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Vs Queen Mod | Programmed by Crimson", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("Determination Sans", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				if (optionShit[curSelected] == 'deltarune')
				{
					CoolUtil.browserLoad('https://deltarune.com/');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		
		switch(curSelected)
		{
			case 0:
				FlxTween.tween(soulThing,{y: 252, alpha: 1}, 0.1, {ease: FlxEase.quadInOut});
			case 1:
				FlxTween.tween(soulThing,{y: 382.35, alpha: 1}, 0.1, {ease: FlxEase.quadInOut});
			case 2:
				FlxTween.tween(soulThing,{y: 502, alpha: 1}, 0.1, {ease: FlxEase.quadInOut});
			case 3,4,5,6:
				FlxTween.tween(soulThing, {y: 602, alpha: 0}, 0.1, {ease: FlxEase.quadInOut});
		}	
		
		menuItems.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');
				spr.alpha = 0.5;
				if (spr.ID == curSelected)
				{
					spr.animation.play('selected');
					spr.alpha = 1;
					if (curSelected <= 2)
						FlxTween.tween(camFollow, {x: spr.getGraphicMidpoint().x, y: spr.getGraphicMidpoint().y}, 0.4, {ease: FlxEase.quadInOut});
				}
			});
		}
	}