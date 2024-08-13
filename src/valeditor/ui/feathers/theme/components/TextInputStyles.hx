package valeditor.ui.feathers.theme.components;
import feathers.controls.TextInput;
import feathers.layout.HorizontalLayoutData;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.theme.simple.SimpleTheme;
import valeditor.ui.feathers.theme.variant.TextInputVariant;
import valeditor.ui.feathers.theme.simple.components.TextInputStyles;

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
		
		if (styleProvider.getStyleFunction(TextInput, TextInputVariant.FULL_WIDTH) == null)
		{
			styleProvider.setStyleFunction(TextInput, TextInputVariant.FULL_WIDTH, textInput_full_width);
		}
		
		if (styleProvider.getStyleFunction(TextInput, TextInputVariant.NUMERIC_SMALL) == null)
		{
			styleProvider.setStyleFunction(TextInput, TextInputVariant.NUMERIC_SMALL, textInput_numeric_small);
		}
		
		if (styleProvider.getStyleFunction(TextInput, TextInputVariant.NUMERIC_MEDIUM) == null)
		{
			styleProvider.setStyleFunction(TextInput, TextInputVariant.NUMERIC_MEDIUM, textInput_numeric_medium);
		}
		
		if (styleProvider.getStyleFunction(TextInput, TextInputVariant.NUMERIC_LARGE) == null)
		{
			styleProvider.setStyleFunction(TextInput, TextInputVariant.NUMERIC_LARGE, textInput_numeric_large);
		}
	}
	
	static private function textInput_full_width(input:TextInput):Void
	{
		valeditor.ui.feathers.theme.simple.components.TextInputStyles.Default(input);
		
		input.layoutData = new HorizontalLayoutData(100);
	}
	
	static private function textInput_numeric_small(input:TextInput):Void
	{
		valeditor.ui.feathers.theme.simple.components.TextInputStyles.Default(input);
		
		if (input.layoutData != null && Std.isOfType(input.layoutData, HorizontalLayoutData))
		{
			input.layoutData = null;
		}
		input.minWidth = 60;
		input.width = input.minWidth;
	}
	
	static private function textInput_numeric_medium(input:TextInput):Void
	{
		valeditor.ui.feathers.theme.simple.components.TextInputStyles.Default(input);
		
		if (input.layoutData != null && Std.isOfType(input.layoutData, HorizontalLayoutData))
		{
			input.layoutData = null;
		}
		input.minWidth = 80;
		input.width = input.minWidth;
	}
	
	static private function textInput_numeric_large(input:TextInput):Void
	{
		valeditor.ui.feathers.theme.simple.components.TextInputStyles.Default(input);
		
		if (input.layoutData != null && Std.isOfType(input.layoutData, HorizontalLayoutData))
		{
			input.layoutData = null;
		}
		input.minWidth = 100;
		input.width = input.minWidth;
	}
	
}