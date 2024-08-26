package valeditor.ui.feathers.theme.components;
import feathers.controls.TabBar;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.skins.RectangleSkin;
import feathers.skins.UnderlineSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.theme.variant.TabBarVariant;

/**
 * ...
 * @author Matse
 */
class TabBarStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		TabBarStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(TabBar, TabBarVariant.TOP_SPACING) == null)
		{
			styleProvider.setStyleFunction(TabBar, TabBarVariant.TOP_SPACING, top_spacing);
		}
	}
	
	static private function top_spacing(tabBar:TabBar):Void
	{
		var isDesktop:Bool = DeviceUtil.isDesktop();
		
		if (tabBar.backgroundSkin == null)
		{
			var skin = new UnderlineSkin();
			skin.fill = theme.getLightFill();
			skin.border = theme.getContrastBorderLight();
			tabBar.backgroundSkin = skin;
		}
		
		if (tabBar.focusRectSkin == null)
		{
			var focusRectSkin = new RectangleSkin();
			focusRectSkin.fill = null;
			focusRectSkin.border = theme.getFocusBorder();
			tabBar.focusRectSkin = focusRectSkin;
		}
		
		if (tabBar.layout == null)
		{
			var layout = new HorizontalLayout();
			layout.paddingTop = 2;
			if (!isDesktop)
			{
				layout.horizontalAlign = HorizontalAlign.CENTER;
			}
			tabBar.layout = layout;
		}
	}
	
}