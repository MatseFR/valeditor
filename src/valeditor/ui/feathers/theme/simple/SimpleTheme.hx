package valeditor.ui.feathers.theme.simple;

import feathers.events.StyleProviderEvent;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.style.ClassVariantStyleProvider;
import feathers.style.IDarkModeTheme;
import feathers.style.Theme;
import feathers.text.TextFormat;
import feathers.themes.ClassVariantTheme;
import feathers.themes.steel.DefaultSteelTheme;
import openfl.text.TextFormatAlign;
import valeditor.ui.feathers.theme.simple.components.ActivityIndicatorStyles;
import valeditor.ui.feathers.theme.simple.components.AlertStyles;
import valeditor.ui.feathers.theme.simple.components.ApplicationStyles;
import valeditor.ui.feathers.theme.simple.components.ButtonBarStyles;
import valeditor.ui.feathers.theme.simple.components.ButtonStyles;
import valeditor.ui.feathers.theme.simple.components.CalloutStyles;
import valeditor.ui.feathers.theme.simple.components.CheckStyles;
import valeditor.ui.feathers.theme.simple.components.ComboBoxStyles;
import valeditor.ui.feathers.theme.simple.components.HScrollBarStyles;
import valeditor.ui.feathers.theme.simple.components.HSliderStyles;
import valeditor.ui.feathers.theme.simple.components.HierarchicalItemRendererStyles;
import valeditor.ui.feathers.theme.simple.components.ItemRendererStyles;
import valeditor.ui.feathers.theme.simple.components.LabelStyles;
import valeditor.ui.feathers.theme.simple.components.LayoutGroupItemRendererStyles;
import valeditor.ui.feathers.theme.simple.components.LayoutGroupStyles;
import valeditor.ui.feathers.theme.simple.components.ListViewStyles;
import valeditor.ui.feathers.theme.simple.components.PopUpListViewStyles;
import valeditor.ui.feathers.theme.simple.components.ScrollContainerStyles;
import valeditor.ui.feathers.theme.simple.components.TextInputStyles;
import valeditor.ui.feathers.theme.simple.components.ToggleButtonStyles;
import valeditor.ui.feathers.theme.simple.components.TreeViewStyles;
import valeditor.ui.feathers.theme.simple.components.VScrollBarStyles;
import valeditor.ui.feathers.theme.simple.components.VSliderStyles;
import valeditor.utils.ColorUtil;

/**
 * ...
 * @author Matse
 */
class SimpleTheme extends ClassVariantTheme implements IDarkModeTheme 
{
	public var defaultTheme:DefaultSteelTheme;
	
	public var darkMode(get, set):Bool;
	private var _darkMode:Bool = false;
	function get_darkMode():Bool { return this._darkMode; }
	function set_darkMode(value:Bool):Bool 
	{
		if (_darkMode == value) return value;
		//defaultTheme.darkMode = value;
		this._darkMode = value;
		this.refreshColors();
		this.styleChanged();
		return value;
	}
	
	public var fontName(get, set):String;
	private var _fontName:String = "_sans";
	private function get_fontName():String { return this._fontName; }
	private function set_fontName(value:String):String
	{
		if (this._fontName == value) return value;
		this._fontName = value;
		this.styleChanged();
		return this._fontName;
	}
	
	public var fontSize(get, set):Int;
	private var _fontSize:Int = 12;
	private function get_fontSize():Int { return this._fontSize; }
	private function set_fontSize(value:Int):Int
	{
		if (this._fontSize == value) return value;
		this._fontSize = value;
		this.styleChanged();
		return this._fontSize;
	}
	
	public var fontSizeBig(get, set):Int;
	private var _fontSizeBig:Int = 16;
	private function get_fontSizeBig():Int { return this._fontSizeBig; }
	private function set_fontSizeBig(value:Int):Int
	{
		if (this._fontSizeBig == value) return value;
		this._fontSizeBig = value;
		this.styleChanged();
		return this._fontSizeBig;
	}
	
	public var fontSizeSmall(get, set):Int;
	private var _fontSizeSmall:Int = 11;
	private function get_fontSizeSmall():Int { return this._fontSizeSmall; }
	private function set_fontSizeSmall(value:Int):Int
	{
		if (this._fontSizeSmall == value) return value;
		this._fontSizeSmall = value;
		this.styleChanged();
		return this._fontSizeSmall;
	}
	
	public var lineThickness(get, set):Float;
	private var _lineThickness:Float = 1;
	private function get_lineThickness():Float { return this._lineThickness; }
	private function set_lineThickness(value:Float):Float
	{
		if (this._lineThickness == value) return value;
		this._lineThickness = value;
		this.styleChanged();
		return this._lineThickness;
	}
	
