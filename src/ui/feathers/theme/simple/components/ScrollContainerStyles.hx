package ui.feathers.theme.simple.components;
import feathers.controls.ScrollContainer;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class ScrollContainerStyles 
{
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(ScrollContainer, null) == null) {
			styleProvider.setStyleFunction(ScrollContainer, null, function(container:ScrollContainer):Void {
				var isDesktop = DeviceUtil.isDesktop();
				
				container.autoHideScrollBars = !isDesktop;
				container.fixedScrollBars = isDesktop;
				
				if (container.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getLightFill();
					container.backgroundSkin = backgroundSkin;
				}
				
				if (container.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					container.focusRectSkin = focusRectSkin;
				}
			});
		}
	}
	
}