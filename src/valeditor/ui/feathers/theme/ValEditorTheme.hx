package valeditor.ui.feathers.theme;

import valeditor.ui.feathers.theme.components.AssetItemRendererStyles;
import valeditor.ui.feathers.theme.components.LabelStyles;
import valeditor.ui.feathers.theme.components.LayoutGroupStyles;
import valeditor.ui.feathers.theme.components.SelectionGroupStyles;
import valeditor.ui.feathers.theme.components.TextInputStyles;
import valeditor.ui.feathers.theme.components.ToggleButtonStyles;
import valeditor.ui.feathers.theme.components.ToggleCustomStyles;
import valeditor.ui.feathers.theme.components.ToggleLayoutGroupStyles;
import valeditor.ui.feathers.theme.components.NumericDraggerStyles;
import valeditor.ui.feathers.theme.components.ValueWedgeStyles;
import valeditor.ui.feathers.theme.simple.SimpleTheme;

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
		SelectionGroupStyles.initialize(this, this.styleProvider);
		TextInputStyles.initialize(this, this.styleProvider);
		ToggleButtonStyles.initialize(this, this.styleProvider);
		ToggleCustomStyles.initialize(this, this.styleProvider);
		ToggleLayoutGroupStyles.initialize(this, this.styleProvider);
		NumericDraggerStyles.initialize(this, this.styleProvider);
		ValueWedgeStyles.initialize(this, this.styleProvider);
	}
	
}