	//##########################################################################################
	// LIGHT MODE
	//##########################################################################################
	public var lightThemeColor(get, set):Int;
	private var _lightThemeColor:Int = 0xa0c0f0;
	private function get_lightThemeColor():Int { return this._lightThemeColor; }
	private function set_lightThemeColor(value:Int):Int
	{
		if (this._lightThemeColor == value) return value;
		this._lightThemeColor = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeColor;
	}
	
	public var lightThemeColorDarkenRatio(get, set):Float;
	private var _lightThemeColorDarkenRatio:Float = 0.1;
	private function get_lightThemeColorDarkenRatio():Float { return this._lightThemeColorDarkenRatio; }
	private function set_lightThemeColorDarkenRatio(value:Float):Float
	{
		if (this._lightThemeColorDarkenRatio == value) return value;
		this._lightThemeColorDarkenRatio = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeColorDarkenRatio;
	}
	
	public var lightThemeColorLightenRatio(get, set):Float;
	private var _lightThemeColorLightenRatio:Float = 0.1;
	private function get_lightThemeColorLightenRatio():Float { return this._lightThemeColorLightenRatio; }
	private function set_lightThemeColorLightenRatio(value:Float):Float
	{
		if (this._lightThemeColorLightenRatio  == value) return value;
		this._lightThemeColorLightenRatio = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeColorLightenRatio;
	}
	
	public var lightThemeLightColor(get, set):Int;
	private var _lightThemeLightColor:Int = 0xF0F0F0;//0xf8f8f8;
	private function get_lightThemeLightColor():Int { return this._lightThemeLightColor; }
	private function set_lightThemeLightColor(value:Int):Int
	{
		if (this.lightThemeLightColor == value) return value;
		this._lightThemeLightColor = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeLightColor;
	}
	
	public var lightThemeLightColorDarkenRatio(get, set):Float;
	private var _lightThemeLightColorDarkenRatio:Float = 0.1;
	private function get_lightThemeLightColorDarkenRatio():Float { return this._lightThemeLightColorDarkenRatio; }
	private function set_lightThemeLightColorDarkenRatio(value:Float):Float
	{
		if (this._lightThemeLightColorDarkenRatio == value) return value;
		this._lightThemeLightColorDarkenRatio = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeLightColorDarkenRatio;
	}
	
	public var lightThemeLightColorLightenRatio(get, set):Float;
	private var _lightThemeLightColorLightenRatio:Float = 0.1;
	private function get_lightThemeLightColorLightenRatio():Float { return this._lightThemeLightColorLightenRatio; }
	private function set_lightThemeLightColorLightenRatio(value:Float):Float
	{
		if (this._lightThemeLightColorLightenRatio == value) return value;
		this._lightThemeLightColorLightenRatio = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeLightColorLightenRatio;
	}
	
	public var lightThemeContrastColor(get, set):Int;
	private var _lightThemeContrastColor:Int = 0x3C3C3C;//0x1f1f1f;
	private function get_lightThemeContrastColor():Int { return this._lightThemeContrastColor; }
	private function set_lightThemeContrastColor(value:Int):Int
	{
		if (this._lightThemeContrastColor == value) return value;
		this._lightThemeContrastColor = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeContrastColor;
	}
	
	public var lightThemeContrastColorDarkenRatio(get, set):Float;
	private var _lightThemeContrastColorDarkenRatio:Float = 0.1;
	private function get_lightThemeContrastColorDarkenRatio():Float { return this._lightThemeContrastColorDarkenRatio; }
	private function set_lightThemeContrastColorDarkenRatio(value:Float):Float
	{
		if (this._lightThemeContrastColorDarkenRatio == value) return value;
		this._lightThemeContrastColorDarkenRatio = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeContrastColorDarkenRatio;
	}
	
	public var lightThemeContrastColorLightenRatio(get, set):Float;
	private var _lightThemeContrastColorLightenRatio:Float = 0.1;
	private function get_lightThemeContrastColorLightenRatio():Float { return this._lightThemeContrastColorLightenRatio; }
	private function set_lightThemeContrastColorLightenRatio(value:Float):Float
	{
		if (this._lightThemeContrastColorLightenRatio == value) return value;
		this._lightThemeContrastColorLightenRatio = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeContrastColorLightenRatio;
	}
	
