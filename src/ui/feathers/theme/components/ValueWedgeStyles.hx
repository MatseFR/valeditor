package ui.feathers.theme.components;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.controls.ValueWedge;
import ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
class ValueWedgeStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ValueWedgeStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(ValueWedge, null) == null)
		{
			styleProvider.setStyleFunction(ValueWedge, null, default_style);
		}
	}
	
	static public function default_style(wedge:ValueWedge):Void
	{
		wedge.minWidth = UIConfig.VALUE_NAME_MIN_WIDTH;
		wedge.maxWidth = UIConfig.VALUE_NAME_MAX_WIDTH;
	}
	
}