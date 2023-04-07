package ui.feathers.theme.simple.components;
import feathers.controls.Callout;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class CalloutStyles 
{

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Callout, null) == null) {
			styleProvider.setStyleFunction(Callout, null, function(callout:Callout):Void {
				if (callout.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getLightFill();
					backgroundSkin.border = theme.getLightBorderDark();
					callout.backgroundSkin = backgroundSkin;
				}
				if (callout.topArrowSkin == null) {
					var topArrowSkin = new TriangleSkin();
					topArrowSkin.pointPosition = TOP;
					topArrowSkin.drawBaseBorder = false;
					topArrowSkin.fill = theme.getLightFill();
					topArrowSkin.border = theme.getLightBorderDark();
					topArrowSkin.width = 14.0;
					topArrowSkin.height = 8.0;
					callout.topArrowSkin = topArrowSkin;
				}
				if (callout.rightArrowSkin == null) {
					var rightArrowSkin = new TriangleSkin();
					rightArrowSkin.pointPosition = RIGHT;
					rightArrowSkin.drawBaseBorder = false;
					rightArrowSkin.fill = theme.getLightFill();
					rightArrowSkin.border = theme.getLightBorderDark();
					rightArrowSkin.width = 8.0;
					rightArrowSkin.height = 14.0;
					callout.rightArrowSkin = rightArrowSkin;
				}
				if (callout.bottomArrowSkin == null) {
					var bottomArrowSkin = new TriangleSkin();
					bottomArrowSkin.pointPosition = BOTTOM;
					bottomArrowSkin.drawBaseBorder = false;
					bottomArrowSkin.fill = theme.getLightFill();
					bottomArrowSkin.border = theme.getLightBorderDark();
					bottomArrowSkin.width = 14.0;
					bottomArrowSkin.height = 8.0;
					callout.bottomArrowSkin = bottomArrowSkin;
				}
				if (callout.leftArrowSkin == null) {
					var leftArrowSkin = new TriangleSkin();
					leftArrowSkin.pointPosition = LEFT;
					leftArrowSkin.drawBaseBorder = false;
					leftArrowSkin.fill = theme.getLightFill();
					leftArrowSkin.border = theme.getLightBorderDark();
					leftArrowSkin.width = 8.0;
					leftArrowSkin.height = 14.0;
					callout.leftArrowSkin = leftArrowSkin;
				}
				
				callout.topArrowGap = -1.0;
				callout.rightArrowGap = -1.0;
				callout.bottomArrowGap = -1.0;
				callout.leftArrowGap = -1.0;
				
				callout.paddingTop = 1.0;
				callout.paddingRight = 1.0;
				callout.paddingBottom = 1.0;
				callout.paddingLeft = 1.0;
				
				callout.marginTop = 10.0;
				callout.marginRight = 10.0;
				callout.marginBottom = 10.0;
				callout.marginLeft = 10.0;
			});
		}
	}
	
}