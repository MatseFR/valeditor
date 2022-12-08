package ui.feathers.theme.flatcolor;

import feathers.events.StyleProviderEvent;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.style.ClassVariantStyleProvider;
import feathers.style.IDarkModeTheme;
import feathers.text.TextFormat;
import feathers.themes.ClassVariantTheme;
import openfl.display.GradientType;
import openfl.text.TextFormatAlign;
import ui.feathers.theme.flatcolor.components.ActivityIndicatorStyles;
import ui.feathers.theme.flatcolor.components.AlertStyles;
import ui.feathers.theme.flatcolor.components.ApplicationStyles;
import ui.feathers.theme.flatcolor.components.ButtonBarStyles;
import ui.feathers.theme.flatcolor.components.ButtonStyles;
import ui.feathers.theme.flatcolor.components.CalloutStyles;
import ui.feathers.theme.flatcolor.components.CheckStyles;
import ui.feathers.theme.flatcolor.components.ComboBoxStyles;
import ui.feathers.theme.flatcolor.components.HScrollBarStyles;
import ui.feathers.theme.flatcolor.components.HSliderStyles;
import ui.feathers.theme.flatcolor.components.LabelStyles;
import ui.feathers.theme.flatcolor.components.LayoutGroupItemRendererStyles;
import ui.feathers.theme.flatcolor.components.LayoutGroupStyles;
import ui.feathers.theme.flatcolor.components.ListViewStyles;
import ui.feathers.theme.flatcolor.components.PopUpListViewStyles;
import ui.feathers.theme.flatcolor.components.ScrollContainerStyles;
import ui.feathers.theme.flatcolor.components.TextInputStyles;
import ui.feathers.theme.flatcolor.components.ToggleButtonStyles;
import ui.feathers.theme.flatcolor.components.VScrollBarStyles;
import ui.feathers.theme.flatcolor.components.VSliderStyles;
import ui.feathers.theme.flatcolor.settings.ControlSettings;
import utils.ColorUtil;

/**
 * ...
 * @author Matse
 */
class FlatColorTheme extends ClassVariantTheme implements IDarkModeTheme
{
	public var darkMode(get, set):Bool;
	
	private var _darkMode:Bool = false;
	private function get_darkMode():Bool { return _darkMode; }
	private function set_darkMode(value:Bool):Bool 
	{
		if (_darkMode == value) return value;
		_darkMode = value;
		this.refreshColors();
		styleChanged();
		return value;
	}
	
	public var lightThemeColor(get, set):Int;
	public var lightThemeLightColor(get, set):Int;
	public var lightThemeContrastColor(get, set):Int;
	public var lightThemeFocusColor(get, set):Int;
	public var lightThemeDangerColor(get, set):Int;
	public var lightThemeControlSettings(default, null):ControlSettings = new ControlSettings();
	public var lightThemeProminentControlSettings(default, null):ControlSettings = new ControlSettings();
	//public var lightThemeControlColor1(get, set):Int;
	//public var lightThemeControlColor2(get, set):Int;
	//public var lightThemeControlBorderColor(get, set):Int;
	//public var lightThemeControlDisabledColor1(get, set):Int;
	//public var lightThemeControlDisabledColor2(get, set):Int;
	//public var lightThemeControlDisabledBorderColor(get, set):Int;
	//public var lightThemeControlDownColor1(get, set):Int;
	//public var lightThemeControlDownColor2(get, set):Int;
	//public var lightThemeControlDownBorderColor(get, set):Int;
	//public var lightThemeProminentControlColor1(get, set):Int;
	//public var lightThemeProminentControlColor2(get, set):Int;
	//public var lightThemeProminentControlBorderColor(get, set):Int;
	//public var lightThemeProminentControlDisabledColor1(get, set):Int;
	//public var lightThemeProminentControlDisabledColor2(get, set):Int;
	//public var lightThemeProminentControlDisabledBorderColor(get, set):Int;
	//public var lightThemeProminentControlDownColor1(get, set):Int;
	//public var lightThemeProminentControlDownColor2(get, set):Int;
	//public var lightThemeProminentControlDownBorderColor(get, set):Int;
	
	public var lightThemeColorDarkenRatio(get, set):Float;
	public var lightThemeColorLightenRatio(get, set):Float;
	public var lightThemeLightColorDarkenRatio(get, set):Float;
	public var lightThemeLightColorLightenRatio(get, set):Float;
	public var lightThemeContrastColorDarkenRatio(get, set):Float;
	public var lightThemeContrastColorLightenRatio(get, set):Float;
	public var lightThemeDangerColorDarkenRatio(get, set):Float;
	public var lightThemeDangerColorLightenRatio(get, set):Float;
	
