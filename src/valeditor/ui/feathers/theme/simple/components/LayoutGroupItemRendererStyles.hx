package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.skins.RectangleSkin;
import feathers.skins.UnderlineSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class LayoutGroupItemRendererStyles 
{
	static private var theme:SimpleTheme;

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		LayoutGroupItemRendererStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(LayoutGroupItemRenderer, null) == null) {
			styleProvider.setStyleFunction(LayoutGroupItemRenderer, null, itemRenderer_default);
			//styleProvider.setStyleFunction(LayoutGroupItemRenderer, null, function(itemRenderer:LayoutGroupItemRenderer):Void {
				//var isDesktop = DeviceUtil.isDesktop();
				//
				//if (itemRenderer.backgroundSkin == null) {
					//var skin = new UnderlineSkin();
					//skin.fill = theme.getLightFill();
					//skin.border = theme.getContrastBorderLight();
					//skin.selectedFill = theme.getThemeFill();
					//skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFillLight());
					//if (isDesktop) {
						//skin.width = 32.0;
						//skin.height = 32.0;
						//skin.minWidth = 32.0;
						//skin.minHeight = 32.0;
					//} else {
						//skin.width = 44.0;
						//skin.height = 44.0;
						//skin.minWidth = 44.0;
						//skin.minHeight = 44.0;
					//}
					//itemRenderer.backgroundSkin = skin;
				//}
			//});
		}
	}
	
	static public function itemRenderer_default(itemRenderer:LayoutGroupItemRenderer):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		if (itemRenderer.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = theme.getLightFill();
			skin.border = theme.getContrastBorderLight();
			skin.selectedFill = theme.getThemeFill();
			skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFillLight());
			if (isDesktop) {
				skin.width = 32.0;
				skin.height = 32.0;
				skin.minWidth = 32.0;
				skin.minHeight = 32.0;
			} else {
				skin.width = 44.0;
				skin.height = 44.0;
				skin.minWidth = 44.0;
				skin.minHeight = 44.0;
			}
			itemRenderer.backgroundSkin = skin;
		}
	}
	
}