package ui.feathers.theme.flatcolor.components;
import feathers.controls.Label;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class LabelStyles 
{

	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Label, null) == null) {
			styleProvider.setStyleFunction(Label, null, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getTextFormat_disabled();
				}
			});
		}
		if (styleProvider.getStyleFunction(Label, Label.VARIANT_HEADING) == null) {
			styleProvider.setStyleFunction(Label, Label.VARIANT_HEADING, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat_big();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getTextFormat_big_disabled();
				}
			});
		}
		if (styleProvider.getStyleFunction(Label, Label.VARIANT_DETAIL) == null) {
			styleProvider.setStyleFunction(Label, Label.VARIANT_DETAIL, function(label:Label):Void {
				if (label.textFormat == null) {
					label.textFormat = theme.getTextFormat_small();
				}
				if (label.disabledTextFormat == null) {
					label.disabledTextFormat = theme.getTextFormat_small_disabled();
				}
			});
		}
	}
	
}