	public var darkThemeColor(get, set):Int;
	public var darkThemeLightColor(get, set):Int;
	public var darkThemeContrastColor(get, set):Int;
	public var darkThemeFocusColor(get, set):Int;
	public var darkThemeDangerColor(get, set):Int;
	public var darkThemeControlSettings(default, null):ControlSettings = new ControlSettings();
	public var darkThemeProminentControlSettings(default, null):ControlSettings = new ControlSettings();
	//public var darkThemeControlColor1(get, set):Int;
	//public var darkThemeControlColor2(get, set):Int;
	//public var darkThemeControlBorderColor(get, set):Int;
	//public var darkThemeControlDisabledColor1(get, set):Int;
	//public var darkThemeControlDisabledColor2(get, set):Int;
	//public var darkThemeControlDisabledBorderColor(get, set):Int;
	//public var darkThemeControlDownColor1(get, set):Int;
	//public var darkThemeControlDownColor2(get, set):Int;
	//public var darkThemeControlDownBorderColor(get, set):Int;
	//public var darkThemeProminentControlColor1(get, set):Int;
	//public var darkThemeProminentControlColor2(get, set):Int;
	//public var darkThemeProminentControlDisabledColor1(get, set):Int;
	//public var darkThemeProminentControlDisabledColor2(get, set):Int;
	//public var darkThemeProminentControlDownColor1(get, set):Int;
	//public var darkThemeProminentControlDownColor2(get, set):Int;
	
	public var darkThemeColorDarkenRatio(get, set):Float;
	public var darkThemeColorLightenRatio(get, set):Float;
	public var darkThemeLightColorDarkenRatio(get, set):Float;
	public var darkThemeLightColorLightenRatio(get, set):Float;
	public var darkThemeContrastColorDarkenRatio(get, set):Float;
	public var darkThemeContrastColorLightenRatio(get, set):Float;
	public var darkThemeDangerColorDarkenRatio(get, set):Float;
	public var darkThemeDangerColorLightenRatio(get, set):Float;
	
	public var themeColor(default, null):Int;
	public var themeColorDark(default, null):Int;
	public var themeColorLight(default, null):Int;
	
	public var lightColor(default, null):Int;
	public var lightColorDark(default, null):Int;
	public var lightColorDarker(default, null):Int;
	public var lightColorLight(default, null):Int;
	
	public var contrastColor(default, null):Int;
	public var contrastColorLight(default, null):Int;
	public var contrastColorLighter(default, null):Int;
	
	public var focusColor(default, null):Int;
	
	public var dangerColor(default, null):Int;
	public var dangerColorDark(default, null):Int;
	public var dangerColorLight(default, null):Int;
	
	public var controlSettings(default, null):ControlSettings;
	public var prominentControlSettings(default, null):ControlSettings;
	
	//public var controlColor1(default, null):Int;
	//public var controlColor2(default, null):Int;
	//public var controlDisabledColor1(default, null):Int;
	//public var controlDisabledColor2(default, null):Int;
	//public var controlDownColor1(default, null):Int;
	//public var controlDownColor2(default, null):Int;
	//public var prominentControlColor1(default, null):Int;
	//public var prominentControlColor2(default, null):Int;
	//public var prominentControlDisabledColor1(default, null):Int;
	//public var prominentControlDisabledColor2(default, null):Int;
	//public var prominentControlDownColor1(default, null):Int;
	//public var prominentControlDownColor2(default, null):Int;
	
	public var lineThickness(get, set):Float;
	
	public var fontEmbed(default, null):Bool = false;
	public var fontName(get, set):String;
	public var fontSize(get, set):Int;
	public var fontSizeBig(get, set):Int;
	public var fontSizeSmall(get, set):Int;
	
	private var _lightThemeColor:Int = 0xa0c0f0;
	private function get_lightThemeColor():Int { return _lightThemeColor; }
	private function set_lightThemeColor(value:Int):Int
	{
		if (_lightThemeColor == value) return value;
		_lightThemeColor = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeColor;
	}
	
	private var _lightThemeLightColor:Int = 0xf8f8f8;
	private function get_lightThemeLightColor():Int { return _lightThemeLightColor; }
	private function set_lightThemeLightColor(value:Int):Int
	{
		if (_lightThemeLightColor == value) return value;
		_lightThemeLightColor = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeLightColor;
	}
	
	private var _lightThemeContrastColor:Int = 0x1f1f1f;
	private function get_lightThemeContrastColor():Int { return _lightThemeContrastColor; }
	private function set_lightThemeContrastColor(value:Int):Int
	{
		if (_lightThemeContrastColor == value) return value;
		_lightThemeContrastColor = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeContrastColor;
	}
	
	private var _lightThemeFocusColor:Int = 0xcfcf00;
	private function get_lightThemeFocusColor():Int { return _lightThemeFocusColor; }
	private function set_lightThemeFocusColor(value:Int):Int
	{
		if (_lightThemeFocusColor == value) return value;
		_lightThemeFocusColor = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeFocusColor;
	}
	
	private var _lightThemeDangerColor:Int = 0xcf0000;
	private function get_lightThemeDangerColor():Int { return _lightThemeDangerColor; }
	private function set_lightThemeDangerColor(value:Int):Int
	{
		if (_lightThemeDangerColor == value) return value;
		_lightThemeDangerColor = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeDangerColor;
	}
	
