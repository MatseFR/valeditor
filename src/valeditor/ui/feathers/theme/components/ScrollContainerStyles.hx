package valeditor.ui.feathers.theme.components;
import feathers.controls.ScrollContainer;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.variant.ScrollContainerVariant;

/**
 * ...
 * @author Matse
 */
class ScrollContainerStyles 
{

	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(ScrollContainer, ScrollContainerVariant.TRANSPARENT) == null)
		{
			styleProvider.setStyleFunction(ScrollContainer, ScrollContainerVariant.TRANSPARENT, function(container:ScrollContainer):Void
			{
				var isDesktop = DeviceUtil.isDesktop();
				
				container.autoHideScrollBars = !isDesktop;
				container.fixedScrollBars = isDesktop;
				
				if (container.focusRectSkin == null)
				{
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					container.focusRectSkin = focusRectSkin;
				}
			});
		}
	}
	
}