package ui.feathers.theme.components;
import feathers.controls.Label;
import feathers.style.ClassVariantStyleProvider;
import openfl.text.TextFormatAlign;
import ui.feathers.theme.ValEditorTheme;
import ui.feathers.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
@:access(ui.feathers.theme.ValEditorTheme)
class LabelStyles 
{
	static private var theme:ValEditorTheme;
	
	/**
	   
	   @param	theme
	**/
	static public function initialize(theme:ValEditorTheme):Void
	{
		LabelStyles.theme = theme;
		var styleProvider:ClassVariantStyleProvider = theme.styleProvider;
		styleProvider.setStyleFunction(Label, LabelVariant.NOTE, note);
		styleProvider.setStyleFunction(Label, LabelVariant.OBJECT_NAME, object_name);
		styleProvider.setStyleFunction(Label, LabelVariant.SUBVALUE_NAME, subValue_name);
		styleProvider.setStyleFunction(Label, LabelVariant.VALUE_NAME, value_name);
	}
	
	static private function note(label:Label):Void
	{
		label.textFormat = theme.getTextFormat_small_note(TextFormatAlign.JUSTIFY);
		label.textFormat.italic = true;
		label.wordWrap = true;
	}
	
	static private function object_name(label:Label):Void
	{
		label.textFormat = theme.getTextFormat(TextFormatAlign.RIGHT);
		label.textFormat.bold = true;
		label.wordWrap = true;
	}
	
	static private function subValue_name(label:Label):Void
	{
		label.textFormat = theme.getTextFormat(TextFormatAlign.RIGHT);
		label.width = UIConfig.VALUE_NAME_WIDTH;
		label.wordWrap = true;
	}
	
	static private function value_name(label:Label):Void
	{
		label.textFormat = theme.getTextFormat(TextFormatAlign.RIGHT);
		label.textFormat.bold = true;
		label.width = UIConfig.VALUE_NAME_WIDTH;
		label.wordWrap = true;
	}
	
}