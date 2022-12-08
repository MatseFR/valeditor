package ui.feathers.theme.flatcolor.components;
import feathers.controls.ButtonBar;
import feathers.layout.HorizontalLayout;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class ButtonBarStyles 
{
	
	/**
	   
	   @param	theme
	   @param	styleProvider
	**/
	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(ButtonBar, null) == null) {
			styleProvider.setStyleFunction(ButtonBar, null, function(tabBar:ButtonBar):Void {
				if (tabBar.layout == null) {
					var layout = new HorizontalLayout();
					layout.gap = 6.0;
					tabBar.layout = layout;
				}
			});
		}
	}
	
}