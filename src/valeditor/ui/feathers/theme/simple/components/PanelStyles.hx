package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.Panel;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class PanelStyles 
{
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Panel, null) == null)
		{
			styleProvider.setStyleFunction(Panel, null, function(panel:Panel):Void
			{
				var isDesktop = DeviceUtil.isDesktop();
				
				panel.autoHideScrollBars = !isDesktop;
				panel.fixedScrollBars = isDesktop;
				
				if (panel.backgroundSkin == null)
				{
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getLightFill();
					panel.backgroundSkin = backgroundSkin;
				}
			});
		}
	}
	
}