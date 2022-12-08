package ui.feathers.theme.flatcolor.settings;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;

/**
 * ...
 * @author Matse
 */
class ColorSettings extends BaseSettings 
{
	public var alpha(get, set):Float;
	public var borderAlpha(get, set):Float;
	public var borderColor(get, set):Int;
	public var color(get, set):Int;
	public var lineThickness:Float;
	
	private var _alpha:Float = 1.0;
	private function get_alpha():Float { return _alpha; }
	private function set_alpha(value:Float):Float
	{
		if (_alpha == value) return value;
		_alpha = value;
		dispatchChange();
		return _alpha;
	}
	
	private var _borderAlpha:Float = 1.0;
	private function get_borderAlpha():Float { return _borderAlpha; }
	private function set_borderAlpha(value:Float):Float
	{
		if (_borderAlpha == value) return value;
		_borderAlpha = value;
		dispatchChange();
		return _borderAlpha;
	}
	
	private var _borderColor:Int;
	private function get_borderColor():Int { return _borderColor; }
	private function set_borderColor(value:Int):Int
	{
		if (_borderColor == value) return _borderColor;
		_borderColor = value;
		dispatchChange();
		return _borderColor;
	}
	
	private var _color:Int;
	private function get_color():Int { return _color; }
	private function set_color(value:Int):Int
	{
		if (_color == value) return value;
		_color = value;
		dispatchChange();
		return _color;
	}
	
	/**
	   
	**/
	public function new() 
	{
		super();
	}
	
	public function getBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, _borderColor, _borderAlpha);
	}
	
	public function getFill():FillStyle
	{
		return FillStyle.SolidColor(_color, _borderAlpha);
	}
	
}