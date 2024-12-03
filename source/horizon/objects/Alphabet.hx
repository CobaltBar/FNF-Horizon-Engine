package horizon.objects;

@:publicFields
class Alphabet extends FlxSpriteGroup
{
	var align(default, set):FlxTextAlign;
	var text(default, set):String;
	var bold:Bool;
	var textScale:Float;

	private var widths:Array<Float> = [];
	private var charPos:Array<Array<Float>> = [];
	private var lines:Array<Array<FlxSprite>> = [];
	private var maxWidth:Float = 0;
	private var maxHeight:Float = 0;

	// Static group used for recycling between alphabets, cleared in preStateCreate
	private static var alphabetGroup:FlxSpriteGroup = new FlxSpriteGroup();
	private static final letterRegex = ~/^[a-zA-Z]+$/;

	static function init():Void
	{
		FlxG.signals.preStateCreate.add(state -> @:privateAccess
		{
			for (member in Alphabet.alphabetGroup.members)
				member.destroy();
			Alphabet.alphabetGroup.clear();
		});
	}

	function new(x:Float, y:Float, text:String, bold:Bool, align:FlxTextAlign, scale:Float = 1)
	{
		super(x, y);

		@:bypassAccessor this.align = align;
		this.bold = bold;
		textScale = scale;

		this.text = text;
	}

	function updateText(?val:String):Void
	{
		for (line in lines)
			for (char in line)
				char.kill();

		var oldWidths = widths;
		lines = [];
		widths = [];
		maxWidth = maxHeight = 0;
		val ??= text;

		for (i => text in val.replace('\r', '').split('\n'))
		{
			var letterTracker:Float = 0;
			lines[i] = [];

			for (ch in text.split(''))
			{
				if (ch == ' ')
				{
					letterTracker += 30 * textScale;
					continue;
				}

				var animName = switch (ch)
				{
					case '?':
						'question';
					case '&':
						'ampersand';
					case '<':
						'less';
					case '"':
						'quote';
					default:
						ch;
				}

				if (bold)
					animName += ' bold';
				else if (letterRegex.match(ch))
					animName += animName.toLowerCase() != animName ? ' uppercase' : ' lowercase';
				else
					animName += ' normal';
				animName = animName.toLowerCase();

				var char = alphabetGroup.recycle(FlxSprite, Create.atlas.bind(0, 0, Path.atlas('alphabet')));
				if (char.animation.exists('idle'))
					char.animation.remove('idle');
				char.animation.addByPrefix('idle', animName, 24);
				char.animation.play('idle');
				char.scale.set(textScale, textScale);
				char.updateHitbox();

				char.x = char.y = char.angle = 0;
				char.alpha = 1;
				char.clipRect = null;
				char.color = 0xFFFFFFFF;
				char.flipX = char.flipY = false;
				char.setColorTransform();

				if (char.height > maxHeight)
					maxHeight = char.height;

				switch (ch)
				{
					case "'" | '“' | '”' | '*' | '^' | '"' | '-':
						char.y -= char.height;
					case '+':
						char.y -= char.height * .25;
					case 'y':
						if (!bold)
							char.y -= char.height * .15;
				}

				char.x = letterTracker;
				char.y -= char.height;

				letterTracker += char.width + (2 * textScale);
				add(char);
				lines[i].push(char);
			}

			widths.push(letterTracker);

			if (oldWidths != null && oldWidths[i] != 0 && (align == CENTER || align == RIGHT))
				for (char in lines[i])
					char.x -= (widths[i] - oldWidths[i]) * (align == CENTER ? .5 : 1);

			if (letterTracker > maxWidth)
				maxWidth = letterTracker;
		}

		for (i => line in lines)
			for (char in line)
				char.y += maxHeight * (i + 1);

		width = maxWidth;
		this.align = align;
	}

	@:noCompletion function set_text(val:String):String
	{
		updateText(val);
		return text = val;
	}

	@:noCompletion function set_align(val:FlxTextAlign):FlxTextAlign
	{
		if (align == CENTER || align == RIGHT)
			for (i => line in lines)
				for (char in line)
					char.x -= (maxWidth - widths[i]) * (align == CENTER ? .5 : 1);

		if (val == CENTER || val == RIGHT)
			for (i => line in lines)
				for (char in line)
					char.x += (maxWidth - widths[i]) * (val == CENTER ? .5 : 1);

		charPos = [];
		for (i => char in members)
			charPos[i] = [char.x, char.y];

		return align = val;
	}

	@:noCompletion override function set_angle(val:Float):Float
	{
		super.set_angle(val);

		for (i => member in members)
		{
			member.setPosition(charPos[i][0], charPos[i][1]);
			member.updateTrig();
			var offX = member.x - origin.x;
			var offY = member.y - origin.y;
			member.x = x + (offX * member._cosAngle - offY * member._sinAngle) + origin.x;
			member.y = y + (offY * member._cosAngle + offX * member._sinAngle) + origin.y;
		}

		return val;
	}

	override function destroy():Void
	{
		for (line in lines)
			for (char in line)
			{
				char.kill();
				remove(char, true);
			}
		lines = [];
		super.destroy();
	}

	override function setColorTransform(redMultiplier = 1.0, greenMultiplier = 1.0, blueMultiplier = 1.0, alphaMultiplier = 1.0, redOffset = 0.0,
			greenOffset = 0.0, blueOffset = 0.0, alphaOffset = 0.0):Void
		for (member in members)
			member.setColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
}
