package ui.feathers.theme;

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
import ui.feathers.theme.components.LabelStyles;
import ui.feathers.theme.components.LayoutGroupStyles;
import ui.feathers.theme.components.ToggleButtonStyles;
import ui.feathers.theme.components.ToggleLayoutGroupStyles;
import utils.ColorUtil;

/**
 * ...
 * @author Matse
 */
class ValEditorTheme extends ClassVariantTheme implements IDarkModeTheme 
{
	public var defaultTheme:DefaultSteelTheme;
	
	@:isVar public var darkMode(get, set):Bool;
	function get_darkMode():Bool { return darkMode; }
	function set_darkMode(value:Bool):Bool 
	{
		defaultTheme.darkMode = value;
		darkMode = value;
		this.refreshColors();
		StyleProviderEvent.dispatch(this.styleProvider, StyleProviderEvent.STYLES_CHANGE);
		return value;
	}
	
	private var srcThemeColor:Int;
	private var srcThemeLightColor:Int;
	private var srcThemeContrastColor:Int;
	private var srcDarkThemeColor:Int;
	private var srcDarkThemeLightColor:Int;
	private var srcDarkThemeContrastColor:Int;
	
	private var themeColor:Int;
	private var themeColorDark:Int;
	private var themeColorLight:Int;
	
	private var lightColor:Int;
	private var lightColorDark:Int;
	private var lightColorDarker:Int;
	private var lightColorLight:Int;
	
	private var contrastColor:Int;
	private var contrastColorLight:Int;
	private var contrastColorLighter:Int;
	
	private var fontName:String;
	private var fontSizeGroup:Int;
	private var fontSizeValue:Int;
	

	public function new() 
	{
		super();
		
		this.defaultTheme = cast Theme.fallbackTheme;
		this.refreshColors();
		this.refreshFonts();
		this.styleProvider = new ClassVariantStyleProvider();
		
		LabelStyles.initialize(this);
		LayoutGroupStyles.initialize(this);
		ToggleButtonStyles.initialize(this);
		ToggleLayoutGroupStyles.initialize(this);
	}
	
	private function refreshColors():Void
	{
		if (this.darkMode)
		{
			this.themeColor = 0x4f6f9f;
			
			
		}
		else
		{
			this.themeColor = 0xa0c0f0;
			this.themeColorDark = ColorUtil.darkenByRatio(this.themeColor, 0.2);
			this.themeColorLight = ColorUtil.lightenByRatio(this.themeColor, 0.2);
			
			this.lightColor = 0xf8f8f8;
			this.lightColorDark = ColorUtil.darkenByRatio(this.lightColor, 0.1);
			this.lightColorDarker = ColorUtil.darkenByRatio(this.lightColor, 0.2);
			this.lightColorLight = ColorUtil.lightenByRatio(this.lightColor, 0.1);
			
			this.contrastColor = 0x1f1f1f;
			this.contrastColorLight = ColorUtil.lightenByRatio(this.contrastColor, 0.1);
			this.contrastColorLighter = ColorUtil.lightenByRatio(this.contrastColor, 0.2);
		}
	}
	
	private function refreshFonts():Void
	{
		this.fontName = "_sans";
		this.refreshFontSizes();
	}
	
	private function refreshFontSizes():Void
	{
		this.fontSizeGroup = 16;
		this.fontSizeValue = 14;
	}
	
	//####################################################################################################
	// Fills & Borders
	//####################################################################################################
	public function getContrastBorder(thickness:Float = 1):LineStyle
	{
		return LineStyle.SolidColor(thickness, this.contrastColor);
	}
	
	public function getContrastBorderLight(thickness:Float = 1):LineStyle
	{
		return LineStyle.SolidColor(thickness, this.contrastColorLight);
	}
	
	public function getContrastBorderLighter(thickness:Float = 1):LineStyle
	{
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
	
	public function getLightBorder(thickness:Float = 1):LineStyle
	{
		return LineStyle.SolidColor(thickness, this.lightColor);
	}
	
	public function getLightBorderDark(thickness:Float = 1):LineStyle
	{
		return LineStyle.SolidColor(thickness, this.lightColorDark);
	}
	
	public function getLightBorderDarker(thickness:Float = 1):LineStyle
	{
		return LineStyle.SolidColor(thickness, this.lightColorDarker);
	}
	
	public function getLightBorderLight(thickness:Float = 1):LineStyle
	{
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
	
	public function getThemeBorder(thickness:Float = 1):LineStyle
	{
		return LineStyle.SolidColor(thickness, this.themeColor);
	}
	
	public function getThemeBorderDark(thickness:Float = 1):LineStyle
	{
		return LineStyle.SolidColor(thickness, this.themeColorDark);
	}
	
	public function getThemeBorderLight(thickness:Float = 1):LineStyle
	{
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
	public function getTextFormat_group(align:TextFormatAlign = LEFT):TextFormat
	{
		return new TextFormat(this.fontName, this.fontSizeGroup, this.contrastColor, true, null, null, null, null, align);
	}
	
	public function getTextFormat_object(align:TextFormatAlign = RIGHT):TextFormat
	{
		return new TextFormat(this.fontName, this.fontSizeValue, this.contrastColor, true, null, null, null, null, align);
	}
	
	public function getTextFormat_subValue(align:TextFormatAlign = RIGHT):TextFormat
	{
		return new TextFormat(this.fontName, this.fontSizeValue, this.contrastColor, null, null, null, null, null, align);
	}
	
	public function getTextFormat_value(align:TextFormatAlign = RIGHT):TextFormat
	{
		return new TextFormat(this.fontName, this.fontSizeValue, this.contrastColor, true, null, null, null, null, align);
	}
	//####################################################################################################
	//\TextFormat
	//####################################################################################################
	
}