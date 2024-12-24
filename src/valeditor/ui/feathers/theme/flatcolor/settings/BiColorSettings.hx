package valeditor.ui.feathers.theme.flatcolor.settings;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import openfl.display.GradientType;

/**
 * ...
 * @author Matse
 */
class BiColorSettings extends ColorSettings 
{
	public var alpha2(get, set):Float;
	public var borderAlpha2(get, set):Float;
	public var borderColor2(get, set):Int;
	public var color2(get, set):Int;
	
	private var _alpha2:Float = 1.0;
	private function get_alpha2():Float { return _alpha2; }
	private function set_alpha2(value:Float):Float
	{
		if (_alpha2 == value) return value;
		_alpha2 = value;
		dispatchChange();
		return _alpha2;
	}
	
	private var _borderAlpha2:Float = 1.0;
	private function get_borderAlpha2():Float { return _borderAlpha2; }
	private function set_borderAlpha2(value:Float):Float
	{
		if (_borderAlpha2 == value) return value;
		_borderAlpha2 = value;
		dispatchChange();
		return _borderAlpha2;
	}
	
	private var _borderColor2:Int;
	private function get_borderColor2():Int { return _borderColor2; }
	private function set_borderColor2(value:Int):Int
	{
		if (_borderColor2 == value) return value;
		_borderColor2 = value;
		dispatchChange();
		return _borderColor2;
	}
	
	private var _color2:Int;
	private function get_color2():Int { return _color2; }
	private function set_color2(value:Int):Int
	{
		if (_color2 == value) return value;
		_color2 = value;
		dispatchChange();
		return _color2;
	}

	public function new() 
	{
		super();
		
	}
	
	override public function getFill():FillStyle 
	{
		return FillStyle.Gradient(GradientType.LINEAR, [_color, _color2], [_alpha, _alpha2], [0, 0xff], Math.PI / 2);
	}
	
	public function getReversedBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, _borderColor2, _borderAlpha2);
	}
	
	public function getReversedFill():FillStyle
	{
		return FillStyle.Gradient(GradientType.LINEAR, [_color2, _color], [_alpha2, _alpha], [0, 0xff], Math.PI / 2);
	}
	
}