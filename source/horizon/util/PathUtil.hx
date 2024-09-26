package horizon.util;

import haxe.Rest;

@:publicFields
class PathUtil
{
	@:keep static inline function directory(path:String):String
		return path.substring(0, path.lastIndexOf(path.lastIndexOf('\\') > path.lastIndexOf('/') ? '\\' : '/'));

	@:keep static function extension(path:String):String
	{
		var index = path.lastIndexOf('.');
		if (index == -1 || index < path.lastIndexOf(path.lastIndexOf('\\') > path.lastIndexOf('/') ? '\\' : '/'))
			return "";
		return path.substring(index + 1);
	}

	@:keep static inline function isAbsolute(path:String):Bool
		return path.charAt(0) == '/' || path.charAt(1) == ':' || path.charAt(0) == '\\\\';

	@:keep static function normalize(path:String):String
	{
		var paths = [];
		for (part in path.replace('\\', '/').split('/'))
		{
			if (part == '.')
				continue;
			if (part == '..' && paths.length > 0 && paths[paths.length - 1] != "..")
			{
				paths.pop();
				continue;
			}
			paths.push(part);
		}

		var normalized = paths.join('/').replace('//', '/');
		return normalized.endsWith('/') && normalized.length > 0 ? normalized.substr(0, -1) : normalized;
	}

	@:keep static function withExtension(path:String, extension:String):String
	{
		var index = path.lastIndexOf('.');
		if (index == -1 || index < path.lastIndexOf(path.lastIndexOf('\\') > path.lastIndexOf('/') ? '\\' : '/'))
			return path + '.$extension';
		return path.substring(0, index) + '.$extension';
	}

	@:keep static function withoutDirectory(path:String):String
	{
		var index = path.lastIndexOf(path.lastIndexOf('\\') > path.lastIndexOf('/') ? '\\' : '/');
		if (index == -1)
			return path;
		return path.substring(index + 1);
	}

	@:keep static function withoutExtension(path:String):String
	{
		var index = path.lastIndexOf('.');
		if (index == -1 || index < path.lastIndexOf(path.lastIndexOf('\\') > path.lastIndexOf('/') ? '\\' : '/'))
			return path;
		return path.substring(0, index);
	}

	@:keep static inline function combine(paths:Rest<String>):String
		return normalize(paths.toArray().filter(s -> s != null && s != "").join('/'));
}
