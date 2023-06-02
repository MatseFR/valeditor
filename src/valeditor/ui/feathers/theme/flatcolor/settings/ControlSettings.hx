package valeditor.ui.feathers.theme.flatcolor.settings;

import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import openfl.display.GradientType;

/**
 * ...
 * @author Matse
 */
class ControlSettings extends BaseSettings 
{
	public var color1(get, set):Int;
	public var color2(get, set):Int;
	public var borderColor(get, set):Int;
	public var text(default, null):TextSettings = new TextSettings();
	
	public var disabledColor1(get, set):Int;
	public var disabledColor2(get, set):Int;
	public var disabledBorderColor(get, set):Int;
	public var disabledText(default, null):TextSettings = new TextSettings();
	
	public var downColor1(get, set):Int;
	public var downColor2(get, set):Int;
	public var downBorderColor(get, set):Int;
	public var downText(default, null):TextSettings = new TextSettings();
	
	public var hoverColor1(get, set):Int;
	public var hoverColor2(get, set):Int;
	public var hoverBorderColor(get, set):Int;
	public var hoverText(default, null):TextSettings = new TextSettings();
	
	public var selectedColor1(get, set):Int;
	public var selectedColor2(get, set):Int;
	public var selectedBorderColor(get, set):Int;
	public var selectedText(default, null):TextSettings = new TextSettings();
	
	public var lineThickness(get, set):Float;
	public var dispatchChangeForLineThickness:Bool = false;
	
