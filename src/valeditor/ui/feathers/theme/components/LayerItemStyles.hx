package valeditor.ui.feathers.theme.components;
import feathers.controls.ToggleButtonState;
import feathers.skins.UnderlineSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.renderers.LayerItemRenderer;
import valeditor.ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
class LayerItemStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		LayerItemStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(LayerItemRenderer, null) == null)
		{
			styleProvider.setStyleFunction(LayerItemRenderer, null, default_style);
		}
	}
	
	static private function default_style(item:LayerItemRenderer):Void
	{
		var size:Float = 18.0;
		
		item.height = size;
		item.minHeight = size;
		
		if (item.backgroundSkin == null)
		{
			var skin:UnderlineSkin = new UnderlineSkin();
			skin.fill = theme.getLightFillLight();
			skin.border = theme.getLightBorderDark();
			skin.selectedFill = theme.getThemeFill();
			skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
			skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFill());
			
			skin.width = size;
			skin.height = size;
			skin.minWidth = size;
			skin.minHeight = size;
			
			item.backgroundSkin = skin;
		}
	}
	
}