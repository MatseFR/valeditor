package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.TextArea;
import feathers.controls.TextInputState;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class TextAreaStyles 
{
	static private var theme:SimpleTheme;
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		TextAreaStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(TextArea, null) == null)
		{
			styleProvider.setStyleFunction(TextArea, null, Default);
		}
	}
	
	static private function Default(textArea:TextArea):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		textArea.autoHideScrollBars = !isDesktop;
		textArea.fixedScrollBars = isDesktop;
		
		if (textArea.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.cornerRadius = 3.0;
			if (isDesktop) {
				backgroundSkin.width = 120.0;
				backgroundSkin.height = 100.0;
			} else {
				backgroundSkin.width = 160.0;
				backgroundSkin.height = 120.0;
			}
			backgroundSkin.fill = theme.getLightFillLight();
			backgroundSkin.border = theme.getContrastBorderLight();
			backgroundSkin.disabledFill = theme.getLightFill();
			backgroundSkin.setBorderForState(TextInputState.DISABLED, theme.getContrastBorderLighter());
			backgroundSkin.setBorderForState(TextInputState.FOCUSED, theme.getThemeBorder());
			backgroundSkin.setBorderForState(TextInputState.ERROR, theme.getDangerBorder());
			textArea.backgroundSkin = backgroundSkin;
		}
		
		if (textArea.textFormat == null) {
			textArea.textFormat = theme.getTextFormat();
		}
		if (textArea.disabledTextFormat == null) {
			textArea.disabledTextFormat = theme.getTextFormat_disabled();
		}
		if (textArea.promptTextFormat == null) {
			textArea.promptTextFormat = theme.getTextFormat();
			textArea.promptTextFormat.italic = true;
		}
		
		textArea.paddingTop = 1.0;
		textArea.paddingRight = 1.0;
		textArea.paddingBottom = 1.0;
		textArea.paddingLeft = 1.0;
		
		if (isDesktop) {
			textArea.textPaddingTop = 4.0;
			textArea.textPaddingRight = 6.0;
			textArea.textPaddingBottom = 4.0 + 1;
			textArea.textPaddingLeft = 6.0;
		} else {
			textArea.textPaddingTop = 6.0;
			textArea.textPaddingRight = 10.0;
			textArea.textPaddingBottom = 6.0 + 1;
			textArea.textPaddingLeft = 10.0;
		}
	}
	
}