package ui.feathers.theme.simple.components;
import feathers.controls.ActivityIndicator;
import feathers.skins.activity.DotsActivitySkin;
import feathers.style.ClassVariantStyleProvider;

/**
 * ...
 * @author Matse
 */
class ActivityIndicatorStyles 
{
	
	/**
	   
	   @param	theme
	   @param	styleProvider
	**/
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(ActivityIndicator, null) == null) {
			styleProvider.setStyleFunction(ActivityIndicator, null, function(indicator:ActivityIndicator):Void {
				if (indicator.activitySkin == null) {
					var activitySkin = new DotsActivitySkin();
					activitySkin.numDots = 8;
					activitySkin.dotRadius = 3.0;
					activitySkin.endDotRadius = null;
					activitySkin.dotColor = theme.contrastColor;
					activitySkin.endDotColor = null;
					activitySkin.dotAlpha = 1.0;
					activitySkin.endDotAlpha = 0.0;
					var size = 1.1 * activitySkin.dotRadius * activitySkin.numDots;
					activitySkin.width = size;
					activitySkin.height = size;
					indicator.activitySkin = activitySkin;
				}
			});
		}
	}
	
}