	//private var _lightThemeControlColor1:Int = 0xffffff;
	//private function get_lightThemeControlColor1():Int { return _lightThemeControlColor1; }
	//private function set_lightThemeControlColor1(value:Int):Int
	//{
		//if (_lightThemeControlColor1 == value) return value;
		//_lightThemeControlColor1 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeControlColor1;
	//}
	//
	//private var _lightThemeControlColor2:Int = 0xe8e8e8;
	//private function get_lightThemeControlColor2():Int { return _lightThemeControlColor2; }
	//private function set_lightThemeControlColor2(value:Int):Int
	//{
		//if (_lightThemeControlColor2 == value) return value;
		//_lightThemeControlColor2 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeControlColor2;
	//}
	//
	//private var _lightThemeControlDisabledColor1:Int = 0x;
	//private function get_lightThemeControlDisabledColor1():Int { return _lightThemeControlDisabledColor1; }
	//private function set_lightThemeControlDisabledColor1(value:Int):Int
	//{
		//if (_lightThemeControlDisabledColor1 == value) return value;
		//_lightThemeControlDisabledColor1 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeControlDisabledColor1;
	//}
	//
	//private var _lightThemeControlDisabledColor2:Int = 0x;
	//private function get_lightThemeControlDisabledColor2():Int { return _lightThemeControlDisabledColor2; }
	//private function set_lightThemeControlDisabledColor2(value:Int):Int
	//{
		//if (_lightThemeControlDisabledColor2 == value) return value;
		//_lightThemeControlDisabledColor2 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeControlDisabledColor2
	//}
	//
	//private var _lightThemeControlDownColor1:Int = 0x;
	//private function get_lightThemeControlDownColor1():Int { return _lightThemeControlDownColor1; }
	//private function set_lightThemeControlDownColor1(value:Int):Int
	//{
		//if (_lightThemeControlDownColor1 == value) return value;
		//_lightThemeControlDownColor1 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeControlDownColor1;
	//}
	//
	//private var _lightThemeControlDownColor2:Int = 0x;
	//private function get_lightThemeControlDownColor2():Int { return _lightThemeControlDownColor2; }
	//private function set_lightThemeControlDownColor2(value:Int):Int
	//{
		//if (_lightThemeControlDownColor2 == value) return value;
		//_lightThemeControlDownColor2 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeControlDownColor2;
	//}
	//
	//private var _lightThemeProminentControlColor1:Int = 0xa0c0f0;
	//private function get_lightThemeProminentControlColor1():Int { return _lightThemeProminentControlColor1; }
	//private function set_lightThemeProminentControlColor1(value:Int):Int
	//{
		//if (_lightThemeProminentControlColor1 == value) return value;
		//_lightThemeProminentControlColor1 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeProminentControlColor1;
	//}
	//
	//private var _lightThemeProminentControlColor2:Int = 0x90add8;
	//private function get_lightThemeProminentControlColor2():Int { return _lightThemeProminentControlColor2; }
	//private function set_lightThemeProminentControlColor2(value:Int):Int
	//{
		//if (_lightThemeProminentControlColor2 == value) return value;
		//_lightThemeProminentControlColor2 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeProminentControlColor2;
	//}
	//
	//private var _lightThemeProminentControlDisabledColor1:Int = 0x;
	//private function get_lightThemeProminentControlDisabledColor1():Int { return _lightThemeProminentControlDisabledColor1; }
	//private function set_lightThemeProminentControlDisabledColor1(value:Int):Int
	//{
		//if (_lightThemeProminentControlDisabledColor1 == value) return value;
		//_lightThemeProminentControlDisabledColor1 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeProminentControlDisabledColor1;
	//}
	//
	//private var _lightThemeProminentControlDisabledColor2:Int = 0x;
	//private function get_lightThemeProminentControlDisabledColor2():Int { return _lightThemeProminentControlDisabledColor2; }
	//private function set_lightThemeProminentControlDisabledColor2(value:Int):Int
	//{
		//if (_lightThemeProminentControlDisabledColor2 == value) return value;
		//_lightThemeProminentControlDisabledColor2 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeProminentControlDisabledColor2;
	//}
	//
	//private var _lightThemeProminentControlDownColor1:Int = 0x;
	//private function get_lightThemeProminentControlDownColor1():Int { return _lightThemeProminentControlDownColor1; }
	//private function set_lightThemeProminentControlDownColor1(value:Int):Int
	//{
		//if (_lightThemeProminentControlDownColor1 == value) return value;
		//_lightThemeProminentControlDownColor1 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeProminentControlDownColor1;
	//}
	//
	//private var _lightThemeProminentControlDownColor2:Int = 0x;
	//private function get_lightThemeProminentControlDownColor2():Int { return _lightThemeProminentControlDownColor2; }
	//private function set_lightThemeProminentControlDownColor2(value:Int):Int
	//{
		//if (_lightThemeProminentControlDownColor2 == value) return value;
		//_lightThemeProminentControlDownColor2 = value;
		//this.refreshColors();
		//if (!this.darkMode) styleChanged();
		//return _lightThemeProminentControlDownColor2;
	//}
	
	private var _lightThemeColorDarkenRatio:Float = 0.2;
	private function get_lightThemeColorDarkenRatio():Float { return _lightThemeColorDarkenRatio; }
	private function set_lightThemeColorDarkenRatio(value:Float):Float
	{
		if (_lightThemeColorDarkenRatio == value) return value;
		_lightThemeColorDarkenRatio = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeColorDarkenRatio;
	}
	
	private var _lightThemeColorLightenRatio:Float = 0.2;
	private function get_lightThemeColorLightenRatio():Float { return _lightThemeColorLightenRatio; }
	private function set_lightThemeColorLightenRatio(value:Float):Float
	{
		if (_lightThemeColorLightenRatio == value) return value;
		_lightThemeColorLightenRatio = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeColorLightenRatio;
	}
	
