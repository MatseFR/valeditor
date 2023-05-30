package utils;

/**
 * ...
 * @author Matse
 */
class MathUtil 
{
	static public var PI:Float = Math.PI;
	
	// from starling.utils.MathUtil
	/** Converts an angle from degrees into radians. */
    inline public static function deg2rad(deg:Float):Float
    {
        return deg / 180.0 * PI;
    }
    
	// from starling.utils.MathUtil
    /** Converts an angle from radians into degrees. */
    inline public static function rad2deg(rad:Float):Float
    {
        return rad / PI * 180.0;
    }
	
	// from feathers.utils.MathUtil
	/**
		Rounds a number to a certain level of decimal precision. Useful for
		limiting the number of decimal places on a fractional number.

		@param		number		the input number to round.
		@param		precision	the number of decimal digits to keep
		@return		the rounded number, or the original input if no rounding is needed

		@since 1.0.0
	**/
	static public function roundToPrecision(number:Float, precision:Int = 0):Float {
		var decimalPlaces = Math.pow(10, precision);
		return Math.fround(decimalPlaces * number) / decimalPlaces;
	}
	
}