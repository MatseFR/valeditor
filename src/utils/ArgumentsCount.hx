package utils;
import haxe.Constraints.Function;
import openfl.errors.Error;

/**
 * ...
 * @author Matse
 */
class ArgumentsCount 
{

	inline public static function count_args(func:Function):Int
	{
		#if flash
		return untyped func.length;
		#elseif neko
		return untyped ($nargs)(func);
		#elseif cpp
		return untyped func.__ArgCount();
		#elseif html5
		return untyped func.length;
		#else
		throw new Error("ArgumentsCount.count_args ::: unsupported platform");
		#end
	}
	
}