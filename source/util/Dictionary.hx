package util;

typedef AnyDictionary = Dictionary<Dynamic, Dynamic>;
typedef StringDictionary<T> = Dictionary<String, T>;
typedef IntDictionary<T> = Dictionary<Int, T>;
typedef StringBaseDictionary<T> = BaseDictionary<String, T>;

/**
 * a Dictionary is a Custom-made Map which has a proper order..
 *
 * Usually, Haxe's Maps are completely unordered, this was made to circumvent the issue,
 * if you need to use this in a scripting backend (for example, HScript), use `BaseDictionary<K, V>`,
 * keep in mind that BaseDictionary lacks some features such as being able to read and write like an array.
 * @author crowplexus
**/
@:forward
abstract Dictionary<K, V>(BaseDictionary<K, V>)
{
	public function new()
	{
		this = new BaseDictionary<K, V>();
	}

	@:op([]) // Read like an array, [key]
	public function get(k:K)
		return this.get(k);

	@:op([]) // Write like an array, [key] = value;
	public function set(k:K, v:V)
		return this.set(k, v);
}

/**
 * Base Dictionary implementation.
**/
class BaseDictionary<K, V>
{
	var _ks:Array<K>;
	var _vs:Array<V>;

	public var length(get, never):Int;

	inline function get_length():Int
		return _ks.length;

	public function new()
	{
		_ks = [];
		_vs = [];
	}

	public function get(k:K)
	{
		var ret:V = null;
		for (i in 0..._ks.length)
		{
			if (_ks[i] == k)
			{
				ret = _vs[i];
				break;
			}
		}
		return ret;
	}

	public function set(k:K, v:V)
	{
		for (i in 0..._ks.length)
		{
			if (_ks[i] == k)
			{
				_ks[i] = k;
				_vs[i] = v;
				return;
			}
		}
		_ks.push(k);
		_vs.push(v);
	}

	public function remove(k:K)
	{
		for (i in 0..._ks.length)
		{
			if (_ks[i] == k)
			{
				_ks.splice(i, 1);
				_vs.splice(i, 1);
				return true;
			}
		}
		return false;
	}

	public function iremove(id:Int)
	{
		for (i in 0..._ks.length)
		{
			if (i == id)
			{
				_ks.splice(i, 1);
				_vs.splice(i, 1);
				return true;
			}
		}
		return false;
	}

	public function clear()
	{
		while (_ks.length != 0)
		{
			_ks.pop();
			_vs.pop();
		}
		return _ks.length == 0;
	}

	public function keys()
	{
		return _ks.iterator();
	}

	public function iterator():Iterator<V>
	{
		return _vs.iterator();
	}

	public function keyValueIterator():DictionaryKeyValueIterator<K, V>
	{
		return new DictionaryKeyValueIterator<K, V>(_ks, _vs);
	}

	public function has(k:K)
	{
		for (i in _ks)
			if (k == i)
				return true;
		return false;
	}

	public function exists(k:K)
		return has(k);

	public function toString()
	{
		var str:String = "";
		for (i in 0..._ks.length)
		{
			final value = (Std.isOfType(_vs[i], String) ? '"${_vs[i]}"' : '${_vs[i]}');
			str += '${_ks[i]}: ${value}';
			if (i != _ks.length - 1)
				str += ", ";
		}
		return '{${str}}';
	}
}

class DictionaryKeyValueIterator<K, V>
{
	var current:Int = 0;
	var karray:Array<K>;
	var varray:Array<V>;

	public function new(karray:Array<K>, varray:Array<V>)
	{
		this.karray = karray;
		this.varray = varray;
	}

	public inline function hasNext():Bool
	{
		return karray.length == varray.length && current < karray.length;
	}

	public inline function next():{key:K, value:V}
	{
		return {value: varray[current], key: karray[current++]};
	}
}