	private var _lightThemeLightColorDarkenRatio:Float = 0.1;
	private function get_lightThemeLightColorDarkenRatio():Float { return _lightThemeLightColorDarkenRatio; }
	private function set_lightThemeLightColorDarkenRatio(value:Float):Float
	{
		if (_lightThemeLightColorDarkenRatio == value) return value;
		_lightThemeLightColorDarkenRatio = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeLightColorDarkenRatio;
	}
	
	private var _lightThemeLightColorLightenRatio:Float = 0.1;
	private function get_lightThemeLightColorLightenRatio():Float { return _lightThemeLightColorLightenRatio; }
	private function set_lightThemeLightColorLightenRatio(value:Float):Float
	{
		if (_lightThemeContrastColorDarkenRatio == value) return value;
		_lightThemeLightColorLightenRatio = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeLightColorLightenRatio;
	}
	
	private var _lightThemeContrastColorDarkenRatio:Float = 0.1;
	private function get_lightThemeContrastColorDarkenRatio():Float { return _lightThemeContrastColorDarkenRatio; }
	private function set_lightThemeContrastColorDarkenRatio(value:Float):Float
	{
		if (_lightThemeContrastColorDarkenRatio == value) return value;
		_lightThemeContrastColorDarkenRatio = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeContrastColorDarkenRatio;
	}
	
	private var _lightThemeContrastColorLightenRatio:Float = 0.1;
	private function get_lightThemeContrastColorLightenRatio():Float { return _lightThemeContrastColorLightenRatio; }
	private function set_lightThemeContrastColorLightenRatio(value:Float):Float
	{
		if (_lightThemeContrastColorLightenRatio == value) return value;
		_lightThemeContrastColorLightenRatio = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeContrastColorLightenRatio;
	}
	
	private var _lightThemeDangerColorDarkenRatio:Float = 0.2;
	private function get_lightThemeDangerColorDarkenRatio():Float { return _lightThemeDangerColorDarkenRatio; }
	private function set_lightThemeDangerColorDarkenRatio(value:Float):Float
	{
		if (_lightThemeDangerColorDarkenRatio == value) return value;
		_lightThemeDangerColorDarkenRatio = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeDangerColorDarkenRatio;
	}
	
	private var _lightThemeDangerColorLightenRatio:Float = 0.2;
	private function get_lightThemeDangerColorLightenRatio():Float { return _lightThemeDangerColorLightenRatio; }
	private function set_lightThemeDangerColorLightenRatio(value:Float):Float
	{
		if (_lightThemeDangerColorLightenRatio == value) return value;
		_lightThemeDangerColorLightenRatio = value;
		this.refreshColors();
		if (!this.darkMode) styleChanged();
		return _lightThemeDangerColorLightenRatio;
	}
	
	private var _darkThemeColor:Int = 0x4f6f9f;
	private function get_darkThemeColor():Int { return _darkThemeColor; }
	private function set_darkThemeColor(value:Int):Int
	{
		if (_darkThemeColor == value) return value;
		_darkThemeColor = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeColor;
	}
	
	private var _darkThemeLightColor:Int = 0x1f1f1f;
	private function get_darkThemeLightColor():Int { return _darkThemeLightColor; }
	private function set_darkThemeLightColor(value:Int):Int
	{
		if (_darkThemeLightColor == value) return value;
		_darkThemeLightColor = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeLightColor;
	}
	
	private var _darkThemeContrastColor:Int = 0xf8f8f8;
	private function get_darkThemeContrastColor():Int { return _darkThemeContrastColor; }
	private function set_darkThemeContrastColor(value:Int):Int
	{
		if (_darkThemeContrastColor == value) return value;
		_darkThemeContrastColor = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeContrastColor;
	}
	
	private var _darkThemeFocusColor:Int = 0xcfcf00;
	private function get_darkThemeFocusColor():Int { return _darkThemeFocusColor; }
	private function set_darkThemeFocusColor(value:Int):Int
	{
		if (_darkThemeFocusColor == value) return value;
		_darkThemeFocusColor = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeFocusColor;
	}
	
	private var _darkThemeDangerColor:Int = 0xcf0000;
	private function get_darkThemeDangerColor():Int { return _darkThemeDangerColor; }
	private function set_darkThemeDangerColor(value:Int):Int
	{
		if (_darkThemeDangerColor == value) return value;
		_darkThemeDangerColor = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeDangerColor;
	}
	
