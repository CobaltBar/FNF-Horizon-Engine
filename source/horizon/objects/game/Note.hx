package horizon.objects.game;

@:publicFields
class Note extends NoteSprite
{
	var data:Int;
	var time:Float;
	var length:Float;
	var mult:Float;
	var type:String;

	function new(data:Int = 2)
	{
		super(data);
		active = false;
	}

	function resetNote(json:NoteJSON)
	{
		data = json.data ?? 0;
		time = json.time ?? 0;
		length = json.length ?? 0;
		type = json.type;
		mult = json.mult ?? 1;
		alpha = 1;
	}
}
