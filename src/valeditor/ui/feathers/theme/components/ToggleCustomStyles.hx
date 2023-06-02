package valeditor.ui.feathers.theme.components;
import feathers.controls.ToggleButtonState;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.controls.ToggleCustom;
import valeditor.ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
class ToggleCustomStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ToggleCustomStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(ToggleCustom, null) == null)
		{
			styleProvider.setStyleFunction(ToggleCustom, null, default_style);
		}
	}
	
	static public function default_style(group:ToggleCustom):Void
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