	//private var _darkThemeControlColor1:Int = 0x5f5f5f;
	//private function get_darkThemeControlColor1():Int { return _darkThemeControlColor1; }
	//private function set_darkThemeControlColor1(value:Int):Int
	//{
		//if (_darkThemeControlColor1 == value) return value;
		//_darkThemeControlColor1 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeControlColor1;
	//}
	//
	//private var _darkThemeControlColor2:Int = 0x4c4c4c;
	//private function get_darkThemeControlColor2():Int { return _darkThemeControlColor2; }
	//private function set_darkThemeControlColor2(value:Int):Int
	//{
		//if (_darkThemeControlColor2 == value) return value;
		//_darkThemeControlColor2 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeControlColor2;
	//}
	//
	//private var _darkThemeControlDisabledColor1:Int = 0x;
	//private function get_darkThemeControlDisabledColor1():Int { return _darkThemeControlDisabledColor1; }
	//private function set_darkThemeControlDisabledColor1(value:Int):Int
	//{
		//if (_darkThemeControlDisabledColor1 == value) return value;
		//_darkThemeControlDisabledColor1 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeControlDisabledColor1;
	//}
	//
	//private var _darkThemeControlDisabledColor2:Int = 0x;
	//private function get_darkThemeControlDisabledColor2():Int { return _darkThemeControlDisabledColor2; }
	//private function set_darkThemeControlDisabledColor2(value:Int):Int
	//{
		//if (_darkThemeControlDisabledColor2 == value) return value;
		//_darkThemeControlDisabledColor2 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeControlDisabledColor2;
	//}
	//
	//private var _darkThemeControlDownColor1:Int = 0x;
	//private function get_darkThemeControlDownColor1():Int { return _darkThemeControlDownColor1; }
	//private function set_darkThemeControlDownColor1(value:Int):Int
	//{
		//if (_darkThemeControlDownColor1 == value) return value;
		//_darkThemeControlDownColor1 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeControlDownColor1;
	//}
	//
	//private var _darkThemeControlDownColor2:Int = 0x;
	//private function get_darkThemeControlDownColor2():Int { return _darkThemeControlDownColor2; }
	//private function set_darkThemeControlDownColor2(value:Int):Int
	//{
		//if (_darkThemeControlDownColor2 == value) return value;
		//_darkThemeControlDownColor2 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeControlDownColor2;
	//}
	//
	//private var _darkThemeProminentControlColor1:Int = 0x4f6f9f;
	//private function get_darkThemeProminentControlColor1():Int { return _darkThemeProminentControlColor1; }
	//private function set_darkThemeProminentControlColor1(value:Int):Int
	//{
		//if (_darkThemeProminentControlColor1 == value) return value;
		//_darkThemeProminentControlColor1 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeProminentControlColor1;
	//}
	//
	//private var _darkThemeProminentControlColor2:Int = 0x446089;
	//private function get_darkThemeProminentControlColor2():Int { return _darkThemeProminentControlColor2; }
	//private function set_darkThemeProminentControlColor2(value:Int):Int
	//{
		//if (_darkThemeProminentControlColor2 == value) return value;
		//_darkThemeProminentControlColor2 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeProminentControlColor2;
	//}
	//
	//private var _darkThemeProminentControlDisabledColor1:Int = 0x;
	//private function get_darkThemeProminentControlDisabledColor1():Int { return _darkThemeProminentControlDisabledColor1; }
	//private function set_darkThemeProminentControlDisabledColor1(value:Int):Int
	//{
		//if (_darkThemeProminentControlDisabledColor1 == value) return value;
		//_darkThemeProminentControlDisabledColor1 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeProminentControlDisabledColor1;
	//}
	//
	//private var _darkThemeProminentControlDisabledColor2:Int = 0x;
	//private function get_darkThemeProminentControlDisabledColor2():Int { return _darkThemeProminentControlDisabledColor2; }
	//private function set_darkThemeProminentControlDisabledColor2(value:Int):Int
	//{
		//if (_darkThemeProminentControlDisabledColor2 == value) return value;
		//_darkThemeProminentControlDisabledColor2 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeProminentControlDisabledColor2;
	//}
	//
	//private var _darkThemeProminentControlDownColor1:Int = 0x;
	//private function get_darkThemeProminentControlDownColor1():Int { return _darkThemeProminentControlDownColor1; }
	//private function set_darkThemeProminentControlDownColor1(value:Int):Int
	//{
		//if (_darkThemeProminentControlDownColor1 == value) return value;
		//_darkThemeProminentControlDownColor1 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeProminentControlDownColor1;
	//}
	//
	//private var _darkThemeProminentControlDownColor2:Int = 0x;
	//private function get_darkThemeProminentControlDownColor2():Int { return _darkThemeProminentControlDownColor2; }
	//private function set_darkThemeProminentControlDownColor2(value:Int):Int
	//{
		//if (_darkThemeProminentControlDownColor2 == value) return value;
		//_darkThemeProminentControlDownColor2 = value;
		//this.refreshColors();
		//if (this.darkMode) styleChanged();
		//return _darkThemeProminentControlDownColor2;
	//}
	
	private var _darkThemeColorDarkenRatio:Float = 0.2;
	private function get_darkThemeColorDarkenRatio():Float { return _darkThemeColorDarkenRatio; }
	private function set_darkThemeColorDarkenRatio(value:Float):Float
	{
		if (_darkThemeColorDarkenRatio == value) return value;
		_darkThemeColorDarkenRatio = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeColorDarkenRatio;
	}
	
	private var _darkThemeColorLightenRatio:Float = 0.2;
	private function get_darkThemeColorLightenRatio():Float { return _darkThemeColorLightenRatio; }
	private function set_darkThemeColorLightenRatio(value:Float):Float
	{
		if (_darkThemeColorLightenRatio == value) return value;
		_darkThemeColorLightenRatio = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeColorLightenRatio;
	}
	
	private var _darkThemeLightColorDarkenRatio:Float = 0.1;
	private function get_darkThemeLightColorDarkenRatio():Float { return _darkThemeLightColorDarkenRatio; }
	private function set_darkThemeLightColorDarkenRatio(value:Float):Float
	{
		if (_darkThemeLightColorDarkenRatio == value) return value;
		_darkThemeLightColorDarkenRatio = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeLightColorDarkenRatio;
	}
	
