package ui.feathers.theme.simple.components;
import feathers.controls.BasicButton;
import feathers.controls.HScrollBar;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class HScrollBarStyles 
{
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(HScrollBar, null) == null) {
			styleProvider.setStyleFunction(HScrollBar, null, function(scrollBar:HScrollBar):Void {
				var isDesktop = DeviceUtil.isDesktop();
				
				if (scrollBar.thumbSkin == null) {
					var thumbSkin = new RectangleSkin();
					thumbSkin.fill = theme.getContrastFillLight();
					thumbSkin.disabledFill = theme.getContrastFillLighter();
					var size = isDesktop ? 6.0 : 4.0;
					thumbSkin.width = size;
					thumbSkin.height = size;
					thumbSkin.minWidth = size;
					thumbSkin.minHeight = size;
					thumbSkin.cornerRadius = size / 2.0;
					
					var thumb = new BasicButton();
					thumb.keepDownStateOnRollOut = true;
					thumb.backgroundSkin = thumbSkin;
					scrollBar.thumbSkin = thumb;
				}
				
				if (isDesktop && scrollBar.trackSkin == null) {
					var trackSkin = new RectangleSkin();
					trackSkin.fill = theme.getLightFillDark();
					trackSkin.disabledFill = theme.getLightFill();
					trackSkin.width = 12.0;
					trackSkin.height = 12.0;
					trackSkin.minWidth = 12.0;
					trackSkin.minHeight = 12.0;
					scrollBar.trackSkin = trackSkin;
				}
				
				scrollBar.paddingTop = 2.0;
				scrollBar.paddingRight = 2.0;
				scrollBar.paddingBottom = 2.0;
				scrollBar.paddingLeft = 2.0;
			});
		}
	}
	
}