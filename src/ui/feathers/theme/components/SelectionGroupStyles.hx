package ui.feathers.theme.components;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.controls.SelectionGroup;
import ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
class SelectionGroupStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		SelectionGroupStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(SelectionGroup, null) == null)
		{
			styleProvider.setStyleFunction(SelectionGroup, null, default_style);
		}
	}
	
	static private function default_style(group:SelectionGroup):Void
	{
		var skin:RectangleSkin = new RectangleSkin();
		skin.border = theme.getThemeBorder(UIConfig.SELECTION_BOX_THICKNESS);
		
		group.backgroundSkin = skin;
	}
	
}