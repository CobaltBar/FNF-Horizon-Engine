package horizon.objects;

@:publicFields
class Alphabet extends FlxSpriteGroup
{
	var align(default, set):FlxTextAlign;
	var text(default, set):String;
	var bold:Bool;
	var textScale:Float;

	private var widths:Array<Float> = [];
	private var lines:Array<Array<FlxSprite>> = [];
	private var maxWidth:Float = 0;

	// TODO autodetect?
	private var seperateHeight:Float = 86;

	private static var alphabetGroup:FlxSpriteGroup = new FlxSpriteGroup();
	private static final letterRegex = ~/^[a-zA-Z]+$/;

	function new(x:Float, y:Float, text:String, bold:Bool, align:FlxTextAlign, scale:Float = 1)
	{
		super(x, y);

		this.bold = bold;
		textScale = scale;
		@:bypassAccessor this.align = align;

		this.text = text;
	}

	function updateText(val:String):Void
	{
		for (line in lines)
			for (char in line)
				char.kill();

		lines = [];
		widths = [];
		maxWidth = 0;
		for (i => text in val.split('\n'))
		{
			var letterWidth:Float = 0;
			lines[i] = [];

			for (ch in text.split(''))
			{
				var name = ch;

				switch (name)
				{
					case '\r':
						continue;
					case ' ':
						letterWidth += 30 * textScale;
						continue;
				}

				var char = alphabetGroup.recycle(FlxSprite, () -> Create.atlas(0, 0, Path.sparrow('alphabet')));
				char.x = char.angle = 0;
				char.y = char.height;
				char.alpha = 1;
				char.clipRect = null;
				char.color = 0xFFFFFFFF;
				char.flipX = char.flipY = false;
				char.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);
				if (char.animation.exists('idle'))
					char.animation.remove('idle');

				switch (name)
				{
					case "'" | '“' | '”' | '*' | '^':
						char.y -= char.height * .5;
					case '-' | '+':
						char.y -= char.height * .25;
					case '"':
						name = 'quote';
						char.y -= char.height * .5;
					case '?':
						name = 'question';
					case '&':
						name = 'ampersand';
					case '<':
						name = 'less';
				}

				if (bold)
					name += ' bold';
				else if (letterRegex.match(ch))
				{
					if (name == 'y')
						char.y += char.height * .15;
					name += name.toLowerCase() != name ? ' uppercase' : ' lowercase';
				}
				else
					name += ' normal';
				name = name.toLowerCase();

				char.animation.addByPrefix('idle', name, 24);
				char.animation.play('idle');
				char.scale.set(textScale, textScale);
				char.updateHitbox();
				char.centerOffsets();
				char.x = letterWidth;
				char.y -= char.height;
				char.y += seperateHeight * i * textScale;
				letterWidth += char.width + (2 * textScale);
				add(char);
				lines[i].push(char);
			}

			widths.push(letterWidth);
			if (letterWidth > maxWidth)
				maxWidth = letterWidth;
		}

		this.align = align;
	}

	@:noCompletion function set_text(val:String):String
	{
		updateText(val);
		return text = val;
	}

	@:noCompletion function set_align(val:FlxTextAlign):FlxTextAlign
	{
		if (val == CENTER)
			for (i => line in lines)
				for (char in line)
					char.x -= (maxWidth - widths[i]) * .5;
		else if (val == RIGHT)
			for (i => line in lines)
				for (char in line)
					char.x -= maxWidth - widths[i];

		if (val == CENTER)
			for (i => line in lines)
				for (char in line)
					char.x += (maxWidth - widths[i]) * .5;
		else if (val == RIGHT)
			for (i => line in lines)
				for (char in line)
					char.x += maxWidth - widths[i];
		return align = val;
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
