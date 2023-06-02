package valeditor.utils;

/**
 * ...
 * @author Matse
 */
class TimeUtil 
{
	/**
	 * 
	 * @param	ms
	 * @return
	 */
	static public function msToString(ms:Float):String
	{
		var numMS:Int = Std.int(ms) % 1000;
		var seconds:Int = Math.floor(ms / 1000);
		var numSeconds:Int = seconds % 60;
		var minutes:Int = Math.floor(seconds / 60);
		//var numMinutes = minutes % 60;
		
		return  minutes + ":" + numSeconds + ":" + numMS;
	}
	
}