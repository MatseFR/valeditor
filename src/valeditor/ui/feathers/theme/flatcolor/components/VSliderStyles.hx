package valeditor.ui.feathers.theme.flatcolor.components;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.VSlider;
import feathers.layout.RelativePosition;
import feathers.skins.CircleSkin;
import feathers.skins.TabSkin;
import feathers.style.ClassVariantStyleProvider;
import valeditor.ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class VSliderStyles 
{

	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(VSlider, null) == null) {
			styleProvider.setStyleFunction(VSlider, null, function(slider:VSlider):Void {
				if (slider.thumbSkin == null) {
					var thumb = new Button();
					thumb.styleProvider = null;
					thumb.keepDownStateOnRollOut = true;

					var backgroundSkin = new CircleSkin();
					backgroundSkin.fill = theme.getLightFill();
					backgroundSkin.border = theme.getContrastBorderLight();
					backgroundSkin.setFillForState(ButtonState.DOWN, theme.getThemeFillLight());
					backgroundSkin.setFillForState(ButtonState.DISABLED, theme.getLightFillDark());
					backgroundSkin.width = 24.0;
					backgroundSkin.height = 24.0;
					thumb.backgroundSkin = backgroundSkin;

					var focusRectSkin = new CircleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					thumb.focusRectSkin = focusRectSkin;

					slider.thumbSkin = thumb;
				}

				if (slider.trackSkin == null) {
					var trackSkin = new TabSkin();
					trackSkin.fill = theme.getThemeFill();
					trackSkin.border = theme.getContrastBorderLight();
					trackSkin.cornerRadius = 8.0;
					trackSkin.cornerRadiusPosition = RelativePosition.BOTTOM;
					trackSkin.width = 8.0;
					trackSkin.height = 100.0;
					slider.trackSkin = trackSkin;

					// if the track skin is already styled, don't style the secondary
					// track skin with its default either
					if (slider.secondaryTrackSkin == null) {
						var secondaryTrackSkin = new TabSkin();
						secondaryTrackSkin.fill = theme.getLightFillLight();
						secondaryTrackSkin.border = theme.getContrastBorderLight();
						secondaryTrackSkin.cornerRadius = 8.0;
						secondaryTrackSkin.cornerRadiusPosition = RelativePosition.TOP;
						secondaryTrackSkin.width = 8.0;
						secondaryTrackSkin.height = 100.0;
						slider.secondaryTrackSkin = secondaryTrackSkin;
					}
				}
			});
		}
	}
	
}