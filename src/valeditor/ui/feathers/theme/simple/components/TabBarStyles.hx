package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.TabBar;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.RelativePosition;
import feathers.skins.BaseGraphicsPathSkin;
import feathers.skins.RectangleSkin;
import feathers.skins.TabSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class TabBarStyles 
{

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(TabBar, null) == null)
		{
			styleProvider.setStyleFunction(TabBar, null, function(tabBar:TabBar):Void
			{
				var isDesktop:Bool = DeviceUtil.isDesktop();
				
				if (tabBar.backgroundSkin == null)
				{
					//var skin = new RectangleSkin();
					//skin.fill = theme.getLightFill();
					//skin.disabledFill = theme.getLightFillDark();
					//tabBar.backgroundSkin = skin;
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
					if (!isDesktop)
					{
						layout.horizontalAlign = HorizontalAlign.CENTER;
					}
					tabBar.layout = layout;
				}
			});
		}
		
		if (styleProvider.getStyleFunction(ToggleButton, TabBar.CHILD_VARIANT_TAB) == null)
		{
			styleProvider.setStyleFunction(ToggleButton, TabBar.CHILD_VARIANT_TAB, function(button:ToggleButton):Void
			{
				var isDesktop:Bool = DeviceUtil.isDesktop();
				
				if (button.backgroundSkin == null)
				{
					var skin:BaseGraphicsPathSkin = null;
					if (isDesktop)
					{
						var desktopSkin = new TabSkin();
						desktopSkin.cornerRadius = 3.0;
						desktopSkin.cornerRadiusPosition = RelativePosition.TOP;
						desktopSkin.drawBaseBorder = false;
						desktopSkin.maxWidth = 100.0;
						desktopSkin.minWidth = 20.0;
						skin = desktopSkin;
					}
					else
					{
						var mobileSkin = new RectangleSkin();
						mobileSkin.minWidth = 44.0;
						mobileSkin.minHeight = 44.0;
						skin = mobileSkin;
					}
					skin.fill = theme.getLightFill();
					skin.disabledFill = theme.getLightFillDark();
					skin.selectedFill = theme.getThemeFill();
					skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
					skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFill());
					skin.border = theme.getContrastBorderLight();
					skin.selectedBorder = theme.getContrastBorderLight();
					//skin.setBorderForState(ToggleButtonState.HOVER(false), theme.getThemeBorderLight());
					skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getThemeBorderDark());
					button.backgroundSkin = skin;
				}
				
				if (button.textFormat == null)
				{
					button.textFormat = theme.getTextFormat();
				}
				if (button.disabledTextFormat == null)
				{
					button.disabledTextFormat = theme.getTextFormat_disabled();
				}
				
				button.paddingTop = button.paddingBottom = 4.0;
				button.paddingLeft = button.paddingRight = 10.0;
				button.gap = 4.0;
			});
		}
	}
	
}