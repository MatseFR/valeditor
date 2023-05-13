package ui.feathers.theme;

import ui.feathers.theme.components.AssetItemRendererStyles;
import ui.feathers.theme.components.LabelStyles;
import ui.feathers.theme.components.LayoutGroupStyles;
import ui.feathers.theme.components.TextInputStyles;
import ui.feathers.theme.components.ToggleButtonStyles;
import ui.feathers.theme.components.ToggleCustomStyles;
import ui.feathers.theme.components.ToggleLayoutGroupStyles;
import ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class ValEditorTheme extends SimpleTheme
{
	
	/**
	   
	   @param	lightThemeColor
	   @param	darkThemeColor
	**/
	public function new(lightThemeColor:Int = 0xa0c0f0, darkThemeColor:Int = 0x4f6f9f)
	{
		super(lightThemeColor, darkThemeColor);
		
		AssetItemRendererStyles.initialize(this, this.styleProvider);
		LabelStyles.initialize(this, this.styleProvider);
		LayoutGroupStyles.initialize(this, this.styleProvider);
		TextInputStyles.initialize(this, this.styleProvider);
		ToggleButtonStyles.initialize(this, this.styleProvider);
		ToggleCustomStyles.initialize(this, this.styleProvider);
		ToggleLayoutGroupStyles.initialize(this, this.styleProvider);
	}
	
}