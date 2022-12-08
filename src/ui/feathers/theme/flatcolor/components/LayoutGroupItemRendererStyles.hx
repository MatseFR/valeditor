package ui.feathers.theme.flatcolor.components;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.LayoutGroupItemRenderer;
import feathers.skins.UnderlineSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class LayoutGroupItemRendererStyles 
{

	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(LayoutGroupItemRenderer, null) == null) {
			styleProvider.setStyleFunction(LayoutGroupItemRenderer, null, function(itemRenderer:LayoutGroupItemRenderer):Void {
				var isDesktop = DeviceUtil.isDesktop();

				if (itemRenderer.backgroundSkin == null) {
					var skin = new UnderlineSkin();
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
			});
		}
	}
	
}