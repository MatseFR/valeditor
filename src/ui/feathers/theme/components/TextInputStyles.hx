package ui.feathers.theme.components;
import feathers.controls.TextInput;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.ValEditorTheme;
import ui.feathers.theme.simple.SimpleTheme;
import ui.feathers.variant.TextInputVariant;

/**
 * ...
 * @author Matse
 */
class TextInputStyles 
{
	static private var theme:SimpleTheme;

	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		TextInputStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(TextInput, TextInputVariant.NUMERIC) == null)
		{
			styleProvider.setStyleFunction(TextInput, TextInputVariant.NUMERIC, textInput_numeric);
		}
	}
	
	static private function textInput_numeric(input:TextInput):Void
	{
		ui.feathers.theme.simple.components.TextInputStyles.textInput(input);
		
		input.minWidth = 60;
	}
	
}