	private var _darkThemeLightColorLightenRatio:Float = 0.1;
	private function get_darkThemeLightColorLightenRatio():Float { return _darkThemeLightColorLightenRatio; }
	private function set_darkThemeLightColorLightenRatio(value:Float):Float
	{
		if (_darkThemeLightColorLightenRatio == value) return value;
		_darkThemeLightColorLightenRatio = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeLightColorLightenRatio;
	}
	
	private var _darkThemeContrastColorDarkenRatio:Float = 0.1;
	private function get_darkThemeContrastColorDarkenRatio():Float { return _darkThemeContrastColorDarkenRatio; }
	private function set_darkThemeContrastColorDarkenRatio(value:Float):Float
	{
		if (_darkThemeContrastColorDarkenRatio == value) return value;
		_darkThemeContrastColorDarkenRatio = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeContrastColorDarkenRatio;
	}
	
	private var _darkThemeContrastColorLightenRatio:Float = 0.1;
	private function get_darkThemeContrastColorLightenRatio():Float { return _darkThemeContrastColorLightenRatio; }
	private function set_darkThemeContrastColorLightenRatio(value:Float):Float
	{
		if (_darkThemeContrastColorLightenRatio == value) return value;
		_darkThemeContrastColorLightenRatio = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeContrastColorLightenRatio;
	}
	
	private var _darkThemeDangerColorDarkenRatio:Float = 0.2;
	private function get_darkThemeDangerColorDarkenRatio():Float { return _darkThemeDangerColorDarkenRatio; }
	private function set_darkThemeDangerColorDarkenRatio(value:Float):Float
	{
		if (_darkThemeDangerColorDarkenRatio == value) return value;
		_darkThemeDangerColorDarkenRatio = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeDangerColorDarkenRatio;
	}
	
	private var _darkThemeDangerColorLightenRatio:Float = 0.2;
	private function get_darkThemeDangerColorLightenRatio():Float { return _darkThemeDangerColorLightenRatio; }
	private function set_darkThemeDangerColorLightenRatio(value:Float):Float
	{
		if (_darkThemeDangerColorLightenRatio == value) return value;
		_darkThemeDangerColorLightenRatio = value;
		this.refreshColors();
		if (this.darkMode) styleChanged();
		return _darkThemeDangerColorLightenRatio;
	}
	
	private var _lineThickness:Float = 1;
	private function get_lineThickness():Float { return _lineThickness; }
	private function set_lineThickness(value:Float):Float
	{
		if (_lineThickness == value) return value;
		_lineThickness = value;
		styleChanged();
		return _lineThickness;
	}
	
	private var _fontName:String = "_sans";
	private function get_fontName():String { return _fontName; }
	private function set_fontName(value:String):String
	{
		if (_fontName == value) return value;
		_fontName = value;
		styleChanged();
		return _fontName;
	}
	
	private var _fontSize:Int = 14;
	private function get_fontSize():Int { return _fontSize; }
	private function set_fontSize(value:Int):Int
	{
		if (_fontSize == value) return value;
		_fontSize = value;
		styleChanged();
		return _fontSize;
	}
	
	private var _fontSizeBig:Int = 18;
	private function get_fontSizeBig():Int { return _fontSizeBig; }
	private function set_fontSizeBig(value:Int):Int
	{
		if (_fontSizeBig == value) return value;
		_fontSizeBig = value;
		styleChanged();
		return _fontSizeBig;
	}
	
	private var _fontSizeSmall:Int = 12;
	private function get_fontSizeSmall():Int { return _fontSizeSmall; }
	private function set_fontSizeSmall(value:Int):Int
	{
		if (_fontSizeSmall == value) return value;
		_fontSizeSmall = value;
		styleChanged();
		return _fontSizeSmall;
	}

	public function new(lightThemeColor:Int = 0xa0c0f0, darkThemeColor:Int = 0x4f6f9f) 
	{
		super();
		this.lightThemeColor = lightThemeColor;
		this.darkThemeColor = darkThemeColor;
		this.refreshColors();
		this.styleProvider = new ClassVariantStyleProvider();
		
		ActivityIndicatorStyles.initialize(this, this.styleProvider);
		AlertStyles.initialize(this, this.styleProvider);
		ApplicationStyles.initialize(this, this.styleProvider);
		ButtonBarStyles.initialize(this, this.styleProvider);
		ButtonStyles.initialize(this, this.styleProvider);
		CalloutStyles.initialize(this, this.styleProvider);
		CheckStyles.initialize(this, this.styleProvider);
		ComboBoxStyles.initialize(this, this.styleProvider);
		HScrollBarStyles.initialize(this, this.styleProvider);
		HSliderStyles.initialize(this, this.styleProvider);
		LabelStyles.initialize(this, this.styleProvider);
		LayoutGroupItemRendererStyles.initialize(this, this.styleProvider);
		LayoutGroupStyles.initialize(this, this.styleProvider);
		ListViewStyles.initialize(this, this.styleProvider);
		PopUpListViewStyles.initialize(this, this.styleProvider);
		ScrollContainerStyles.initialize(this, this.styleProvider);
		TextInputStyles.initialize(this, this.styleProvider);
		ToggleButtonStyles.initialize(this, this.styleProvider);
		VScrollBarStyles.initialize(this, this.styleProvider);
		VSliderStyles.initialize(this, this.styleProvider);
	}
	
