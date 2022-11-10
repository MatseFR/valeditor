package utils;

/**
 * ...
 * @author Matse
 */
class ColorUtil 
{

	/** Returns the alpha part of an ARGB color (0 - 255). */
    inline public static function getAlpha(color:Int):Int { return (color >> 24) & 0xff; }

    /** Returns the red part of an (A)RGB color (0 - 255). */
    inline public static function getRed(color:Int):Int   { return (color >> 16) & 0xff; }

    /** Returns the green part of an (A)RGB color (0 - 255). */
    inline public static function getGreen(color:Int):Int { return (color >>  8) & 0xff; }

    /** Returns the blue part of an (A)RGB color (0 - 255). */
    inline public static function getBlue(color:Int):Int  { return  color        & 0xff; }

    /** Sets the alpha part of an ARGB color (0 - 255). */
    inline public static function setAlpha(color:Int, alpha:Int):Int
    {
        return (color & 0x00ffffff) | (alpha & 0xff) << 24;
    }

    /** Sets the red part of an (A)RGB color (0 - 255). */
    inline public static function setRed(color:Int, red:Int):Int
    {
        return (color & 0xff00ffff) | (red & 0xff) << 16;
    }

    /** Sets the green part of an (A)RGB color (0 - 255). */
    inline public static function setGreen(color:Int, green:Int):Int
    {
        return (color & 0xffff00ff) | (green & 0xff) << 8;
    }

    /** Sets the blue part of an (A)RGB color (0 - 255). */
    inline public static function setBlue(color:Int, blue:Int):Int
    {
        return (color & 0xffffff00) | (blue & 0xff);
    }
	
	/**
	   Returns a String representation of the color in AARRGGBB format
	   @param	color
	   @return
	**/
	inline public static function RGBAtoHexString(color:Int):String
	{
		return colorChannelToHexString(getAlpha(color)) + colorChannelToHexString(getRed(color)) + colorChannelToHexString(getGreen(color)) + colorChannelToHexString(getBlue(color));
	}
	
	/**
	   Returns a String representation of the color in RRGGBB format
	   @param	color
	   @return
	**/
	inline public static function RGBtoHexString(color:Int):String
	{
		return colorChannelToHexString(getRed(color)) + colorChannelToHexString(getGreen(color)) + colorChannelToHexString(getBlue(color));
	}
	
	/**
	   Return a String containing a hex representation of the given color channel
	   @param	color	0-255
	   @return
	**/
	inline public static function colorChannelToHexString(color:Int):String
	{
		var digits:String = "0123456789ABCDEF";
		var lsd:Float = color % 16;
		var msd:Float = (color - lsd) / 16;
		return digits.charAt(Std.int(msd)) + digits.charAt(Std.int(lsd));
	}
	
	/**
	   
	   @param	color
	   @param	offset
	   @return
	**/
	inline public static function lighten(color:Int, offset:Int):Int {
		var a1 = getAlpha(color);
		var r1 = getRed(color);
		var g1 = getGreen(color);
		var b1 = getBlue(color);
		
		var a2 = getAlpha(offset);
		var r2 = getRed(offset);
		var g2 = getGreen(offset);
		var b2 = getBlue(offset);
		
		a1 += a2;
		if (a1 > 0xff) {
			a1 = 0xff;
		}
		r1 += r2;
		if (r1 > 0xff) {
			r1 = 0xff;
		}
		g1 += g2;
		if (g1 > 0xff) {
			g1 = 0xff;
		}
		b1 += b2;
		if (b1 > 0xff) {
			b1 = 0xff;
		}
		return (a1 << 24) + (r1 << 16) + (g1 << 8) + b1;
	}
	
	/**
	   
	   @param	color
	   @param	offset
	   @return
	**/
	inline public static function darken(color:Int, offset:Int):Int {
		var a1 = getAlpha(color);
		var r1 = getRed(color);
		var g1 = getGreen(color);
		var b1 = getBlue(color);
		
		var a2 = getAlpha(offset);
		var r2 = getRed(offset);
		var g2 = getGreen(offset);
		var b2 = getBlue(offset);
		
		a1 -= a2;
		if (a1 < 0) {
			a1 = 0;
		}
		r1 -= r2;
		if (r1 < 0) {
			r1 = 0;
		}
		g1 -= g2;
		if (g1 < 0) {
			g1 = 0;
		}
		b1 -= b2;
		if (b1 < 0) {
			b1 = 0;
		}
		return (a1 << 24) + (r1 << 16) + (g1 << 8) + b1;
	}
	
	inline public static function lightenByRatio(color:Int, ratio:Float = 0.2):Int
	{
		bound(ratio, 0, 1);

        var r:Int = getRed(color);
        var g:Int = getGreen(color);
        var b:Int = getBlue(color);
        var a:Int = getAlpha(color);

        r += Std.int((255 - r) * ratio);
        g += Std.int((255 - g) * ratio);
        b += Std.int((255 - b) * ratio);

        //return makeFromRGBA(r, g, b, a);
		return (a << 24) + (r << 16) + (g << 8) + b;
	}
	
	inline public static function darkenByRatio(color:Int, ratio:Float = 0.2):Int
	{
		bound(ratio, 0, 1);

        var r:Int = getRed(color);
        var g:Int = getGreen(color);
        var b:Int = getBlue(color);
        var a:Int = getAlpha(color);

        ratio = (1 - ratio);

        r = Std.int(r * ratio);
        g = Std.int(g * ratio);
        b = Std.int(b * ratio);

        //return makeFromRGBA(r, g, b, a);
		return (a << 24) + (r << 16) + (g << 8) + b;
	}
	
	/**
     * Bound a number by a minimum and maximum.
     * Ensures that this number is no smaller than the minimum,
     * and no larger than the maximum.
     * @param   value   Any number.
     * @param   min     Any number.
     * @param   max     Any number.
     * @return  The bounded value of the number.
     */
    inline public static function bound(value:Float, min:Float, max:Float):Float
    {
        var lowerBound:Float = (value < min) ? min : value;
        return (lowerBound > max) ? max : lowerBound;
    }
	
}