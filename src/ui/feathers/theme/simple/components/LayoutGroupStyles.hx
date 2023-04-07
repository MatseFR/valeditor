package ui.feathers.theme.simple.components;
import feathers.controls.LayoutGroup;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class LayoutGroupStyles 
{

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(LayoutGroup, LayoutGroup.VARIANT_TOOL_BAR) == null) {
			styleProvider.setStyleFunction(LayoutGroup, LayoutGroup.VARIANT_TOOL_BAR, function(group:LayoutGroup):Void {
				if (group.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getLightFillDark();
					backgroundSkin.width = 44.0;
					backgroundSkin.height = 44.0;
					backgroundSkin.minHeight = 44.0;
					group.backgroundSkin = backgroundSkin;
				}
				if (group.layout == null) {
					var layout = new HorizontalLayout();
					layout.horizontalAlign = HorizontalAlign.LEFT;
					layout.verticalAlign = VerticalAlign.MIDDLE;
					layout.paddingTop = 4.0;
					layout.paddingRight = 10.0;
					layout.paddingBottom = 4.0;
					layout.paddingLeft = 10.0;
					layout.gap = 4.0;
					group.layout = layout;
				}
			});
		}
	}
	
}