package valeditor.ui.feathers.theme.components;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Shape;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.variant.ToggleButtonVariant;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class ToggleButtonStyles 
{
	static private var theme:ValEditorTheme;

	/**
	   
	   @param	theme
	**/
	public static function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ToggleButtonStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(ToggleButton, ToggleButtonVariant.GROUP_HEADER) == null)
		{
			styleProvider.setStyleFunction(ToggleButton, ToggleButtonVariant.GROUP_HEADER, group);
		}
		
		if (styleProvider.getStyleFunction(ToggleButton, ToggleButtonVariant.PANEL) == null)
		{
			styleProvider.setStyleFunction(ToggleButton, ToggleButtonVariant.PANEL, panel);
		}
	}
	
	static private function group(btn:ToggleButton):Void
	{
		var skin:RectangleSkin = new RectangleSkin();
		skin.fill = theme.getLightFillDark();
		skin.selectedFill = theme.getThemeFill();
		skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
		skin.setFillForState(ToggleButtonState.HOVER(true), theme.getThemeFillLight());
		skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFill());
		skin.setFillForState(ToggleButtonState.DOWN(true), theme.getThemeFill());
		skin.border = theme.getLightBorderDarker();
		skin.selectedBorder = theme.getThemeBorderDark();
		skin.setBorderForState(ToggleButtonState.HOVER(false), theme.getLightBorderDark());
		skin.setBorderForState(ToggleButtonState.HOVER(true), theme.getThemeBorder());
		skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getLightBorderDark());
		skin.setBorderForState(ToggleButtonState.DOWN(true), theme.getThemeBorder());
		btn.backgroundSkin = skin;
		
		btn.iconPosition = RelativePosition.LEFT;
		btn.gap = Spacing.DEFAULT;
		btn.setPadding(Padding.TOGGLE);
		btn.horizontalAlign = HorizontalAlign.LEFT;
		btn.textFormat = theme.getTextFormat();
		btn.textFormat.bold = true;
		
		if (btn.focusRectSkin == null)
		{
			skin = new RectangleSkin();
			skin.fill = null;
			skin.border = theme.getFocusBorder();
			btn.focusRectSkin = skin;
		}
	}
	
	static private function panel(btn:ToggleButton):Void
	{
		var skin:RectangleSkin = new RectangleSkin();
		skin.fill = theme.getLightFillDark();
		skin.selectedFill = theme.getThemeFill();
		skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
		skin.setFillForState(ToggleButtonState.HOVER(true), theme.getThemeFillLight());
		skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFill());
		skin.setFillForState(ToggleButtonState.DOWN(true), theme.getThemeFill());
		skin.border = theme.getLightBorderDarker();
		skin.selectedBorder = theme.getThemeBorderDark();
		skin.setBorderForState(ToggleButtonState.HOVER(false), theme.getLightBorderDark());
		skin.setBorderForState(ToggleButtonState.HOVER(true), theme.getThemeBorder());
		skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getLightBorderDark());
		skin.setBorderForState(ToggleButtonState.DOWN(true), theme.getThemeBorder());
		btn.backgroundSkin = skin;
		
		btn.iconPosition = RelativePosition.LEFT;
		btn.gap = Spacing.DEFAULT;
		btn.setPadding(Padding.VALUE);
		btn.horizontalAlign = HorizontalAlign.LEFT;
		btn.textFormat = theme.getTextFormat();
		btn.textFormat.bold = true;
		
		var defaultIcon:Shape = new Shape();
		drawDisclosureClosedIcon(defaultIcon, theme.contrastColor);
		btn.icon = defaultIcon;
		
		var selectedIcon:Shape = new Shape();
		drawDisclosureOpenIcon(selectedIcon, theme.contrastColor);
		btn.selectedIcon = selectedIcon;
		
		if (btn.focusRectSkin == null)
		{
			skin = new RectangleSkin();
			skin.fill = null;
			skin.border = theme.getFocusBorder();
			btn.focusRectSkin = skin;
		}
	}
	
	private static function drawDisclosureClosedIcon(icon:Shape, color:UInt):Void {
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

	private static function drawDisclosureOpenIcon(icon:Shape, color:UInt):Void {
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