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

	static var debugText:String = '\n\nHorizon Engine Build ${Constants.horizonVer}\n';

	public function new()
	{
		super();

		// if the mac/ios stuff doesn't work blame lily
		// https://askubuntu.com/a/988612
		var cpuProc = new Process(#if windows 'wmic cpu get name' #elseif (linux || android) 'lscpu | grep \'Model name\' | cut -f 2 -d \":\" | awk \'{$1=$1}1\'' #elseif (mac
			|| ios) 'sysctl -a | grep brand_string | awk -F ": " \'{print $2}\'' #end);

		var cpu:String = 'N/A';

		if (cpuProc.exitCode() == 0)
		{
			var arr = cpuProc.stdout.readAll().toString().trim().split('\n');
			cpu = arr[arr.length - 1];
		}

		// Credit to CoreCat for the CPU, GPU, and OS data
		debugText += 'OS:  ${System.platformLabel} ${System.platformVersion}\n';
		debugText += 'CPU: $cpu\n';
		debugText += 'GPU: ${@:privateAccess Std.string(FlxG.stage.context3D.gl.getParameter(FlxG.stage.context3D.gl.RENDERER)).split('/')[0].trim()}\n\n';

		debugText += 'Haxe:          ${LibraryMacro.getLibVersion('haxe')}\n';
		debugText += 'Flixel:        ${LibraryMacro.getLibVersion('flixel')}\n';
		debugText += 'Flixel Addons: ${LibraryMacro.getLibVersion('flixel-addons')}\n';
		debugText += 'OpenFL:        ${LibraryMacro.getLibVersion('openfl')}\n';
		debugText += 'Lime:          ${LibraryMacro.getLibVersion('lime')}\n';
		debugText += 'HaxeUI-Core:   ${LibraryMacro.getLibVersion('haxeui-core')}\n';
		debugText += 'HaxeUI-Flixel: ${LibraryMacro.getLibVersion('haxeui-flixel')}\n';

		x = y = 5;

		curFPS = FlxG.updateFramerate;
		selectable = mouseEnabled = false;
		defaultTextFormat = new TextFormat(Path.font('JetBrainsMonoNL-SemiBold'), 14, 0xFFFFFF);
		text = 'Initializing...';

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
		curFPS = times.length < FlxG.drawFramerate ? times.length : FlxG.drawFramerate;
		curMemory = #if cpp cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE) #elseif hl hl.Gc.stats().currentMemory #else System.totalMemory #end;

		text = 'FPS: ${curFPS}';
		if (Settings.showMemory)
			text += '\nMemory: ${Util.formatBytes(curMemory)}';
		if (Constants.debugDisplay)
			text += debugText;
	}
}