	private var _color1:Int;
	private function get_color1():Int { return _color1; }
	private function set_color1(value:Int):Int
	{
		if (_color1 == value) return value;
		_color1 = value;
		dispatchChange();
		return _color1;
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
	
	private var _borderColor:Int;
	private function get_borderColor():Int { return _borderColor; }
	private function set_borderColor(value:Int):Int
	{
		if (_borderColor == value) return value;
		_borderColor = value;
		dispatchChange();
		return _borderColor;
	}
	
	private var _disabledColor1:Int;
	private function get_disabledColor1():Int { return _disabledColor1; }
	private function set_disabledColor1(value:Int):Int
	{
		if (_disabledColor1 == value) return value;
		_disabledColor1 = value;
		dispatchChange();
		return _disabledColor1;
	}
	
	private var _disabledColor2:Int;
	private function get_disabledColor2():Int { return _disabledColor2; }
	private function set_disabledColor2(value:Int):Int
	{
		if (_disabledColor2 == value) return value;
		_disabledColor2 = value;
		dispatchChange();
		return _disabledColor2;
	}
	
	private var _disabledBorderColor:Int;
	private function get_disabledBorderColor():Int { return _disabledBorderColor; }
	private function set_disabledBorderColor(value:Int):Int
	{
		if (_disabledBorderColor == value) return value;
		_disabledBorderColor = value;
		dispatchChange();
		return _disabledBorderColor;
	}
	
	private var _downColor1:Int;
	private function get_downColor1():Int { return _downColor1; }
	private function set_downColor1(value:Int):Int
	{
		if (_downColor1 == value) return value;
		_downColor1 = value;
		dispatchChange();
		return _downColor1;
	}
	
	private var _downColor2:Int;
	private function get_downColor2():Int { return _downColor2; }
	private function set_downColor2(value:Int):Int
	{
		if (_downColor2 == value) return value;
		_downColor2 = value;
		dispatchChange();
		return _downColor2;
	}
	
	private var _downBorderColor:Int;
	private function get_downBorderColor():Int { return _downBorderColor; }
	private function set_downBorderColor(value:Int):Int
	{
		if (_downBorderColor == value) return value;
		_downBorderColor = value;
		dispatchChange();
		return _downBorderColor;
	}
	
	private var _hoverColor1:Int;
	private function get_hoverColor1():Int { return _hoverColor1; }
	private function set_hoverColor1(value:Int):Int
	{
		if (_hoverColor1 == value) return value;
		_hoverColor1 = value;
		dispatchChange();
		return _hoverColor1;
	}
	
	private var _hoverColor2:Int;
	private function get_hoverColor2():Int { return _hoverColor2; }
	private function set_hoverColor2(value:Int):Int
	{
		if (_hoverColor2 == value) return value;
		_hoverColor2 = value;
		dispatchChange();
		return _hoverColor2;
	}
	
	private var _hoverBorderColor:Int;
	private function get_hoverBorderColor():Int { return _hoverBorderColor; }
	private function set_hoverBorderColor(value:Int):Int
	{
		if (_hoverBorderColor == value) return value;
		_hoverBorderColor = value;
		dispatchChange();
		return _hoverBorderColor;
	}
	
	private var _selectedColor1:Int;
	private function get_selectedColor1():Int { return _selectedColor1; }
	private function set_selectedColor1(value:Int):Int
	{
		if (_selectedColor1 == value) return value;
		_selectedColor1 = value;
		dispatchChange();
		return _selectedColor1;
	}
	
	private var _selectedColor2:Int;
	private function get_selectedColor2():Int { return _selectedColor2; }
	private function set_selectedColor2(value:Int):Int
	{
		if (_selectedColor2 == value) return value;
		_selectedColor2 = value;
		dispatchChange();
		return _selectedColor2;
	}
	
	private var _selectedBorderColor:Int;
	private function get_selectedBorderColor():Int { return _selectedBorderColor; }
	private function set_selectedBorderColor(value:Int):Int
	{
		if (_selectedBorderColor == value) return value;
		_selectedBorderColor = value;
		dispatchChange();
		return _selectedBorderColor;
	}
	
	private var _lineThickness:Float;
	private function get_lineThickness():Float { return _lineThickness; }
	private function set_lineThickness(value:Float):Float
	{
		if (_lineThickness == value) return value;
		_lineThickness = value;
		dispatchChange();
		return _lineThickness;
	}
	
	/**
	   
	**/
	public function new() 
	{
		super();
		
	}
	
	public function copy(settings:ControlSettings):Void
	{
		_color1 = settings.color1;
		_color2 = settings.color2;
		_borderColor = settings.borderColor;
		text.copy(settings.text);
		
		_disabledColor1 = settings.disabledColor1;
		_disabledColor2 = settings.disabledColor2;
		_disabledBorderColor = settings.disabledBorderColor;
		disabledText.copy(settings.disabledText);
		
		_downColor1 = settings.downColor1;
		_downColor2 = settings.downColor2;
		_downBorderColor = settings.downBorderColor;
		downText.copy(settings.downText);
		
		_hoverColor1 = settings.hoverColor1;
		_hoverColor2 = settings.hoverColor2;
		_hoverBorderColor = settings.hoverBorderColor;
		hoverText.copy(settings.hoverText);
		
		_selectedColor1 = settings.selectedColor1;
		_selectedColor2 = settings.selectedColor2;
		_selectedBorderColor = settings.selectedBorderColor;
		selectedText.copy(settings.selectedText);
		
		_lineThickness = settings.lineThickness;
	}
	
	public function getBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, _borderColor);
	}
	
	public function getFill():FillStyle
	{
		if (_color1 == _color2)
		{
			return FillStyle.SolidColor(_color1);
		}
		return FillStyle.Gradient(GradientType.LINEAR, [_color1, _color2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}
	
	public function getDisabledBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, _disabledBorderColor);
	}
	
	public function getDisabledFill():FillStyle
	{
		if (_disabledColor1 == _disabledColor2)
		{
			return FillStyle.SolidColor(_disabledColor1);
		}
		return FillStyle.Gradient(GradientType.LINEAR, [_disabledColor1, _disabledColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}
	
	public function getDownBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, _downBorderColor);
	}
	
	public function getDownFill():FillStyle
	{
		if (_downColor1 == _downColor2)
		{
			return FillStyle.SolidColor(_downColor1);
		}
		return FillStyle.Gradient(GradientType.LINEAR, [_downColor1, _downColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}
	
	public function getHoverBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, _hoverBorderColor);
	}
	
	public function getHoverFill():FillStyle
	{
		if (_hoverColor1 == _hoverColor2)
		{
			return FillStyle.SolidColor(_hoverColor1);
		}
		return FillStyle.Gradient(GradientType.LINEAR, [_hoverColor1, _hoverColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}
	
	public function getSelectedBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, _selectedBorderColor);
	}
	
	public function getSelectedFill():FillStyle
	{
		if (_selectedColor1 == _selectedColor2)
		{
			return FillStyle.SolidColor(_selectedColor1);
		}
		return FillStyle.Gradient(GradientType.LINEAR, [_selectedColor1, _selectedColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	}
	
}