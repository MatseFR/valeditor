package valeditor.ui.feathers.theme.flatcolor.components;
import feathers.controls.Button;
import feathers.controls.ListView;
import feathers.controls.PopUpListView;
import feathers.controls.popups.DropDownPopUpAdapter;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.skins.TriangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class PopUpListViewStyles 
{

	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(PopUpListView, null) == null) {
			styleProvider.setStyleFunction(PopUpListView, null, function(listView:PopUpListView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					listView.popUpAdapter = new DropDownPopUpAdapter();
				}
			});
		}
		if (styleProvider.getStyleFunction(Button, PopUpListView.CHILD_VARIANT_BUTTON) == null) {
			styleProvider.setStyleFunction(Button, PopUpListView.CHILD_VARIANT_BUTTON, function(button:Button):Void {
				styleProvider.getStyleFunction(Button, null)(button);

				button.horizontalAlign = HorizontalAlign.LEFT;
				button.gap = 1.0 / 0.0; // Math.POSITIVE_INFINITY bug workaround for swf
				button.minGap = 6.0;

				if (button.icon == null) {
					var icon = new TriangleSkin();
					icon.pointPosition = BOTTOM;
					icon.fill = theme.getContrastFill();
					icon.disabledFill = theme.getContrastFillLighter();
					icon.width = 8.0;
					icon.height = 4.0;
					button.icon = icon;
				}

				button.iconPosition = RelativePosition.RIGHT;
			});
		}
		if (styleProvider.getStyleFunction(ListView, PopUpListView.CHILD_VARIANT_LIST_VIEW) == null) {
			styleProvider.setStyleFunction(ListView, PopUpListView.CHILD_VARIANT_LIST_VIEW, function(listView:ListView):Void {
				styleProvider.getStyleFunction(ListView, ListView.VARIANT_POP_UP)(listView);
			});
		}
	}
	
}