	public var lightThemeDangerColor(get, set):Int;
	private var _lightThemeDangerColor:Int = 0xcf0000;
	private function get_lightThemeDangerColor():Int { return this._lightThemeDangerColor; }
	private function set_lightThemeDangerColor(value:Int):Int
	{
		if (this._lightThemeDangerColor == value) return value;
		this._lightThemeDangerColor = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeDangerColor;
	}
	
	public var lightThemeDangerColorDarkenRatio(get, set):Float;
	private var _lightThemeDangerColorDarkenRatio:Float = 0.1;
	private function get_lightThemeDangerColorDarkenRatio():Float { return this._lightThemeDangerColorDarkenRatio; }
	private function set_lightThemeDangerColorDarkenRatio(value:Float):Float
	{
		if (this._lightThemeDangerColorDarkenRatio == value) return value;
		this._lightThemeDangerColorDarkenRatio = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeDangerColorDarkenRatio;
	}
	
	public var lightThemeDangerColorLightenRatio(get, set):Float;
	private var _lightThemeDangerColorLightenRatio:Float = 0.1;
	private function get_lightThemeDangerColorLightenRatio():Float { return this._lightThemeDangerColorLightenRatio; }
	private function set_lightThemeDangerColorLightenRatio(value:Float):Float
	{
		if (this._lightThemeDangerColorLightenRatio == value) return value;
		this._lightThemeDangerColorLightenRatio = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeDangerColorLightenRatio;
	}
	
	public var lightThemeFocusColor(get, set):Int;
	private var _lightThemeFocusColor:Int = 0xcfcf00;
	private function get_lightThemeFocusColor():Int { return this._lightThemeFocusColor; }
	private function set_lightThemeFocusColor(value:Int):Int
	{
		if (this._lightThemeFocusColor == value) return value;
		this._lightThemeFocusColor = value;
		this.refreshColors();
		if (!this._darkMode) this.styleChanged();
		return this._lightThemeFocusColor;
	}
	//##########################################################################################
	//\LIGHT MODE
	//##########################################################################################
	
	//##########################################################################################
	// DARK MODE
	//##########################################################################################
	public var darkThemeColor(get, set):Int;
	private var _darkThemeColor:Int = 0x4f6f9f;
	private function get_darkThemeColor():Int { return this._darkThemeColor; }
	private function set_darkThemeColor(value:Int):Int
	{
		if (this._darkThemeColor == value) return value;
		this._darkThemeColor = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeColor;
	}
	
	public var darkThemeColorDarkenRatio(get, set):Float;
	private var _darkThemeColorDarkenRatio:Float = 0.1;
	private function get_darkThemeColorDarkenRatio():Float { return this._darkThemeColorDarkenRatio; }
	private function set_darkThemeColorDarkenRatio(value:Float):Float
	{
		if (this._darkThemeColorDarkenRatio == value) return value;
		this._darkThemeColorDarkenRatio = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeColorDarkenRatio;
	}
	
	public var darkThemeColorLightenRatio(get, set):Float;
	private var _darkThemeColorLightenRatio:Float = 0.1;
	private function get_darkThemeColorLightenRatio():Float { return this._darkThemeColorLightenRatio; }
	private function set_darkThemeColorLightenRatio(value:Float):Float
	{
		if (this._darkThemeColorLightenRatio == value) return value;
		this._darkThemeColorLightenRatio = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeColorLightenRatio;
	}
	
	public var darkThemeLightColor(get, set):Int;
	private var _darkThemeLightColor:Int = 0x3C3C3C;//0x1f1f1f;
	private function get_darkThemeLightColor():Int { return this._darkThemeLightColor; }
	private function set_darkThemeLightColor(value:Int):Int
	{
		if (this._darkThemeLightColor == value) return value;
		this._darkThemeLightColor = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeLightColor;
	}
	
	public var darkThemeLightColorDarkenRatio(get, set):Float;
	private var _darkThemeLightColorDarkenRatio:Float = 0.1;
	private function get_darkThemeLightColorDarkenRatio():Float { return this._darkThemeLightColorDarkenRatio; }
	private function set_darkThemeLightColorDarkenRatio(value:Float):Float
	{
		if (this._darkThemeLightColorDarkenRatio == value) return value;
		this._darkThemeLightColorDarkenRatio = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeLightColorDarkenRatio;
	}
	
	public var darkThemeLightColorLightenRatio(get, set):Float;
	private var _darkThemeLightColorLightenRatio:Float = 0.1;
	private function get_darkThemeLightColorLightenRatio():Float { return this._darkThemeLightColorLightenRatio; }
	private function set_darkThemeLightColorLightenRatio(value:Float):Float
	{
		if (this._darkThemeLightColorLightenRatio == value) return value;
		this._darkThemeLightColorLightenRatio = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeLightColorLightenRatio;
	}
	
