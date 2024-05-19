package modding;

import flixel.util.FlxColor;
import util.Dictionary.StringDictionary;

typedef ModJson =
{
	var name:String;
	var description:String;
	var version:String;
	var color:Array<Int>;
	var global:Bool;
	var modSysVer:Float;
}

typedef Chart =
{
	var sections:Array<Section>;
	var events:Array<EventJson>;
	var bpm:Float;
	var scroll:Float;
	var characters:Array<String>;
}

typedef Section =
{
	var beats:Int;
	var focus:Int;
	var notes:Array<NoteJson>;
}

typedef NoteJson =
{
	var time:Float;
	var data:Int;
	var length:Float;
	var type:String;
}

typedef EventJson =
{
	var name:String;
	var time:Float;
	var value:Array<String>;
}

typedef SongJson =
{
	var name:String;
	var icon:String;
}

typedef WeekJson =
{
	var name:String;
	var menuChars:Array<String>;
	var menuBG:String;
	var bgScale:Float;
	var locked:Bool;
	var unlocks:Array<String>;
	var hideSongsFromFreeplay:Bool;
	var songs:Array<String>;
	var difficulties:Array<String>;
}

typedef MenuCharJson =
{
	var position:Array<Float>;
	var scale:Float;
	var idle:Array<String>;
	var confirm:String;
	var fps:Int;
}

typedef CharacterJson =
{
	var position:Array<Float>;
	var camPos:Array<Float>;
	var voicePos:Array<Float>;
	var scale:Float;
	var animations:Array<AnimationJson>;
	var zoom:Float;
}

typedef AnimationJson =
{
	var offsets:Array<Float>;
	var loop:Bool;
	var animPrefix:String;
	var anim:String;
	var fps:Int;
	var indices:Array<Int>;
}

typedef TitleJsonData =
{
	bpm:Float,
	gfPosition:Array<Int>,
	logoPosition:Array<Int>,
	startPosition:Array<Int>
}

@:structInit
@:publicFields
class Mod
{
	var name:String;
	var description:String;
	var version:String;
	var color:FlxColor;
	var global:Bool;
	var modSysVer:Float;

	var path:String;
	var icon:String;
	var enabled:Bool;
	var staticMod:Bool;
	var weeks:StringDictionary<Week>;
	var songs:StringDictionary<Song>;
	var ID:Int;
}

@:structInit
@:publicFields
class Song
{
	var name:String;
	var icon:String;
	var audioFiles:Array<String>;
	var score:Int;
	var accuracy:Float;
}

@:structInit
@:publicFields
class Week
{
	var name:String;
	var menuChars:Array<String>;
	var menuBG:String;
	var bgScale:Float;
	var locked:Bool;
	var unlocks:Array<String>;
	var hideSongsFromFreeplay:Bool;
	var songs:Array<String>;
	var difficulties:Array<String>;
	var score:Int;
}
