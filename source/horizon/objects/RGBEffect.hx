package horizon.objects;

import flixel.graphics.tile.FlxGraphicsShader as FlxShader;

@:publicFields
class RGBEffect
{
	private static var rgbs:Map<String, RGBEffect> = [];

	var shader:RGBShader;
	var r(default, set):FlxColor;
	var g(default, set):FlxColor;
	var b(default, set):FlxColor;
	var mult(default, set):Float;

	static function get(rgb:Array<FlxColor>):RGBEffect
	{
		var key = rgb.join('');
		if (!rgbs.exists(key))
		{
			var effect = new RGBEffect();
			effect.r = rgb[0];
			effect.g = rgb[1];
			effect.b = rgb[2];
			rgbs.set(key, effect);
		}

		return rgbs[key];
	}

	function set_r(val:FlxColor):FlxColor
	{
		shader.r.value = [val.redFloat, val.greenFloat, val.blueFloat, val.alphaFloat];
		return r = val;
	}

	function set_g(val:FlxColor):FlxColor
	{
		shader.g.value = [val.redFloat, val.greenFloat, val.blueFloat, val.alphaFloat];
		return g = val;
	}

	function set_b(val:FlxColor):FlxColor
	{
		shader.b.value = [val.redFloat, val.greenFloat, val.blueFloat, val.alphaFloat];
		return b = val;
	}

	function set_mult(val:Float):Float
	{
		shader.mult.value = [val];
		return mult = val;
	}

	function new()
	{
		shader = new RGBShader();
		r = 0xFFFF0000;
		g = 0xFF00FF00;
		b = 0xFF0000FF;
		mult = 1;
	}
}

class RGBShader extends FlxShader
{
	@:glFragmentHeader('
		#pragma header
		
		uniform vec4 r;
		uniform vec4 g;
		uniform vec4 b;
		uniform float mult;

		vec4 rgbShader(sampler2D bitmap, vec2 coord) {
			vec4 color = flixel_texture2D(bitmap, coord);
			if (!hasTransform || color.a == 0.0 || mult == 0.0)
				return color;

			color = mix(color, min(color.r * r + color.g * g + color.b * b, vec4(1.0)), mult);
			
			if(color.a > 0.0) 
				return color;
			
			return vec4(0.0, 0.0, 0.0, 0.0);
		}')
	@:glFragmentSource('
		#pragma header

		void main() {
			gl_FragColor = rgbShader(bitmap, openfl_TextureCoordv);
		}')
	public function new()
	{
		super();
	}
}
