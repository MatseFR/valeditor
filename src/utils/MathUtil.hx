package utils;

/**
 * ...
 * @author Matse
 */
class MathUtil 
{
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