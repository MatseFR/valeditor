package valeditor.ui.feathers.theme.components;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.controls.value.base.ValueUI;
import valeditor.ui.feathers.theme.ValEditorTheme;

/**
 * ...
 * @author Matse
 */
class ValueUIStyles 
{

	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(ValueUI, null) == null)
		{
			styleProvider.setStyleFunction(ValueUI, null, function(group:ValueUI):Void
			{
				//if (group.backgroundSkin == null)
				//{
					//var backgroundSkin = new RectangleSkin();
					//backgroundSkin.fill = theme.getLightFillLight();
					//group.backgroundSkin = backgroundSkin;
				//}
				
				group.minWidth = UIConfig.VALUE_MIN_WIDTH;
				group.maxWidth = UIConfig.VALUE_MAX_WIDTH;
			});
		}
	}
	
}