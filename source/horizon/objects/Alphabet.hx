package horizon.objects;

@:publicFields
class Alphabet extends FlxSpriteGroup
{
	var align(default, set):FlxTextAlign;
	var text(default, set):String;
	var bold:Bool;
	var textScale:Float;

	private var widths:Array<Float> = [];
	private var maxWidth:Float = 0;
	private var groups:Array<FlxSpriteGroup> = [];

	private static var alphabetGroup:FlxSpriteGroup = new FlxSpriteGroup();
	private static final letterRegex = ~/^[a-zA-Z]+$/;

	function new(x:Float, y:Float, text:String, bold:Bool, align:FlxTextAlign, scale:Float = 1)
	{
		super(x, y);

		this.bold = bold;
		textScale = scale;

		this.text = text;
	}

	function updateText(val:String):Void
	{
		for (group in groups)
			group.kill();
		groups = [];
		widths = [];
		maxWidth = 0;

		var i = 0;
		for (text in val.split('\n'))
		{
			var group:FlxSpriteGroup;
			add(group = new FlxSpriteGroup(0, 0));
			groups.push(group);
			var letterWidth:Float = 0;

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

				var char = alphabetGroup.recycle(FlxSprite, () -> return Create.atlas(0, 0, Path.sparrow('alphabet'), null, textScale));
				char.x = 0;
				char.y = 0;
				char.setColorTransform(1, 1, 1, 1, 0, 0, 0, 0);

				switch (name)
				{
					case '\'' | '“' | '”' | '*' | '^':
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
					name += name.toLowerCase() != name ? ' uppercase' : ' lowercase';
				else
					name += ' normal';
				name = name.toLowerCase();

				if (char.animation.exists('idle'))
					char.animation.remove('idle');
				char.animation.addByPrefix('idle', name, 24);
				char.animation.play('idle');
				char.updateHitbox();
				char.centerOffsets();
				char.x = letterWidth;
				char.y -= char.height;
				letterWidth += char.width;
				group.add(char);
			}

			widths.push(letterWidth);
			if (letterWidth > maxWidth)
				maxWidth = letterWidth;
			group.y += group.height * (i + 1);
			i++;
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
		switch (val)
		{
			case LEFT:
				for (group in groups)
					group.x = 0;
			case CENTER:
				for (i => group in groups)
					group.x = (maxWidth - widths[i]) * .5;
			case RIGHT:
				for (i => group in groups)
					group.x = maxWidth - widths[i];
			case JUSTIFY:
		}
		return align = val;
	}

	@:noCompletion override function destroy():Void
	{
		for (group in groups)
		{
			group.kill();
			remove(group, true);
			groups = [];
		}
		super.destroy();
	}

	public override function setColorTransform(redMultiplier = 1.0, greenMultiplier = 1.0, blueMultiplier = 1.0, alphaMultiplier = 1.0, redOffset = 0.0,
			greenOffset = 0.0, blueOffset = 0.0, alphaOffset = 0.0):Void
		for (group in groups)
			for (member in group)
				member.setColorTransform(redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset);
}
