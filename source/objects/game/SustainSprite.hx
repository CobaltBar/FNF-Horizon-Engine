package objects.game;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxRect;

/*
	Initially by RapperGF, Completed by Cobalt

	This file is dark flixel magic
 */
class SustainSprite extends FlxSpriteGroup
{
	public var tiles(default, set):Float = 1;
	public var body:TileSprite;
	public var tail:FlxSprite;

	var tileFrame(default, set):FlxGraphic;
	var yOff:Float = 0;

	public function new(tileFrame:FlxGraphic, ?xx:Float, ?yy:Float)
	{
		super(xx, yy);

		add(body = new TileSprite());
		add(tail = new FlxSprite());

		this.tileFrame = tileFrame;
	}

	@:noCompletion override function set_antialiasing(val:Bool):Bool
		return antialiasing = body.antialiasing = tail.antialiasing = val;

	@:noCompletion override function set_alpha(val:Float):Float
	{
		body.alpha = tail.alpha = val;
		return super.set_alpha(val);
	}

	@:noCompletion override function set_clipRect(rect:FlxRect):FlxRect
	{
		var realRect = super.set_clipRect(rect);
		body.clipRect = rect;
		body.clipRect = body.clipRect;
		tail.clipRect.x = rect.x;
		tail.clipRect.y = rect.y - body.frame.frame.height;
		tail.clipRect.width = rect.width;
		tail.clipRect.height = rect.height + body.frame.frame.height;
		tail.clipRect = tail.clipRect;
		return realRect;
	}

	override function updateHitbox()
	{
		body.updateHitbox();
		tail.updateHitbox();
		super.updateHitbox();
	}

	@:access(flixel.FlxSprite)
	@:noCompletion
	public function set_tiles(val:Float)
	{
		body.height = body._frame.frame.height = body.frame.frame.height = Math.ceil(val * body.frameHeight);
		flipY = flipY;
		return tiles = val;
	}

	@:noCompletion override function set_flipY(val:Bool):Bool
	{
		if (val)
			yOff = -(body.frame.frame.height * body.scale.y + tail.frame.frame.height * tail.scale.y / 3);
		else
			yOff = body.frame.frame.height * body.scale.y;

		return super.set_flipY(val);
	}

	@:noCompletion public function set_tileFrame(val:FlxGraphic)
	{
		body.frames = val.imageFrame;
		return tileFrame = val;
	}

	public inline function setScale(valX:Float, valY:Float)
	{
		body.scale.x = valX;
		body.scale.y = valY;
		tail.scale.x = valX;
		tail.scale.y = valY;
		updateHitbox();
	}

	override public function draw()
	{
		tail.x = body.x + (body.width - tail.width) * .5;
		tail.y = body.y + yOff;

		group.draw();
	}
}

class TileSprite extends FlxSprite
{
	override function getScreenBounds(?newRect:FlxRect, ?camera:FlxCamera):FlxRect
	{
		var rect = super.getScreenBounds(newRect, camera);
		rect.y = _frame.frame.height;
		return rect;
	}

	override function updateHitbox()
	{
		width = Math.abs(scale.x) * _frame.frame.width;
		height = Math.abs(scale.y) * _frame.frame.height;
		offset.set(-0.5 * (width - _frame.frame.width), -0.5 * (height - _frame.frame.height));
		centerOrigin();
	}
}