	private function styleChanged():Void
	{
		StyleProviderEvent.dispatch(this.styleProvider, StyleProviderEvent.STYLES_CHANGE);
	}
	
	private function refreshColors():Void
	{
		if (this.darkMode)
		{
			this.themeColor = _darkThemeColor;
			this.themeColorDark = ColorUtil.darkenByRatio(this.themeColor, _darkThemeColorDarkenRatio);
			this.themeColorLight = ColorUtil.lightenByRatio(this.themeColor, _darkThemeColorLightenRatio);
			
			this.lightColor = _darkThemeLightColor;
			this.lightColorDark = ColorUtil.lightenByRatio(this.lightColor, _darkThemeLightColorLightenRatio);
			this.lightColorDarker = ColorUtil.lightenByRatio(this.lightColor, _darkThemeLightColorLightenRatio * 2);
			this.lightColorLight = ColorUtil.darkenByRatio(this.lightColor, _darkThemeLightColorDarkenRatio);
			
			this.contrastColor = _darkThemeContrastColor;
			this.contrastColorLight = ColorUtil.darkenByRatio(this.contrastColor, _darkThemeContrastColorDarkenRatio);
			this.contrastColorLighter = ColorUtil.darkenByRatio(this.contrastColor, _darkThemeContrastColorDarkenRatio * 2);
			
			this.focusColor = _darkThemeFocusColor;
			
			this.dangerColor = _darkThemeDangerColor;
			this.dangerColorDark = ColorUtil.darkenByRatio(this.dangerColor, _darkThemeDangerColorDarkenRatio);
			this.dangerColorLight = ColorUtil.lightenByRatio(this.dangerColor, _darkThemeDangerColorLightenRatio);
			
			this.controlSettings.copy(darkThemeControlSettings);
			this.prominentControlSettings.copy(darkThemeProminentControlSettings);
			//this.controlColor1 = _darkThemeControlColor1;
			//this.controlColor2 = _darkThemeControlColor2;
			//this.controlDisabledColor1 = _darkThemeControlDisabledColor1;
			//this.controlDisabledColor2 = _darkThemeControlDisabledColor2;
			//this.controlDownColor1 = _darkThemeControlDownColor1;
			//this.controlDownColor2 = _darkThemeControlDownColor2
			//
			//this.prominentControlColor1 = _darkThemeProminentControlColor1;
			//this.prominentControlColor2 = _darkThemeProminentControlColor2;
			//this.prominentControlDisabledColor1 = _darkThemeProminentControlColor1;
			//this.prominentControlDisabledColor2 = _darkThemeProminentControlColor2;
			//this.prominentControlDownColor1 = _darkThemeProminentControlDownColor1;
			//this.prominentControlDownColor2 = _darkThemeProminentControlDownColor2:
		}
		else
		{
			this.themeColor = _lightThemeColor;
			this.themeColorDark = ColorUtil.darkenByRatio(this.themeColor, _lightThemeColorDarkenRatio);
			this.themeColorLight = ColorUtil.lightenByRatio(this.themeColor, _lightThemeColorLightenRatio);
			
			this.lightColor = _lightThemeLightColor;
			this.lightColorDark = ColorUtil.darkenByRatio(this.lightColor, _lightThemeLightColorDarkenRatio);
			this.lightColorDarker = ColorUtil.darkenByRatio(this.lightColor, _lightThemeLightColorDarkenRatio * 2);
			this.lightColorLight = ColorUtil.lightenByRatio(this.lightColor, _lightThemeLightColorLightenRatio);
			
			this.contrastColor = _lightThemeContrastColor;
			this.contrastColorLight = ColorUtil.lightenByRatio(this.contrastColor, _lightThemeContrastColorLightenRatio);
			this.contrastColorLighter = ColorUtil.lightenByRatio(this.contrastColor, _lightThemeContrastColorLightenRatio * 2);
			
			this.focusColor = _lightThemeFocusColor;
			
			this.dangerColor = _lightThemeDangerColor;
			this.dangerColorDark = ColorUtil.darkenByRatio(this.dangerColor, _lightThemeDangerColorDarkenRatio);
			this.dangerColorLight = ColorUtil.lightenByRatio(this.dangerColor, _lightThemeDangerColorLightenRatio);
			
			this.controlSettings.copy(lightThemeControlSettings);
			this.prominentControlSettings.copy(lightThemeProminentControlSettings);
			//this.controlColor1 = _lightThemeControlColor1;
			//this.controlColor2 = _lightThemeControlColor2;
			//this.controlDisabledColor1 = _lightThemeControlDisabledColor1;
			//this.controlDisabledColor2 = _lightThemeControlDisabledColor2;
			//this.controlDownColor1 = _lightThemeControlDownColor1;
			//this.controlDownColor2 = _lightThemeControlDownColor2
			//
			//this.prominentControlColor1 = _lightThemeProminentControlColor1;
			//this.prominentControlColor2 = _lightThemeProminentControlColor2;
			//this.prominentControlDisabledColor1 = _lightThemeProminentControlColor1;
			//this.prominentControlDisabledColor2 = _lightThemeProminentControlColor2;
			//this.prominentControlDownColor1 = _lightThemeProminentControlDownColor1;
			//this.prominentControlDownColor2 = _lightThemeProminentControlDownColor2:
		}
	}
	
