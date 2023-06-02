package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.controls.dataRenderers.HierarchicalItemRenderer;
import feathers.skins.MultiSkin;
import feathers.skins.UnderlineSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import openfl.display.Shape;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class HierarchicalItemRendererStyles 
{
	static private var theme:SimpleTheme;
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		HierarchicalItemRendererStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(HierarchicalItemRenderer, null) == null)
		{
			styleProvider.setStyleFunction(HierarchicalItemRenderer, null, Default);
		}
		
		if (styleProvider.getStyleFunction(ToggleButton, HierarchicalItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON) == null)
		{
			styleProvider.setStyleFunction(ToggleButton, HierarchicalItemRenderer.CHILD_VARIANT_DISCLOSURE_BUTTON, disclosure_button);
		}
	}
	
	static private function Default(itemRenderer:HierarchicalItemRenderer):Void
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
		
		itemRenderer.indentation = 20.0;
		
		itemRenderer.horizontalAlign = LEFT;
	}
	
	static private function disclosure_button(button:ToggleButton):Void
	{
		if (button.icon == null) {
			var icon = new MultiSkin();
			button.icon = icon;
			
			var defaultIcon = new Shape();
			drawDisclosureClosedIcon(defaultIcon, theme.contrastColor);
			icon.defaultView = defaultIcon;
			
			var disabledIcon = new Shape();
			drawDisclosureClosedIcon(disabledIcon, theme.contrastColorLight);
			icon.disabledView = disabledIcon;
			
			var selectedIcon = new Shape();
			drawDisclosureOpenIcon(selectedIcon, theme.contrastColor);
			icon.selectedView = selectedIcon;
			
			var selectedDisabledIcon = new Shape();
			drawDisclosureOpenIcon(selectedDisabledIcon, theme.contrastColorLight);
			icon.setViewForState(DISABLED(true), selectedDisabledIcon);
		}
	}
	
	static private function drawDisclosureClosedIcon(icon:Shape, color:UInt):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(16.0, 10.0);
		icon.graphics.lineTo(4.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}

	static private function drawDisclosureOpenIcon(icon:Shape, color:UInt):Void {
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(16.0, 4.0);
		icon.graphics.lineTo(10.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.endFill();
	}
	
}