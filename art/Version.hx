package art;

import sys.FileSystem;
import sys.io.File;

// This class is for increasing the .build
class Version
{
	static function main():Void
	{
		if (!FileSystem.exists('.build'))
			File.saveContent('.build', '0');
		else
			File.saveContent('.build', '' + Std.parseInt(File.getContent('.build')) + 1);
	}
}
