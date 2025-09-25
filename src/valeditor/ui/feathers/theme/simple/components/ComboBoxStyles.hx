package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.ComboBox;
import feathers.controls.ListView;
import feathers.controls.TextInput;
import feathers.controls.TextInputState;
import feathers.layout.RelativePosition;
import feathers.skins.TabSkin;
import feathers.skins.TriangleSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class ComboBoxStyles 
{

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Button, ComboBox.CHILD_VARIANT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, ComboBox.CHILD_VARIANT_BUTTON, function(button:Button):Void {
				if (button.backgroundSkin == null) {
					var skin = new TabSkin();
					skin.cornerRadiusPosition = RelativePosition.RIGHT;
					skin.fill = theme.getLightFillLight();
					skin.disabledFill = theme.getLightFillDark();
					skin.setFillForState(ButtonState.DOWN, theme.getThemeFill());
					skin.setFillForState(ButtonState.HOVER, theme.getThemeFillLight());
					skin.border = theme.getContrastBorderLight();
					skin.setBorderForState(ButtonState.DOWN, theme.getThemeBorderDark());
					skin.disabledBorder = theme.getContrastBorderLighter();
					skin.cornerRadius = 3.0;
					button.backgroundSkin = skin;
				}
				
				if (button.icon == null) {
					var icon = new TriangleSkin();
					icon.pointPosition = BOTTOM;
					icon.fill = SolidColor(theme.contrastColor);
					icon.disabledFill = SolidColor(theme.contrastColorLighter);
					icon.width = 8.0;
					icon.height = 4.0;
					button.icon = icon;
				}
				
				button.paddingTop = 4.0;
				button.paddingRight = 10.0;
				button.paddingBottom = 4.0;
				button.paddingLeft = 10.0;
				button.gap = 4.0;
			});
		}
		
		if (styleProvider.getStyleFunction(TextInput, ComboBox.CHILD_VARIANT_TEXT_INPUT) == null) {
			styleProvider.setStyleFunction(TextInput, ComboBox.CHILD_VARIANT_TEXT_INPUT, function(input:TextInput):Void {
				if (input.backgroundSkin == null) {
					var inputSkin = new TabSkin();
					inputSkin.cornerRadiusPosition = LEFT;
					inputSkin.cornerRadius = 3.0;
					inputSkin.drawBaseBorder = false;
					inputSkin.width = 160.0;
					inputSkin.fill = theme.getLightFillLight();
					inputSkin.border = theme.getContrastBorderLight();
					inputSkin.disabledFill = theme.getLightFillDark();
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
				
				input.leftViewGap = 4.0;
			});
		}
		
		if (styleProvider.getStyleFunction(ListView, ComboBox.CHILD_VARIANT_LIST_VIEW) == null) {
			styleProvider.setStyleFunction(ListView, ComboBox.CHILD_VARIANT_LIST_VIEW, function(listView:ListView):Void {
				styleProvider.getStyleFunction(ListView, ListView.VARIANT_POP_UP)(listView);
			});
		}
	}
	
}