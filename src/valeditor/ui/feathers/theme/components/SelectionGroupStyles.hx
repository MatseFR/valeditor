package valeditor.ui.feathers.theme.components;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.controls.SelectionGroup;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.UIConfig;

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