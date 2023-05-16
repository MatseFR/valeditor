package ui.feathers.theme.simple.components;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.skins.UnderlineSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class ItemRendererStyles 
{
	static private var theme:SimpleTheme;
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ItemRendererStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(ItemRenderer, null) == null)
		{
			styleProvider.setStyleFunction(ItemRenderer, null, Default);
		}
	}
	
	static private function Default(itemRenderer:ItemRenderer):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		if (itemRenderer.backgroundSkin == null) {
			var skin = new UnderlineSkin();
			skin.fill = theme.getLightFill();
			skin.border = theme.getLightBorderDark();
			skin.selectedFill = theme.getThemeFill();
			skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFillLight());
			if (isDesktop) {
				skin.width = 32.0;
				skin.height = 32.0;
				skin.minWidth = 32.0;
				skin.minHeight = 32.0;
			} else {
				skin.width = 44.0;
				skin.height = 44.0;
				skin.minWidth = 44.0;
				skin.minHeight = 44.0;
			}
			itemRenderer.backgroundSkin = skin;
		}
		
		if (itemRenderer.textFormat == null) {
			itemRenderer.textFormat = theme.getTextFormat();
		}
		if (itemRenderer.disabledTextFormat == null) {
			itemRenderer.disabledTextFormat = theme.getTextFormat_disabled();
		}
		if (itemRenderer.secondaryTextFormat == null) {
			itemRenderer.secondaryTextFormat = theme.getTextFormat_small();
		}
		if (itemRenderer.disabledSecondaryTextFormat == null) {
			itemRenderer.disabledSecondaryTextFormat = theme.getTextFormat_small_disabled();
		}
		
		itemRenderer.paddingTop = 4.0;
		itemRenderer.paddingRight = 10.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 10.0;
		itemRenderer.gap = 4.0;
		
		itemRenderer.horizontalAlign = LEFT;
	}
	
}