package objects;

import flixel.util.FlxStringUtil;
import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

class EngineInfo extends TextField
{
	public var curFPS:Int;
	public var curMemory:Float;

	var deltaTimeout:Float = 0.0;
	@:noCompletion private var times:Array<Float>;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		curFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat('VCR OSD Mono', 14, color);
		autoSize = LEFT;
		multiline = true;
		alpha = .75;
		text = 'FPS: ';

		times = [];
	}

	private override function __enterFrame(deltaTime:Float):Void
	{
		// prevents the overlay from updating every frame, why would you need to anyways
		if (deltaTimeout > 1000)
		{
			deltaTimeout = 0.0;
			return;
		}

		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		curFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		updateText();
		deltaTimeout += deltaTime;
	}

	public dynamic function updateText():Void
	{ // so people can override it in hscript
		text = 'FPS: ${curFPS}\nMemory: ${FlxStringUtil.formatBytes(System.totalMemory)}';

		if (curFPS < FlxG.drawFramerate * .75)
			textColor = FlxColor.interpolate(0xFF2E0000, 0xFF004CFF, curFPS / (FlxG.drawFramerate * .75));
		else
			textColor = 0xFF004CFF;
	}
}
