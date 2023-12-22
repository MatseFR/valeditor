package valeditor.ui.feathers.theme.components;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Shape;
import valeditor.ui.feathers.theme.IconGraphics;
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
		
		if (styleProvider.getStyleFunction(ToggleButton, ToggleButtonVariant.PLAY_STOP) == null)
		{
			styleProvider.setStyleFunction(ToggleButton, ToggleButtonVariant.PLAY_STOP, playStop);
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
		IconGraphics.drawDisclosureClosedIcon(defaultIcon, theme.contrastColor);
		btn.icon = defaultIcon;
		
		var selectedIcon:Shape = new Shape();
		IconGraphics.drawDisclosureOpenIcon(selectedIcon, theme.contrastColor);
		btn.selectedIcon = selectedIcon;
		
		if (btn.focusRectSkin == null)
		{
			skin = new RectangleSkin();
			skin.fill = null;
			skin.border = theme.getFocusBorder();
			btn.focusRectSkin = skin;
		}
	}
	
	static private function playStop(btn:ToggleButton):Void
	{
		if (btn.backgroundSkin == null) {
			var skin = new RectangleSkin();
			skin.fill = theme.getLightFill();
			skin.disabledFill = theme.getLightFillDark();
			skin.selectedFill = theme.getLightFill();
			skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
			skin.setFillForState(ToggleButtonState.HOVER(true), theme.getThemeFillLight());
			skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFill());
			skin.setFillForState(ToggleButtonState.DOWN(true), theme.getThemeFill());
			skin.border = theme.getContrastBorderLight();
			skin.disabledBorder = theme.getContrastBorderLighter();
			skin.selectedBorder = theme.getContrastBorderLight();
			//skin.setBorderForState(ToggleButtonState.HOVER(false), theme.getLightBorderDark());
			//skin.setBorderForState(ToggleButtonState.HOVER(true), theme.getThemeBorder());
			skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getThemeBorderDark());
			skin.setBorderForState(ToggleButtonState.DOWN(true), theme.getThemeBorderDark());
			skin.cornerRadius = 3.0;
			btn.backgroundSkin = skin;
		}
		
		var icon:Shape = new Shape();
		IconGraphics.drawPlayIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawPlayIcon(icon, theme.contrastColorLighter);
		btn.disabledIcon = icon;
		
		icon = new Shape();
		IconGraphics.drawStopIcon(icon, theme.contrastColor);
		btn.selectedIcon = icon;
		
		icon = new Shape();
		IconGraphics.drawStopIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED(true), icon);
		
		if (btn.focusRectSkin == null) {
			var focusRectSkin = new RectangleSkin();
			focusRectSkin.fill = null;
			focusRectSkin.border = theme.getFocusBorder();
			focusRectSkin.cornerRadius = 3.0;
			btn.focusRectSkin = focusRectSkin;
		}
		
		//if (btn.textFormat == null) {
			//btn.textFormat = theme.getTextFormat();
		//}
		//if (btn.disabledTextFormat == null) {
			//btn.disabledTextFormat = theme.getTextFormat_disabled();
		//}
		
		//btn.paddingTop = 4.0;
		//btn.paddingRight = 10.0;
		//btn.paddingBottom = 4.0;
		//btn.paddingLeft = 10.0;
		//btn.gap = 4.0;
	}
	
}