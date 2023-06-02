package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.ButtonBar;
import feathers.layout.HorizontalLayout;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

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
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
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