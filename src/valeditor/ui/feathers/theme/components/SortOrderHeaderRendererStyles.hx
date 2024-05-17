package valeditor.ui.feathers.theme.components;
import feathers.controls.dataRenderers.SortOrderHeaderRenderer;
import feathers.layout.HorizontalAlign;
import feathers.skins.RectangleSkin;
import feathers.skins.TriangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.variant.SortOrderHeaderRendererVariant;

/**
 * ...
 * @author Matse
 */
class SortOrderHeaderRendererStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		SortOrderHeaderRendererStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(SortOrderHeaderRenderer, SortOrderHeaderRendererVariant.CENTER_ALIGNED) == null)
		{
			styleProvider.setStyleFunction(SortOrderHeaderRenderer, SortOrderHeaderRendererVariant.CENTER_ALIGNED, centerAligned);
		}
		
		if (styleProvider.getStyleFunction(SortOrderHeaderRenderer, SortOrderHeaderRendererVariant.CRAMPED) == null)
		{
			styleProvider.setStyleFunction(SortOrderHeaderRenderer, SortOrderHeaderRendererVariant.CRAMPED, cramped);
		}
	}
	
	static private function centerAligned(itemRenderer:SortOrderHeaderRenderer):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		if (itemRenderer.backgroundSkin == null)
		{
			var skin = new RectangleSkin();
			skin.fill = theme.getLightFillDark();
			if (isDesktop)
			{
				skin.width = 22.0;
				skin.height = 22.0;
				skin.minWidth = 22.0;
				skin.minHeight = 22.0;
			}
			else
			{
				skin.width = 44.0;
				skin.height = 44.0;
				skin.minWidth = 44.0;
				skin.minHeight = 44.0;
			}
			itemRenderer.backgroundSkin = skin;
		}
		
		if (itemRenderer.sortAscendingIcon == null) {
			var sortAscendingIcon = new TriangleSkin();
			sortAscendingIcon.pointPosition = TOP;
			sortAscendingIcon.fill = theme.getContrastFill();
			sortAscendingIcon.disabledFill = theme.getContrastFillLighter();
			sortAscendingIcon.width = 8.0;
			sortAscendingIcon.height = 4.0;
			itemRenderer.sortAscendingIcon = sortAscendingIcon;
		}
		
		if (itemRenderer.sortDescendingIcon == null) {
			var sortDescendingIcon = new TriangleSkin();
			sortDescendingIcon.pointPosition = BOTTOM;
			sortDescendingIcon.fill = theme.getContrastFill();
			sortDescendingIcon.disabledFill = theme.getContrastFillLighter();
			sortDescendingIcon.width = 8.0;
			sortDescendingIcon.height = 4.0;
			itemRenderer.sortDescendingIcon = sortDescendingIcon;
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
		
		itemRenderer.horizontalAlign = HorizontalAlign.CENTER;
	}
	
	static private function cramped(itemRenderer:SortOrderHeaderRenderer):Void
	{
		var isDesktop = DeviceUtil.isDesktop();
		
		if (itemRenderer.backgroundSkin == null)
		{
			var skin = new RectangleSkin();
			skin.fill = theme.getLightFillDark();
			if (isDesktop)
			{
				skin.width = 22.0;
				skin.height = 22.0;
				skin.minWidth = 22.0;
				skin.minHeight = 22.0;
			}
			else
			{
				skin.width = 44.0;
				skin.height = 44.0;
				skin.minWidth = 44.0;
				skin.minHeight = 44.0;
			}
			itemRenderer.backgroundSkin = skin;
		}
		
		if (itemRenderer.sortAscendingIcon == null) {
			var sortAscendingIcon = new TriangleSkin();
			sortAscendingIcon.pointPosition = TOP;
			sortAscendingIcon.fill = theme.getContrastFill();
			sortAscendingIcon.disabledFill = theme.getContrastFillLighter();
			sortAscendingIcon.width = 8.0;
			sortAscendingIcon.height = 4.0;
			itemRenderer.sortAscendingIcon = sortAscendingIcon;
		}
		
		if (itemRenderer.sortDescendingIcon == null) {
			var sortDescendingIcon = new TriangleSkin();
			sortDescendingIcon.pointPosition = BOTTOM;
			sortDescendingIcon.fill = theme.getContrastFill();
			sortDescendingIcon.disabledFill = theme.getContrastFillLighter();
			sortDescendingIcon.width = 8.0;
			sortDescendingIcon.height = 4.0;
			itemRenderer.sortDescendingIcon = sortDescendingIcon;
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
	
}