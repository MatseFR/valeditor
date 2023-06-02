package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class ToggleButtonStyles 
{
	static private var theme:SimpleTheme;
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ToggleButtonStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(ToggleButton, null) == null) {
			styleProvider.setStyleFunction(ToggleButton, null, Default);
		}
	}
	
	static private function Default(button:ToggleButton):Void
	{
		if (button.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = theme.getLightFill();
			skin.disabledFill = theme.getLightFillDark();
			skin.selectedFill = theme.getThemeFill();
			skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
			skin.setFillForState(ToggleButtonState.HOVER(true), theme.getThemeFillLight());
			skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFill());
			skin.setFillForState(ToggleButtonState.DOWN(true), theme.getThemeFill());
			skin.border = theme.getLightBorderDarker();
			skin.selectedBorder = theme.getThemeBorderDark();
			skin.setBorderForState(ToggleButtonState.HOVER(false), theme.getLightBorderDark());
			skin.setBorderForState(ToggleButtonState.HOVER(true), theme.getThemeBorder());
			skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getLightBorderDark());
			skin.setBorderForState(ToggleButtonState.DOWN(true), theme.getThemeBorder());
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
	}
	
}