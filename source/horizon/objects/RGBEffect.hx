package horizon.objects;

import flixel.graphics.tile.FlxGraphicsShader as FlxShader;

// Based off of PsychEngine's RGBPalette
@:publicFields class RGBEffect
{
	private static var rgbs:Map<String, RGBEffect> = [];

	var shader:RGBShader;
	var r(default, set):FlxColor;
	var g(default, set):FlxColor;
	var b(default, set):FlxColor;
	var mult(default, set):Float;

	static function get(rgb:Array<FlxColor>, mult:Float = 1):RGBEffect
	{
		var key = '${rgb.join('')},$mult';
		if (!rgbs.exists(key))
		{
			var effect = new RGBEffect();
			effect.r = rgb[0];
			effect.g = rgb[1];
			effect.b = rgb[2];
			effect.mult = mult;
			rgbs.set(key, effect);
		}

		return rgbs[key];
	}

	function set_r(val:FlxColor):FlxColor
	{
		shader.r.value = [val.redFloat, val.greenFloat, val.blueFloat];
		return r = val;
	}

	function set_g(val:FlxColor):FlxColor
	{
		shader.g.value = [val.redFloat, val.greenFloat, val.blueFloat];
		return g = val;
	}

	function set_b(val:FlxColor):FlxColor
	{
		shader.b.value = [val.redFloat, val.greenFloat, val.blueFloat];
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
		
		uniform vec3 r;
		uniform vec3 g;
		uniform vec3 b;
		uniform float mult;

		vec4 rgbShader(sampler2D bitmap, vec2 coord) {
			vec4 color = flixel_texture2D(bitmap, coord);
			if (!hasTransform || color.a == 0. || mult == 0.)
				return color;

			color.rgb = mix(color.rgb, min(r * color.r + g * color.g + b * color.b, vec3(1.)), mult);
			
			if(color.a > 0.) 
				return color;
			
			return vec4(0.);
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
