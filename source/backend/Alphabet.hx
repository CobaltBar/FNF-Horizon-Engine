package backend;

class Alphabet extends FlxSpriteGroup
{
	public function new(x:Float, y:Float, text:String, bold:Bool, alignment:FlxTextAlign, scale:Float = 1, offsetX:Float = 0, offsetY:Float = 0,
			?antiAliasing:Bool, seperation:Float = 0, ?icon:String, ?winningIcon:Bool)
	{
		super(x + offsetX, y - offsetY);
		var chars:Array<String> = text.split("");
		var letterWidth:Float = 0;
		for (i in 0...chars.length)
		{
			var animName:String = chars[i];
			var char:FlxSprite = Util.createSparrowSprite(0, 0, "alphabet", scale, antiAliasing);
			if (animName == "\r")
				continue;
			else if (animName == "\n")
			{
				y += 80;
				continue;
			}
			else if (animName == " ")
			{
				letterWidth += 35 * scale;
				continue;
			}
			else if (animName == "&")
				animName = "ampersand";
			else if (animName == ".")
				animName = "bullet";
			else if (animName == "'")
			{
				animName = "apostrophe";
				char.y -= char.height / 2;
			}
			else if (animName == "-")
				char.y -= char.height / 4;
			else if (animName == "\\")
				animName = "back slash";
			else if (animName == "!")
				animName = "exclamation";
			else if (animName == "/")
				animName = "forward slash";
			else if (animName == "¡")
				animName = "inverted exclamation";
			else if (animName == "¿")
				animName = "inverted question";
			else if (animName == '"')
			{
				animName = "quote";
				char.y -= char.height / 2;
			}
			else if (animName == "“")
			{
				animName = "start quote";
				char.y -= char.height / 2;
			}
			else if (animName == "”")
			{
				animName = "end quote";
				char.y -= char.height / 2;
			}
			else if (animName == "*")
				char.y -= char.height / 2;
			if (bold)
				animName += " bold";
			else if (animName.toLowerCase() != animName)
				animName += " uppercase";
			else if (animName.toLowerCase() == animName)
				animName += " lowercase";
			else
				animName += " normal";
			animName = animName.toLowerCase();
			char.animation.addByPrefix("idle", animName, 24);
			char.animation.play("idle");
			char.updateHitbox();
			char.centerOffsets();
			char.x = letterWidth;
			char.y -= char.height;
			letterWidth += char.width;
			add(char);
		}
		if (icon != null)
		{
			var icon = Util.createIcon(letterWidth, 0, icon, winningIcon, scale, antiAliasing);
			add(icon);
		}
		switch (alignment)
		{
			case LEFT:
			case JUSTIFY:
			case CENTER:
				this.x -= this.width / 2;
			case RIGHT:
				this.x -= this.width;
		}
	}
}