	public var darkThemeContrastColor(get, set):Int;
	private var _darkThemeContrastColor:Int = 0xE6E6E6;//0xf8f8f8;
	private function get_darkThemeContrastColor():Int { return this._darkThemeContrastColor; }
	private function set_darkThemeContrastColor(value:Int):Int
	{
		if (this._darkThemeContrastColor == value) return value;
		this._darkThemeContrastColor = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeContrastColor;
	}
	
	public var darkThemeContrastColorDarkenRatio(get, set):Float;
	private var _darkThemeContrastColorDarkenRatio:Float = 0.1;
	private function get_darkThemeContrastColorDarkenRatio():Float { return this._darkThemeContrastColorDarkenRatio; }
	private function set_darkThemeContrastColorDarkenRatio(value:Float):Float
	{
		if (this._darkThemeContrastColorDarkenRatio == value) return value;
		this._darkThemeContrastColorDarkenRatio = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeContrastColorDarkenRatio;
	}
	
	public var darkThemeContrastColorLightenRatio(get, set):Float;
	private var _darkThemeContrastColorLightenRatio:Float = 0.1;
	private function get_darkThemeContrastColorLightenRatio():Float { return this._darkThemeContrastColorLightenRatio; }
	private function set_darkThemeContrastColorLightenRatio(value:Float):Float
	{
		if (this._darkThemeContrastColorLightenRatio == value) return value;
		this._darkThemeContrastColorLightenRatio = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeContrastColorLightenRatio;
	}
	
	public var darkThemeDangerColor(get, set):Int;
	private var _darkThemeDangerColor:Int = 0xcf0000;
	private function get_darkThemeDangerColor():Int { return this._darkThemeDangerColor; }
	private function set_darkThemeDangerColor(value:Int):Int
	{
		if (this._darkThemeDangerColor == value) return value;
		this._darkThemeDangerColor = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeDangerColor;
	}
	
	public var darkThemeDangerColorDarkenRatio(get, set):Float;
	private var _darkThemeDangerColorDarkenRatio:Float = 0.1;
	private function get_darkThemeDangerColorDarkenRatio():Float { return this._darkThemeDangerColorDarkenRatio; }
	private function set_darkThemeDangerColorDarkenRatio(value:Float):Float
	{
		if (this._darkThemeDangerColorDarkenRatio == value) return value;
		this._darkThemeDangerColorDarkenRatio = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeDangerColorDarkenRatio;
	}
	
	public var darkThemeDangerColorLightenRatio(get, set):Float;
	private var _darkThemeDangerColorLightenRatio:Float = 0.1;
	private function get_darkThemeDangerColorLightenRatio():Float { return this._darkThemeDangerColorLightenRatio; }
	private function set_darkThemeDangerColorLightenRatio(value:Float):Float
	{
		if (this._darkThemeDangerColorLightenRatio == value) return value;
		this._darkThemeDangerColorLightenRatio = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeDangerColorLightenRatio;
	}
	
	public var darkThemeFocusColor(get, set):Int;
	private var _darkThemeFocusColor:Int = 0xcfcf00;
	private function get_darkThemeFocusColor():Int { return this._darkThemeFocusColor; }
	private function set_darkThemeFocusColor(value:Int):Int
	{
		if (this._darkThemeFocusColor == value) return value;
		this._darkThemeFocusColor = value;
		this.refreshColors();
		if (this._darkMode) this.styleChanged();
		return this._darkThemeFocusColor;
	}
	//##########################################################################################
	//\DARK MODE
	//##########################################################################################
	
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
	
	public var dangerColor(default, null):Int;
	public var dangerColorDark(default, null):Int;
	public var dangerColorLight(default, null):Int;
	
	public var focusColor(default, null):Int;
	
