package valeditor.ui.feathers.theme.components;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.skins.UnderlineSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.renderers.MenuItemRenderer;
import valeditor.ui.feathers.variant.ItemRendererVariant;

/**
 * ...
 * @author Matse
 */
class ItemRendererStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ItemRendererStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(ItemRenderer, ItemRendererVariant.CRAMPED) == null)
		{
			styleProvider.setStyleFunction(ItemRenderer, ItemRendererVariant.CRAMPED, cramped);
		}
		
		if (styleProvider.getStyleFunction(MenuItemRenderer, null) == null)
		{
			styleProvider.setStyleFunction(MenuItemRenderer, null, menuItem);
		}
	}
	
	static private function cramped(itemRenderer:ItemRenderer):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		if (itemRenderer.backgroundSkin == null) {
			var skin = new UnderlineSkin();
			skin.fill = theme.getLightFillLight();
			skin.border = theme.getLightBorderDark();
			skin.selectedFill = theme.getThemeFill();
			skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
			skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFill());
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
		itemRenderer.paddingRight = 4.0;
		itemRenderer.paddingBottom = 4.0;
		itemRenderer.paddingLeft = 4.0;
		itemRenderer.gap = 4.0;
		
		itemRenderer.horizontalAlign = LEFT;
	}
	
	static private function menuItem(itemRenderer:MenuItemRenderer):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		if (itemRenderer.backgroundSkin == null) {
			var skin = new UnderlineSkin();
			skin.fill = theme.getLightFillLight();
			skin.border = theme.getLightBorderDark();
			skin.selectedFill = theme.getThemeFill();
			skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
			skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFill());
			skin.setFillForState(ToggleButtonState.DISABLED(true), theme.getLightFillLight());
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
	}
	
}