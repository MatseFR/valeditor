package valeditor.ui.feathers.theme.components;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.renderers.AssetItemRenderer;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.theme.simple.components.LayoutGroupItemRendererStyles;

/**
 * ...
 * @author Matse
 */
class AssetItemRendererStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		AssetItemRendererStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(AssetItemRenderer, null) == null)
		{
			styleProvider.setStyleFunction(AssetItemRenderer, null, assetItemRenderer);
		}
	}
	
	static private function assetItemRenderer(item:AssetItemRenderer):Void
	{
		LayoutGroupItemRendererStyles.itemRenderer_default(item);
		item.minWidth = item.width = 150;
	}
	
}