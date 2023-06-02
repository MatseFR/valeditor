package valeditor.ui.feathers.theme.flatcolor.components;
import feathers.controls.Alert;
import feathers.controls.ButtonBar;
import feathers.controls.Label;
import feathers.layout.HorizontalDistributedLayout;
import feathers.layout.HorizontalLayout;
import feathers.layout.HorizontalLayoutData;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class AlertStyles 
{
	
	/**
	   
	   @param	theme
	   @param	styleProvider
	**/
	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Alert, null) == null) {
			styleProvider.setStyleFunction(Alert, null, function(alert:Alert):Void {
				var isDesktop = DeviceUtil.isDesktop();

				alert.autoHideScrollBars = !isDesktop;
				alert.fixedScrollBars = isDesktop;

				if (alert.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = theme.getLightFill();
					backgroundSkin.maxWidth = 276.0;
					alert.backgroundSkin = backgroundSkin;
				}
				if (alert.layout == null) {
					var layout = new HorizontalLayout();
					layout.paddingTop = 10.0;
					layout.paddingRight = 10.0;
					layout.paddingBottom = 10.0;
					layout.paddingLeft = 10.0;
					layout.gap = 6.0;
					layout.percentWidthResetEnabled = true;
					alert.layout = layout;
				}
			});
		}

		if (styleProvider.getStyleFunction(ButtonBar, Alert.CHILD_VARIANT_BUTTON_BAR) == null) {
			styleProvider.setStyleFunction(ButtonBar, Alert.CHILD_VARIANT_BUTTON_BAR, function(buttonBar:ButtonBar):Void {
				if (buttonBar.layout == null) {
					var layout = new HorizontalDistributedLayout();
					layout.paddingTop = 10.0;
					layout.paddingRight = 10.0;
					layout.paddingBottom = 10.0;
					layout.paddingLeft = 10.0;
					layout.gap = 6.0;
					buttonBar.layout = layout;
				}
			});
		}

		if (styleProvider.getStyleFunction(Label, Alert.CHILD_VARIANT_MESSAGE_LABEL) == null) {
			styleProvider.setStyleFunction(Label, Alert.CHILD_VARIANT_MESSAGE_LABEL, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getTextFormat_disabled();
				}
				if (label.layoutData == null) {
					label.layoutData = HorizontalLayoutData.fillHorizontal();
				}
				label.wordWrap = true;
			});
		}
	}
	
}