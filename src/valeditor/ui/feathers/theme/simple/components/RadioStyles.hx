package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.Radio;
import feathers.controls.ToggleButtonState;
import feathers.layout.HorizontalAlign;
import feathers.skins.CircleSkin;
import feathers.skins.MultiSkin;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Shape;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class RadioStyles 
{

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Radio, null) == null) {
			styleProvider.setStyleFunction(Radio, null, function(radio:Radio):Void {
				if (radio.textFormat == null) {
					radio.textFormat = theme.getTextFormat();
				}
				if (radio.disabledTextFormat == null) {
					radio.disabledTextFormat = theme.getTextFormat_disabled();
				}
				
				if (radio.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = SolidColor(0x000000, 0.0);
					backgroundSkin.border = null;
					radio.backgroundSkin = backgroundSkin;
				}
				
				if (radio.icon == null) {
					var icon = new MultiSkin();
					radio.icon = icon;
					
					var defaultIcon = new CircleSkin();
					defaultIcon.width = 20.0;
					defaultIcon.height = 20.0;
					defaultIcon.minWidth = 20.0;
					defaultIcon.minHeight = 20.0;
					defaultIcon.border = theme.getContrastBorderLight();
					defaultIcon.disabledBorder = theme.getContrastBorderLighter();
					defaultIcon.setBorderForState(ToggleButtonState.DOWN(false), theme.getThemeBorderDark());
					defaultIcon.fill = theme.getLightFillLight();
					defaultIcon.disabledFill = theme.getLightFillDark();
					icon.defaultView = defaultIcon;
					
					var selectedIcon = new CircleSkin();
					selectedIcon.width = 20.0;
					selectedIcon.height = 20.0;
					selectedIcon.minWidth = 20.0;
					selectedIcon.minHeight = 20.0;
					selectedIcon.border = theme.getContrastBorderLight();
					selectedIcon.disabledBorder = theme.getContrastBorderLighter();
					selectedIcon.setBorderForState(ToggleButtonState.DOWN(true), theme.getContrastBorder());
					selectedIcon.fill = theme.getThemeFill();
					selectedIcon.disabledFill = theme.getThemeFillLight();
					var symbol = new Shape();
					symbol.graphics.beginFill(theme.contrastColor);
					symbol.graphics.drawCircle(10.0, 10.0, 4.0);
					symbol.graphics.endFill();
					selectedIcon.addChild(symbol);
					icon.selectedView = selectedIcon;
					
					var disabledAndSelectedIcon = new CircleSkin();
					disabledAndSelectedIcon.width = 20.0;
					disabledAndSelectedIcon.height = 20.0;
					disabledAndSelectedIcon.minWidth = 20.0;
					disabledAndSelectedIcon.minHeight = 20.0;
					disabledAndSelectedIcon.border = theme.getContrastBorderLighter();
					disabledAndSelectedIcon.fill = theme.getThemeFillLight();
					var disabledSymbol = new Shape();
					disabledSymbol.graphics.beginFill(theme.contrastColorLighter);
					disabledSymbol.graphics.drawCircle(10.0, 10.0, 4.0);
					disabledSymbol.graphics.endFill();
					disabledAndSelectedIcon.addChild(disabledSymbol);
					icon.setViewForState(ToggleButtonState.DISABLED(true), disabledAndSelectedIcon);
				}
				
				if (radio.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					radio.focusRectSkin = focusRectSkin;
					
					radio.focusPaddingTop = 3.0;
					radio.focusPaddingRight = 3.0;
					radio.focusPaddingBottom = 3.0;
					radio.focusPaddingLeft = 3.0;
				}
				
				radio.horizontalAlign = HorizontalAlign.LEFT;
				radio.gap = 4.0;
			});
		}
	}
	
}