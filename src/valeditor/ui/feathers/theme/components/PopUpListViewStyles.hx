package valeditor.ui.feathers.theme.components;
import feathers.controls.PopUpListView;
import feathers.controls.popups.DropDownPopUpAdapter;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.theme.variant.ButtonVariant;
import valeditor.ui.feathers.theme.variant.PopUpListViewVariant;

/**
 * ...
 * @author Matse
 */
class PopUpListViewStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		PopUpListViewStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(PopUpListView, PopUpListViewVariant.MENU) == null)
		{
			styleProvider.setStyleFunction(PopUpListView, PopUpListViewVariant.MENU, menu);
		}
	}
	
	static private function menu(listView:PopUpListView):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		if (isDesktop) {
			listView.popUpAdapter = new DropDownPopUpAdapter();
		}
		
		listView.customButtonVariant = ButtonVariant.MENU;
	}
	
}