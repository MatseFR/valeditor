package valeditor.ui.feathers.theme.simple.components;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.GridView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.graphics.FillStyle;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalListLayout;
import feathers.skins.RectangleSkin;
import feathers.skins.VerticalLineSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DeviceUtil;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class GridViewStyles 
{
	static private var theme:SimpleTheme;

	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		GridViewStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(GridView, null) == null)
		{
			if (DeviceUtil.isDesktop())
			{
				styleProvider.setStyleFunction(GridView, null, border);
			}
			else
			{
				styleProvider.setStyleFunction(GridView, null, borderLess);
			}
		}
		
		if (styleProvider.getStyleFunction(GridView, GridView.VARIANT_BORDER) == null)
		{
			styleProvider.setStyleFunction(GridView, GridView.VARIANT_BORDER, border);
		}
		
		if (styleProvider.getStyleFunction(GridView, GridView.VARIANT_BORDERLESS) == null)
		{
			styleProvider.setStyleFunction(GridView, GridView.VARIANT_BORDERLESS, borderLess);
		}
		
		if (styleProvider.getStyleFunction(ItemRenderer, GridView.CHILD_VARIANT_HEADER_RENDERER) == null)
		{
			styleProvider.setStyleFunction(ItemRenderer, GridView.CHILD_VARIANT_HEADER_RENDERER, function(itemRenderer:ItemRenderer):Void
			{
				var isDesktop:Bool = DeviceUtil.isDesktop();
				
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
				
				if (itemRenderer.textFormat == null)
				{
					itemRenderer.textFormat = theme.getTextFormat();
				}
				
				if (itemRenderer.disabledTextFormat == null)
				{
					itemRenderer.disabledTextFormat = theme.getTextFormat();
				}
				
				if (itemRenderer.secondaryTextFormat == null)
				{
					itemRenderer.secondaryTextFormat = theme.getTextFormat_small();
				}
				
				if (itemRenderer.disabledSecondaryTextFormat == null)
				{
					itemRenderer.disabledSecondaryTextFormat = theme.getTextFormat_small_disabled();
				}
				
				itemRenderer.paddingTop = itemRenderer.paddingBottom = 4.0;
				itemRenderer.paddingLeft = itemRenderer.paddingRight = 10.0;
				itemRenderer.gap = 4.0;
				
				itemRenderer.horizontalAlign = HorizontalAlign.LEFT;
			});
		}
		
		if (styleProvider.getStyleFunction(Button, GridView.CHILD_VARIANT_HEADER_DIVIDER) == null)
		{
			styleProvider.setStyleFunction(Button, GridView.CHILD_VARIANT_HEADER_DIVIDER, function(headerDivider:Button):Void
			{
				var isDesktop:Bool = DeviceUtil.isDesktop();
				
				if (headerDivider.backgroundSkin == null)
				{
					var skin = new VerticalLineSkin();
					skin.border = theme.getLightBorderDarker();
					skin.fill = FillStyle.SolidColor(0xff00ff, 0.0);
					skin.setBorderForState(ButtonState.HOVER, theme.getThemeBorder());
					if (isDesktop)
					{
						skin.width = 6.0;
						skin.height = 1.0;
						skin.minWidth = 6.0;
						skin.minHeight = 1.0;
					}
					else
					{
						skin.width = 10.0;
						skin.height = 1.0;
						skin.minWidth = 10.0;
						skin.minHeight = 1.0;
					}
					headerDivider.backgroundSkin = skin;
				}
			});
		}
	}
	
	static private function border(gridView:GridView):Void
	{
		var isDesktop:Bool = DeviceUtil.isDesktop();
		
		gridView.autoHideScrollBars = !isDesktop;
		gridView.fixedScrollBars = isDesktop;
		
		if (gridView.layout == null)
		{
			var layout = new VerticalListLayout();
			layout.requestedRowCount = 5.0;
			gridView.layout = layout;
		}
		
		if (gridView.backgroundSkin == null)
		{
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = theme.getLightFill();
			backgroundSkin.border = theme.getLightBorderDark();
			backgroundSkin.width = 10.0;
			backgroundSkin.height = 10.0;
			gridView.backgroundSkin = backgroundSkin;
		}
		
		if (gridView.columnResizeSkin == null)
		{
			var columnResizeSkin = new RectangleSkin();
			columnResizeSkin.fill = theme.getThemeFill();
			columnResizeSkin.border = null;
			columnResizeSkin.width = 2.0;
			columnResizeSkin.height = 2.0;
			gridView.columnResizeSkin = columnResizeSkin;
		}
		
		if (gridView.focusRectSkin == null)
		{
			var focusRectSkin = new RectangleSkin();
			focusRectSkin.fill = null;
			focusRectSkin.border = theme.getFocusBorder();
			gridView.focusRectSkin = focusRectSkin;
		}
		
		gridView.showHeaderDividersOnlyWhenResizable = true;
		
		gridView.setPadding(1.0);
	}
	
	static private function borderLess(gridView:GridView):Void
	{
		var isDesktop:Bool = DeviceUtil.isDesktop();
		
		gridView.autoHideScrollBars = !isDesktop;
		gridView.fixedScrollBars = isDesktop;
		
		if (gridView.layout == null)
		{
			var layout = new VerticalListLayout();
			layout.requestedRowCount = 5.0;
			gridView.layout = layout;
		}
		
		if (gridView.backgroundSkin == null)
		{
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = theme.getLightFill();
			backgroundSkin.width = 10.0;
			backgroundSkin.height = 10.0;
			gridView.backgroundSkin = backgroundSkin;
		}
		
		if (gridView.columnResizeSkin == null)
		{
			var columnResizeSkin = new RectangleSkin();
			columnResizeSkin.fill = theme.getThemeFill();
			columnResizeSkin.border = null;
			columnResizeSkin.width = 2.0;
			columnResizeSkin.height = 2.0;
			gridView.columnResizeSkin = columnResizeSkin;
		}
		
		if (gridView.focusRectSkin == null)
		{
			var skin = new RectangleSkin();
			skin.fill = null;
			skin.border = theme.getFocusBorder();
			gridView.focusRectSkin = skin;
		}
		
		gridView.showHeaderDividersOnlyWhenResizable = true;
	}
	
}