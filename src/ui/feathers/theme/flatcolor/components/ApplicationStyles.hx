package ui.feathers.theme.flatcolor.components;
import feathers.controls.Application;
import feathers.core.ScreenDensityScaleManager;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Stage;
import ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class ApplicationStyles 
{
	
	/**
	   
	   @param	theme
	   @param	styleProvider
	**/
	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Application, null) == null) {
			styleProvider.setStyleFunction(Application, null, function(app:Application):Void {
				if (app.scaleManager == null) {
					app.scaleManager = new ScreenDensityScaleManager();
				}
				#if feathersui_theme_manage_stage_color
				refreshStageColor(app.stage, theme);
				#end
			});
		}
	}
	
	private static function refreshStageColor(stage:Stage, theme:FlatColorTheme):Void {
		if (stage == null) {
			return;
		}
		stage.color = theme.lightColorDark;
	}
	
}