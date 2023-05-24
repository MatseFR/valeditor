package ui.feathers.theme.components;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.controls.SelectionBox;
import ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
class SelectionBoxStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		SelectionBoxStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(SelectionBox, null) == null)
		{
			styleProvider.setStyleFunction(SelectionBox, null, default_style);
		}
	}
	
	static private function default_style(box:SelectionBox):Void
	{
		var skin:RectangleSkin = new RectangleSkin();
		skin.border = theme.getThemeBorder(UIConfig.SELECTION_BOX_THICKNESS);
		
		box.backgroundSkin = skin;
	}
	
}