	//####################################################################################################
	// Fills & Borders
	//####################################################################################################
	public function getContrastBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.contrastColor);
	}
	
	public function getContrastBorderLight(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.contrastColorLight);
	}
	
	public function getContrastBorderLighter(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.contrastColorLighter);
	}
	
	public function getContrastFill():FillStyle
	{
		return FillStyle.SolidColor(this.contrastColor);
	}
	
	public function getContrastFillLight():FillStyle
	{
		return FillStyle.SolidColor(this.contrastColorLight);
	}
	
	public function getContrastFillLighter():FillStyle
	{
		return FillStyle.SolidColor(this.contrastColorLighter);
	}
	
	//public function getControlFill():FillStyle
	//{
		//return FillStyle.Gradient(GradientType.LINEAR, [this.controlColor1, this.controlColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	//}
	//
	//public function getControlDisabledFill():FillStyle
	//{
		//return FillStyle.Gradient(GradientType.LINEAR, [this.controlDisabledColor1, this.controlDisabledColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	//}
	//
	//public function getControlDownFill():FillStyle
	//{
		//return FillStyle.Gradient(GradientType.LINEAR, [this.controlDownColor1, this.controlDownColor2], [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	//}
	//
	//public function getProminentControlFill():FillStyle
	//{
		//return FillStyle.Gradient(GradientType.LINEAR, [this.prominentControlColor1, this.prominentControlColor2, [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	//}
	//
	//public function getProminentControlDisabledFill():FillStyle
	//{
		//return FillStyle.Gradient(GradientType.LINEAR, [this.prominentControlDisabledColor1, this.prominentControlDisabledColor2, [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	//}
	//
	//public function getProminentControlDownFill():FillStyle
	//{
		//return FillStyle.Gradient(GradientType.LINEAR, [this.prominentControlDownColor1, this.prominentControlDownColor2, [1.0, 1.0], [0, 0xff], Math.PI / 2.0);
	//}
	
	public function getDangerBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.dangerColor);
	}
	
	public function getDangerBorderDark(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.dangerColorDark);
	}
	
	public function getDangerBorderLight(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.dangerColorLight);
	}
	
	public function getDangerFill():FillStyle
	{
		return FillStyle.SolidColor(this.dangerColor);
	}
	
	public function getDangerFillDark():FillStyle
	{
		return FillStyle.SolidColor(this.dangerColorDark);
	}
	
	public function getDangerFillLight():FillStyle
	{
		return FillStyle.SolidColor(this.dangerColorLight);
	}
	
	public function getFocusBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.focusColor);
	}
	
	public function getFocusFill():FillStyle
	{
		return FillStyle.SolidColor(this.focusColor);
	}
	
	public function getLightBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.lightColor);
	}
	
	public function getLightBorderDark(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.lightColorDark);
	}
	
	public function getLightBorderDarker(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.lightColorDarker);
	}
	
	public function getLightBorderLight(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.lightColorLight);
	}
	
	public function getLightFill():FillStyle
	{
		return FillStyle.SolidColor(this.lightColor);
	}
	
	public function getLightFillDark():FillStyle
	{
		return FillStyle.SolidColor(this.lightColorDark);
	}
	
	public function getLightFillDarker():FillStyle
	{
		return FillStyle.SolidColor(this.lightColorDarker);
	}
	
	public function getLightFillLight():FillStyle
	{
		return FillStyle.SolidColor(this.lightColorLight);
	}
	
	public function getThemeBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.themeColor);
	}
	
	public function getThemeBorderDark(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.themeColorDark);
	}
	
	public function getThemeBorderLight(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = _lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.themeColorLight);
	}
	
	public function getThemeFill():FillStyle
	{
		return FillStyle.SolidColor(this.themeColor);
	}
	
	public function getThemeFillDark():FillStyle
	{
		return FillStyle.SolidColor(this.themeColorDark);
	}
	
	public function getThemeFillLight():FillStyle
	{
		return FillStyle.SolidColor(this.themeColorLight);
	}
	//####################################################################################################
	//\Fills & Borders
	//####################################################################################################
	
	//####################################################################################################
	// TextFormat
	//####################################################################################################
	public function getTextFormat(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSize, this.contrastColor, null, null, null, null, null, align);
	}
	
	public function getTextFormat_disabled(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSize, this.contrastColorLighter, null, null, null, null, null, align);
	}
	
	public function getTextFormat_note(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSize, this.contrastColorLight, null, null, null, null, null, align);
	}
	
	public function getTextFormat_big(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSizeBig, this.contrastColor, null, null, null, null, null, align);
	}
	
	public function getTextFormat_big_disabled(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSizeBig, this.contrastColorLighter, null, null, null, null, null, align);
	}
	
	public function getTextFormat_big_note(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSizeBig, this.contrastColorLight, null, null, null, null, null, align);
	}
	
	public function getTextFormat_small(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSizeSmall, this.contrastColor, null, null, null, null, null, align);
	}
	
	public function getTextFormat_small_disabled(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSizeSmall, this.contrastColorLighter, null, null, null, null, null, align);
	}
	
	public function getTextFormat_small_note(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this._fontName, this._fontSizeSmall, this.contrastColorLight, null, null, null, null, null, align);
	}
	//####################################################################################################
	//\TextFormat
	//####################################################################################################
	
}