package ui.feathers.theme.simple.components;
import feathers.controls.ListView;
import feathers.layout.VerticalListLayout;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class ListViewStyles 
{
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		function styleListViewWithBorderVariant(listView:ListView):Void {
			var isDesktop = DeviceUtil.isDesktop();
			
			listView.autoHideScrollBars = !isDesktop;
			listView.fixedScrollBars = isDesktop;
			
			if (listView.layout == null) {
				var layout = new VerticalListLayout();
				layout.requestedRowCount = 5.0;
				listView.layout = layout;
			}
			
			if (listView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getLightFill();
				backgroundSkin.border = theme.getContrastBorderLight();
				backgroundSkin.width = 10.0;
				backgroundSkin.height = 10.0;
				listView.backgroundSkin = backgroundSkin;
			}
			
			if (listView.focusRectSkin == null) {
				var focusRectSkin = new RectangleSkin();
				focusRectSkin.fill = null;
				focusRectSkin.border = theme.getFocusBorder();
				listView.focusRectSkin = focusRectSkin;
			}
			
			listView.paddingTop = 1.0;
			listView.paddingRight = 1.0;
			listView.paddingBottom = 1.0;
			listView.paddingLeft = 1.0;
		}
		
		function styleListViewWithBorderlessVariant(listView:ListView):Void {
			var isDesktop = DeviceUtil.isDesktop();
			
			listView.autoHideScrollBars = !isDesktop;
			listView.fixedScrollBars = isDesktop;
			
			if (listView.layout == null) {
				var layout = new VerticalListLayout();
				layout.requestedRowCount = 5.0;
				listView.layout = layout;
			}
			
			if (listView.backgroundSkin == null) {
				var backgroundSkin = new RectangleSkin();
				backgroundSkin.fill = theme.getLightFill();
				backgroundSkin.width = 10.0;
				backgroundSkin.height = 10.0;
				listView.backgroundSkin = backgroundSkin;
			}
			
			if (listView.focusRectSkin == null) {
				var focusRectSkin = new RectangleSkin();
				focusRectSkin.fill = null;
				focusRectSkin.border = theme.getFocusBorder();
				listView.focusRectSkin = focusRectSkin;
			}
		}
		
		if (styleProvider.getStyleFunction(ListView, null) == null) {
			styleProvider.setStyleFunction(ListView, null, function(listView:ListView):Void {
				var isDesktop = DeviceUtil.isDesktop();
				if (isDesktop) {
					styleListViewWithBorderVariant(listView);
				} else {
					styleListViewWithBorderlessVariant(listView);
				}
			});
		}
		if (styleProvider.getStyleFunction(ListView, ListView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(ListView, ListView.VARIANT_BORDER, styleListViewWithBorderVariant);
		}
		if (styleProvider.getStyleFunction(ListView, ListView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(ListView, ListView.VARIANT_BORDERLESS, styleListViewWithBorderlessVariant);
		}
		if (styleProvider.getStyleFunction(ListView, ListView.VARIANT_POP_UP) == null) {
			styleProvider.setStyleFunction(ListView, ListView.VARIANT_POP_UP, function(listView:ListView):Void {
				if (listView.layout == null) {
					var layout = new VerticalListLayout();
					layout.requestedMinRowCount = 1.0;
					layout.requestedMaxRowCount = 5.0;
					listView.layout = layout;
				}
				
				styleListViewWithBorderVariant(listView);
			});
		}
	}
	
}