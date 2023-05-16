package utils;

/**
 * ...
 * @author Matse
 */
class ArraySort 
{

	inline static public function alphabetical(a:String, b:String):Int
	{
		a = a.toLowerCase();
		b = b.toLowerCase();
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	inline static public function alphabetical_reverse(a:String, b:String):Int
	{
		a = a.toLowerCase();
		b = b.toLowerCase();
		if (a < b) return 1;
		if (a > b) return -1;
		return 0;
	}
	
	inline static public function float(a:Float, b:Float):Int
	{
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	inline static public function float_reverse(a:Float, b:Float):Int
	{
		if (a < b) return 1;
		if (a > b) return -1;
		return 0;
	}
	
	inline static public function int(a:Int, b:Int):Int
	{
		if (a < b) return -1;
		if (a > b) return 1;
		return 0;
	}
	
	inline static public function int_reverse(a:Int, b:Int):Int
	{
		if (a < b) return 1;
		if (a > b) return -1;
		return 0;
	}
	
}