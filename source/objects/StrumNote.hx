package objects;

import flixel.graphics.frames.FlxFilterFrames;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;

class StrumNote extends Note
{
	var strumRGB:RGBPalette = new RGBPalette();
	var blurSpr:Note;

	public function new(noteData:Int = 2, ?mod:Mod)
	{
		super(noteData, mod);
		shader = strumRGB.shader;
		strumRGB.set(0x87A3AD, -1, 0);
		blurSpr = new Note(noteData, mod);
		blurSpr.targetSprite = this;
		blurSpr.copyAlpha = true;
		blurSpr.shader = rgb.shader;
		blurSpr.blend = ADD;
		blurSpr.alpha = .8;
		createFilterFrames(blurSpr, new BlurFilter(72, 72));
	}

	@:noCompletion override function set_cameras(val:Array<FlxCamera>):Array<FlxCamera>
	{
		blurSpr.cameras = val;
		return super.set_cameras(val);
	}

	@:noCompletion override function set_angle(val:Float):Float
	{
		blurSpr.angle = val;
		return super.set_angle(val);
	}

	inline function createFilterFrames(sprite:FlxSprite, filter:BitmapFilter)
		updateFilter(sprite, FlxFilterFrames.fromFrames(sprite.frames, 64, 64, [filter]));

	inline function updateFilter(spr:FlxSprite, sprFilter:FlxFilterFrames)
		sprFilter.applyToSprite(spr, false, true);
}
