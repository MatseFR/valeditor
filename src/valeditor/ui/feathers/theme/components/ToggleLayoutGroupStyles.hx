package valeditor.ui.feathers.theme.components;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.controls.ToggleLayoutGroup;
import valeditor.ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
class ToggleLayoutGroupStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ToggleLayoutGroupStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(ToggleLayoutGroup, null) == null)
		{
			styleProvider.setStyleFunction(ToggleLayoutGroup, null, default_style);
		}
	}
	
	static public function default_style(group:ToggleLayoutGroup):Void
	{
		if (group.contentLayout == null)
		{
			var vLayout:VerticalLayout = new VerticalLayout();
			vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
			vLayout.verticalAlign = VerticalAlign.TOP;
			group.contentLayout = vLayout;
		}
	}
	
}