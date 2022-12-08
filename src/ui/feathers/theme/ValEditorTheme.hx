package ui.feathers.theme;

import ui.feathers.theme.components.LabelStyles;
import ui.feathers.theme.components.LayoutGroupStyles;
import ui.feathers.theme.components.ToggleButtonStyles;
import ui.feathers.theme.components.ToggleLayoutGroupStyles;
import ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class ValEditorTheme extends FlatColorTheme
{
	
	/**
	   
	   @param	lightThemeColor
	   @param	darkThemeColor
	**/
	public function new(lightThemeColor:Int = 0xa0c0f0, darkThemeColor:Int = 0x4f6f9f)
	{
		super(lightThemeColor, darkThemeColor);
		
		LabelStyles.initialize(this);
		LayoutGroupStyles.initialize(this);
		ToggleButtonStyles.initialize(this);
		ToggleLayoutGroupStyles.initialize(this);
	}
	
}