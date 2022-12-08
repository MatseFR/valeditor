package ui.feathers.theme.components;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.layout.HorizontalAlign;
import feathers.layout.RelativePosition;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.ValEditorTheme;
import ui.feathers.variant.ToggleButtonVariant;

/**
 * ...
 * @author Matse
 */
@:access(ui.feathers.theme.ValEditorTheme)
class ToggleButtonStyles 
{
	static private var theme:ValEditorTheme;

	/**
	   
	   @param	theme
	**/
	public static function initialize(theme:ValEditorTheme):Void
	{
		ToggleButtonStyles.theme = theme;
		var styleProvider:ClassVariantStyleProvider = theme.styleProvider;
		styleProvider.setStyleFunction(ToggleButton, ToggleButtonVariant.GROUP_HEADER, group);
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
	}
	
}