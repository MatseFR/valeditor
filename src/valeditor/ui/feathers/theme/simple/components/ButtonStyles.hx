package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class ButtonStyles 
{
	
	/**
	   
	   @param	theme
	   @param	styleProvider
	**/
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Button, null) == null) {
			styleProvider.setStyleFunction(Button, null, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getLightFillLight();
					skin.disabledFill = theme.getLightFillDark();
					skin.setFillForState(DOWN, theme.getThemeFill());
					skin.setFillForState(HOVER, theme.getThemeFillLight());
					skin.border = theme.getContrastBorderLight();
					skin.setBorderForState(DOWN, theme.getThemeBorderDark());
					skin.disabledBorder = theme.getContrastBorderLighter();
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}
				
				if (button.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					button.focusRectSkin = focusRectSkin;
				}
				
				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getTextFormat_disabled();
				}
				
				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, Button.VARIANT_PRIMARY) == null) {
			styleProvider.setStyleFunction(Button, Button.VARIANT_PRIMARY, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getThemeFill();
					skin.disabledFill = theme.getThemeFillDark();
					skin.setFillForState(DOWN, theme.getThemeFillDark());
					skin.setFillForState(HOVER, theme.getThemeFillLight());
					skin.border = theme.getThemeBorderDark();
					skin.disabledBorder = theme.getThemeBorderDark();
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}
				
				if (button.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					button.focusRectSkin = focusRectSkin;
				}
				
				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getTextFormat_disabled();
				}
				
				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}
		if (styleProvider.getStyleFunction(Button, Button.VARIANT_DANGER) == null) {
			styleProvider.setStyleFunction(Button, Button.VARIANT_DANGER, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new RectangleSkin();
					skin.fill = theme.getDangerFillLight();
					skin.disabledFill = theme.getDangerFillDark();
					skin.setFillForState(DOWN, theme.getDangerFillLight());
					skin.border = theme.getDangerBorder();
					skin.disabledBorder = theme.getContrastBorderLighter();
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}
				
				if (button.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					button.focusRectSkin = focusRectSkin;
				}
				
				if (button.textFormat == null) {
					button.textFormat = theme.getTextFormat();
					button.textFormat.color = theme.dangerColorDark;
				}
				if (button.disabledTextFormat == null) {
					button.disabledTextFormat = theme.getTextFormat_disabled();
					button.disabledTextFormat.color = theme.dangerColor;
				}
				
				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}
	}
	
}