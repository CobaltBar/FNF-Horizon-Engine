package horizon.util;

import haxe.Exception;
import openfl.text.TextField;
import openfl.text.TextFormat;

@:publicFields
class Util
{
	static function error(desc:String, fatal:Bool = false, ?err:Exception):Void
	{
		Log.error(err == null ? desc : '$desc\n${err.details()}');
		if (fatal)
			FlxG.switchState(() -> new ErrorState());
	}

	@:keep static inline function quadBezier(a:FlxPoint, b:FlxPoint, c:FlxPoint, p:Float):FlxPoint
		return FlxPoint.weak(FlxMath.lerp(FlxMath.lerp(a.x, b.x, p), FlxMath.lerp(b.x, c.x, p), p),
			FlxMath.lerp(FlxMath.lerp(a.y, b.y, p), FlxMath.lerp(b.y, c.y, p), p));

	// Thank you CoreCat!
	static final byteNames = ["B", "KB", "MB", "GB", "TB", "PB"];

	static function formatBytes(bytes:Float):String
	{
		if (bytes == 0)
			return "0B";

		var power = Std.int(Math.log(bytes) / Math.log(1024));
		return '${FlxMath.roundDecimal(bytes / Math.pow(1024, power), 2)}${byteNames[power]}';
	}

	static function applyTextFieldMarkup(textField:TextField, input:String, rules:Array<{format:TextFormat, marker:String}>):Void
	{
		if (rules == null || rules.length == 0)
			return;
		var originalText:String = textField.text;

		if (originalText != input)
			textField.text = input; // Only set the text if it's different.

		var rangeStarts:Array<Int> = [];
		var rangeEnds:Array<Int> = [];
		var rulesToApply:Array<{format:TextFormat, marker:String}> = [];

		for (rule in rules)
		{
			if (rule.marker == null || rule.format == null)
				continue;

			var start:Bool = false;
			var markerLength:Int = rule.marker.length;
			if (!input.contains(rule.marker))
				continue;

			for (charIndex in 0...input.length)
			{
				if (input.substr(charIndex, markerLength) != rule.marker)
					continue;

				if (start)
				{
					start = false;
					rangeEnds.push(charIndex);
				}
				else
				{
					start = true;
					rangeStarts.push(charIndex);
					rulesToApply.push(rule);
				}
			}

			if (start)
				rangeEnds.push(-1);
		}

		for (rule in rules)
			input = input.split(rule.marker).join("");

		for (i in 0...rangeStarts.length)
		{
			var delIndex:Int = rangeStarts[i];
			var markerLength:Int = rulesToApply[i].marker.length;

			for (j in 0...rangeStarts.length)
			{
				if (rangeStarts[j] > delIndex)
					rangeStarts[j] -= markerLength;
				if (rangeEnds[j] > delIndex)
					rangeEnds[j] -= markerLength;
			}

			delIndex = rangeEnds[i];
			for (j in 0...rangeStarts.length)
			{
				if (rangeStarts[j] > delIndex)
					rangeStarts[j] -= markerLength;
				if (rangeEnds[j] > delIndex)
					rangeEnds[j] -= markerLength;
			}
		}

		textField.text = input;

		for (i in 0...rangeStarts.length)
		{
			var startIdx:Int = rangeStarts[i];
			var endIdx:Int = rangeEnds[i];
			if (endIdx == -1)
				endIdx = input.length;
			textField.setTextFormat(rulesToApply[i].format, startIdx, endIdx);
		}
	}
}
