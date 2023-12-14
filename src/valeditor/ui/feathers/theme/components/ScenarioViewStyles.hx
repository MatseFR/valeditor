package valeditor.ui.feathers.theme.components;
import feathers.style.ClassVariantStyleProvider;
import valeditor.editor.UIAssets;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.view.ScenarioView;

/**
 * ...
 * @author Matse
 */
class ScenarioViewStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ScenarioViewStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(ScenarioView, null) == null)
		{
			styleProvider.setStyleFunction(ScenarioView, null, scenario_default);
		}
	}
	
	static private function scenario_default(scenario:ScenarioView):Void
	{
		if (theme.darkMode)
		{
			scenario.lockIconBitmapData = UIAssets.darkMode.lockIcon;
			scenario.visibleIconBitmapData = UIAssets.darkMode.visibleIcon;
		}
		else
		{
			scenario.lockIconBitmapData = UIAssets.lightMode.lockIcon;
			scenario.visibleIconBitmapData = UIAssets.lightMode.visibleIcon;
		}
	}
	
}