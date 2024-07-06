package modding;

import util.Dictionary.StringDictionary;

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

	var folderName:String;
	var iconPath:String;
	var enabled:Bool;
	var staticMod:Bool;
	var ID:Int;

	// var achievements:Array<Dynamic>;
	// var characters:Array<CharacterJSON>;
	// var dialogues:Array<Dynamic>;
	// var events:Array<EventJSON>;
	// var menuScripts:Array<Dynamic>;
	// var noteTypes:Array<Dynamic>;
	// var scripts:Array<Dynamic>;
	var songs:StringDictionary<Song>;
	// var stages:Array<StageJSON>;
	var weeks:StringDictionary<Week>;
}
