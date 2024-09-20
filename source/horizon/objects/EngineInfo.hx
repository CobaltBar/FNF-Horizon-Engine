package horizon.objects;

import lime.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;
import sys.io.Process;

// Based on PsychEngine's FPSCounter.hx
class EngineInfo extends TextField
{
	public var curFPS:Int;
	public var curMemory:Float;

	@:noCompletion var deltaTimeout:Float = 0.0;
	@:noCompletion var times:Array<Float>;

	static var libText:String = '\n\n';

	public function new()
	{
		super();

		// https://askubuntu.com/a/988612
		var cpuProc = new Process(#if windows 'wmic cpu get name' #elseif linux 'lscpu | grep \'Model name\' | cut -f 2 -d \":\" | awk \'{$1=$1}1\'' #end);

		var cpu:String = 'N/A';

		if (cpuProc.exitCode() == 0)
		{
			var arr = cpuProc.stdout.readAll().toString().trim().split('\n');
			cpu = arr[arr.length - 1];
		}

		// Credit to CoreCat for the CPU, GPU, and OS data
		libText += 'OS:  ${System.platformLabel} ${System.platformVersion}\n';
		libText += 'CPU: $cpu\n';
		libText += 'GPU: ${@:privateAccess Std.string(FlxG.stage.context3D.gl.getParameter(FlxG.stage.context3D.gl.RENDERER)).split("/")[0].trim()}\n\n';

		libText += 'Haxe:          ${LibraryMacro.getLibVersion("haxe")}\n';
		libText += 'Flixel:        ${Std.string(FlxG.VERSION).substr(11)}\n';
		libText += 'Flixel Addons: ${LibraryMacro.getLibVersion("flixel-addons")}\n';
		libText += 'OpenFL:        ${LibraryMacro.getLibVersion("openfl")}\n';
		libText += 'Lime:          ${LibraryMacro.getLibVersion("lime")}';

		this.x = 5;
		this.y = 5;

		curFPS = FlxG.updateFramerate;
		selectable = mouseEnabled = false;
		defaultTextFormat = new TextFormat(Path.font("JetBrainsMonoNL-SemiBold"), 16, 0xFFFFFF);
		text = 'FPS: ';

		autoSize = LEFT;
		multiline = true;
		alpha = .75;

		times = [];
	}

	override function __enterFrame(deltaTime:Float):Void
	{
		final now:Float = haxe.Timer.stamp() * 1000;
		times.push(now);
		while (times[0] < now - 1000)
			times.shift();

		if (deltaTimeout < 100)
		{
			deltaTimeout += deltaTime;
			return;
		}

		updateText();
		deltaTimeout = 0;
	}

	public dynamic function updateText():Void
	{
		curFPS = times.length < FlxG.updateFramerate ? times.length : FlxG.updateFramerate;
		curMemory = #if cpp cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE) #elseif hl hl.Gc.stats().currentMemory #else System.totalMemory #end;

		text = 'FPS: ${curFPS}\nMemory: ${Util.formatBytes(cast(curMemory, UInt))} ${Constants.debugDisplay ? libText : ''}';
	}
}