	public function new(lightThemeColor:Int = 0xa0c0f0, darkThemeColor:Int = 0x4f6f9f) 
	{
		super();
		this._lightThemeColor = lightThemeColor;
		this._darkThemeColor = darkThemeColor;
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
		HierarchicalItemRendererStyles.initialize(this, this.styleProvider);
		HScrollBarStyles.initialize(this, this.styleProvider);
		HSliderStyles.initialize(this, this.styleProvider);
		ItemRendererStyles.initialize(this, this.styleProvider);
		LabelStyles.initialize(this, this.styleProvider);
		LayoutGroupItemRendererStyles.initialize(this, this.styleProvider);
		LayoutGroupStyles.initialize(this, this.styleProvider);
		ListViewStyles.initialize(this, this.styleProvider);
		PopUpListViewStyles.initialize(this, this.styleProvider);
		ScrollContainerStyles.initialize(this, this.styleProvider);
		TextInputStyles.initialize(this, this.styleProvider);
		ToggleButtonStyles.initialize(this, this.styleProvider);
		TreeViewStyles.initialize(this, this.styleProvider);
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
			this.themeColor = this._darkThemeColor;
			this.themeColorDark = ColorUtil.darkenByRatio(this.themeColor, this._darkThemeColorDarkenRatio);
			this.themeColorLight = ColorUtil.lightenByRatio(this.themeColor, this._darkThemeColorLightenRatio);
			
			this.lightColor = this._darkThemeLightColor;
			this.lightColorDark = ColorUtil.lightenByRatio(this.lightColor, this._darkThemeLightColorLightenRatio);
			this.lightColorDarker = ColorUtil.lightenByRatio(this.lightColor, this._darkThemeLightColorLightenRatio * 2);
			this.lightColorLight = ColorUtil.darkenByRatio(this.lightColor, this._darkThemeLightColorDarkenRatio);
			
			this.contrastColor = this._darkThemeContrastColor;
			this.contrastColorLight = ColorUtil.darkenByRatio(this.contrastColor, this._darkThemeContrastColorDarkenRatio);
			this.contrastColorLighter = ColorUtil.darkenByRatio(this.contrastColor, this._darkThemeContrastColorDarkenRatio * 2);
			
			this.dangerColor = this._darkThemeDangerColor;
			this.dangerColorDark = ColorUtil.darkenByRatio(this.dangerColor, this._darkThemeDangerColorDarkenRatio);
			this.dangerColorLight = ColorUtil.lightenByRatio(this.dangerColor, this._darkThemeDangerColorLightenRatio);
			
			this.focusColor = this._darkThemeFocusColor;
		}
		else
		{
			this.themeColor = this._lightThemeColor;
			this.themeColorDark = ColorUtil.darkenByRatio(this.themeColor, this._lightThemeColorDarkenRatio);
			this.themeColorLight = ColorUtil.lightenByRatio(this.themeColor, this._lightThemeColorLightenRatio);
			
			this.lightColor = this._lightThemeLightColor;
			this.lightColorDark = ColorUtil.darkenByRatio(this.lightColor, this._lightThemeLightColorDarkenRatio);
			this.lightColorDarker = ColorUtil.darkenByRatio(this.lightColor, this._lightThemeLightColorDarkenRatio * 2);
			this.lightColorLight = ColorUtil.lightenByRatio(this.lightColor, this._lightThemeLightColorLightenRatio);
			
			this.contrastColor = this._lightThemeContrastColor;
			this.contrastColorLight = ColorUtil.lightenByRatio(this.contrastColor, this._lightThemeContrastColorLightenRatio);
			this.contrastColorLighter = ColorUtil.lightenByRatio(this.contrastColor, this._lightThemeContrastColorLightenRatio * 2);
			
			this.dangerColor = this._lightThemeDangerColor;
			this.dangerColorDark = ColorUtil.darkenByRatio(this.dangerColor, this._lightThemeDangerColorDarkenRatio);
			this.dangerColorLight = ColorUtil.lightenByRatio(this.dangerColor, this._lightThemeDangerColorLightenRatio);
			
			this.focusColor = this._lightThemeFocusColor;
		}
	}
	
	//private function refreshFonts():Void
	//{
		//this.fontName = "_sans";
		//this.refreshFontSizes();
	//}
	
	//private function refreshFontSizes():Void
	//{
		//this.fontSizeGroup = 16;
		//this.fontSizeValue = 14;
	//}
	
	//####################################################################################################
	// Fills & Borders
	//####################################################################################################
	public function getContrastBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.contrastColor);
	}
	
	public function getContrastBorderLight(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.contrastColorLight);
	}
	
	public function getContrastBorderLighter(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
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
	
	public function getDangerBorder(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.dangerColor);
	}
	
	public function getDangerBorderDark(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.dangerColorDark);
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
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.lightColor);
	}
	
	public function getLightBorderDark(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.lightColorDark);
	}
	
	public function getLightBorderDarker(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.lightColorDarker);
	}
	
	public function getLightBorderLight(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
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
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.themeColor);
	}
	
	public function getThemeBorderDark(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
		if (thickness == 0) return null;
		return LineStyle.SolidColor(thickness, this.themeColorDark);
	}
	
	public function getThemeBorderLight(?thickness:Float):LineStyle
	{
		if (thickness == null) thickness = this._lineThickness;
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