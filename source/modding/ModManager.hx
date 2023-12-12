package modding;

import sys.FileSystem;

class ModManager
{
	var mods:Array<String> = new Array<String>();

	var folders:Array<String> = [
		"achievements", "characters", "charts", "custom_events", "custom_notetypes", "fonts", "images", "menu_scripts", "scripts", "shaders", "songs",
		"sounds", "stages", "videos", "weeks"
	];

	public static function loadMods():Void
	{
		if (FileSystem.exists('mods/'))
		{
			for (folder in FileSystem.readDirectory('mods/')) {}
		}
		/*
				inline public static function getModDirectories():Array<String>
			{
				var list:Array<String> = [];
				#if MODS_ALLOWED
				var modsFolder:String = Paths.mods();
				if(FileSystem.exists(modsFolder)) {
					for (folder in FileSystem.readDirectory(modsFolder))
					{
						var path = haxe.io.Path.join([modsFolder, folder]);
						if (sys.FileSystem.isDirectory(path) && !ignoreModFolders.contains(folder.toLowerCase()) && !list.contains(folder))
							list.push(folder);
					}
				}
				#end
				return list;
			}
		 */
	}
}
