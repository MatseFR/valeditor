package ui.feathers.theme.flatcolor.components;
import feathers.controls.TextCallout;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.layout.Direction;
import feathers.skins.PillSkin;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class TextInputStyles 
{

	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(TextInput, null) == null) {
			styleProvider.setStyleFunction(TextInput, null, function(input:TextInput):Void {
				if (input.backgroundSkin == null) {
					var inputSkin = new RectangleSkin();
					inputSkin.cornerRadius = 3.0;
					inputSkin.width = 160.0;
					inputSkin.fill = theme.getLightFillLight();
					inputSkin.border = theme.getContrastBorderLight();
					inputSkin.disabledFill = theme.getLightFill();
					inputSkin.setBorderForState(TextInputState.FOCUSED, theme.getThemeBorder());
					inputSkin.setBorderForState(TextInputState.ERROR, theme.getDangerBorder());
					input.backgroundSkin = inputSkin;
				}

				if (input.textFormat == null) {
					input.textFormat = theme.getTextFormat();
				}
				if (input.disabledTextFormat == null) {
					input.disabledTextFormat = theme.getTextFormat_disabled();
				}
				if (input.promptTextFormat == null) {
					input.promptTextFormat = theme.getTextFormat_note();
				}

				input.paddingTop = 6.0;
				input.paddingRight = 10.0;
				input.paddingBottom = 6.0;
				input.paddingLeft = 10.0;
			});
		}
		if (styleProvider.getStyleFunction(TextInput, TextInput.VARIANT_SEARCH) == null) {
			styleProvider.setStyleFunction(TextInput, TextInput.VARIANT_SEARCH, function(input:TextInput):Void {
				if (input.backgroundSkin == null) {
					var inputSkin = new PillSkin();
					inputSkin.capDirection = Direction.HORIZONTAL;
					inputSkin.width = 160.0;
					inputSkin.fill = theme.getLightFillLight();
					inputSkin.border = theme.getContrastBorderLight();
					inputSkin.disabledFill = theme.getLightFill();
					inputSkin.setBorderForState(TextInputState.FOCUSED, theme.getThemeBorder());
					input.backgroundSkin = inputSkin;
				}

				if (input.textFormat == null) {
					input.textFormat = theme.getTextFormat();
				}
				if (input.disabledTextFormat == null) {
					input.disabledTextFormat = theme.getTextFormat_disabled();
				}
				if (input.promptTextFormat == null) {
					input.promptTextFormat = theme.getTextFormat_note();
				}

				input.paddingTop = 6.0;
				input.paddingRight = 10.0;
				input.paddingBottom = 6.0;
				input.paddingLeft = 10.0;
			});
		}
		if (styleProvider.getStyleFunction(TextCallout, TextInput.CHILD_VARIANT_ERROR_CALLOUT) == null) {
			styleProvider.setStyleFunction(TextCallout, TextInput.CHILD_VARIANT_ERROR_CALLOUT, function(callout:TextCallout):Void {
				styleProvider.getStyleFunction(TextCallout, TextCallout.VARIANT_DANGER)(callout);
			});
		}
	}
	
}