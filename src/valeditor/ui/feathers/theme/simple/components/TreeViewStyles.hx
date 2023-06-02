package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.TreeView;
import feathers.layout.VerticalListLayout;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class TreeViewStyles 
{
	static private var theme:SimpleTheme;
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		TreeViewStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(TreeView, null) == null) {
			var isDesktop = DeviceUtil.isDesktop();
			if (isDesktop)
			{
				styleProvider.setStyleFunction(TreeView, null, border);
			}
			else
			{
				styleProvider.setStyleFunction(TreeView, null, borderLess);
			}
		}
		if (styleProvider.getStyleFunction(TreeView, TreeView.VARIANT_BORDER) == null) {
			styleProvider.setStyleFunction(TreeView, TreeView.VARIANT_BORDER, border);
		}
		if (styleProvider.getStyleFunction(TreeView, TreeView.VARIANT_BORDERLESS) == null) {
			styleProvider.setStyleFunction(TreeView, TreeView.VARIANT_BORDERLESS, borderLess);
		}
	}
	
	static private function border(treeView:TreeView):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		treeView.autoHideScrollBars = !isDesktop;
		treeView.fixedScrollBars = isDesktop;
		
		if (treeView.layout == null) {
			var layout = new VerticalListLayout();
			layout.requestedRowCount = 5.0;
			treeView.layout = layout;
		}
		
		if (treeView.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = theme.getLightFill();
			backgroundSkin.border = theme.getContrastBorder();
			backgroundSkin.width = 10.0;
			backgroundSkin.height = 10.0;
			treeView.backgroundSkin = backgroundSkin;
		}
		
		if (treeView.focusRectSkin == null) {
			var focusRectSkin = new RectangleSkin();
			focusRectSkin.fill = null;
			focusRectSkin.border = theme.getFocusBorder();
			treeView.focusRectSkin = focusRectSkin;
		}
		
		treeView.paddingTop = 1.0;
		treeView.paddingRight = 1.0;
		treeView.paddingBottom = 1.0;
		treeView.paddingLeft = 1.0;
	}
	
	static private function borderLess(treeView:TreeView):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		treeView.autoHideScrollBars = !isDesktop;
		treeView.fixedScrollBars = isDesktop;
		
		if (treeView.layout == null) {
			treeView.layout = new VerticalListLayout();
		}
		
		if (treeView.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = theme.getLightFill();
			backgroundSkin.width = 10.0;
			backgroundSkin.height = 10.0;
			treeView.backgroundSkin = backgroundSkin;
		}
		
		if (treeView.focusRectSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = null;
			skin.border = theme.getFocusBorder();
			treeView.focusRectSkin = skin;
		}
	}
	
}