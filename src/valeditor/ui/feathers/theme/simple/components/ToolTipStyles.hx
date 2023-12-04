package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.Label;
import feathers.core.DefaultToolTipManager;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;

/**
 * ...
 * @author Matse
 */
class ToolTipStyles 
{

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Label, DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP) == null) {
			styleProvider.setStyleFunction(Label, DefaultToolTipManager.CHILD_VARIANT_TOOL_TIP, function(label:Label):Void {
				if (label.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.border = theme.getContrastBorderLight();
					backgroundSkin.fill = theme.getLightFill();
					backgroundSkin.cornerRadius = 2.0;
					backgroundSkin.maxWidth = 276.0;
					label.backgroundSkin = backgroundSkin;
				}
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getTextFormat_disabled();
				}
				
				label.wordWrap = true;
				
				label.paddingTop = 2.0;
				label.paddingRight = 2.0;
				label.paddingBottom = 2.0;
				label.paddingLeft = 2.0;
			});
		}
	}
	
}