package ui.feathers.theme.components;
import feathers.controls.ToggleButtonState;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.controls.ToggleLayoutGroup;
import ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
@:access(ui.feathers.theme.ValEditorTheme)
class ToggleLayoutGroupStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme):Void
	{
		ToggleLayoutGroupStyles.theme = theme;
		var styleProvider:ClassVariantStyleProvider = theme.styleProvider;
		styleProvider.setStyleFunction(ToggleLayoutGroup, null, default_style);
	}
	
	static public function default_style(group:ToggleLayoutGroup):Void
	{
		var skin:RectangleSkin = new RectangleSkin();
		skin.fill = theme.getLightFillDark();
		skin.selectedFill = theme.getThemeFill();
		skin.setFillForState(ToggleButtonState.HOVER(false), theme.getThemeFillLight());
		skin.setFillForState(ToggleButtonState.HOVER(true), theme.getThemeFillLight());
		skin.setFillForState(ToggleButtonState.DOWN(false), theme.getThemeFillDark());
		skin.setFillForState(ToggleButtonState.DOWN(true), theme.getThemeFillDark());
		skin.border = theme.getLightBorderDarker();
		skin.selectedBorder = theme.getThemeBorderDark();
		skin.setBorderForState(ToggleButtonState.HOVER(false), theme.getLightBorderDark());
		skin.setBorderForState(ToggleButtonState.HOVER(true), theme.getThemeBorder());
		skin.setBorderForState(ToggleButtonState.DOWN(false), theme.getLightBorderDark());
		skin.setBorderForState(ToggleButtonState.DOWN(true), theme.getThemeBorder());
		group.backgroundSkin = skin;
	}
	
}