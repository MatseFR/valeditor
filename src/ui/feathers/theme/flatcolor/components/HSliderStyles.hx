package ui.feathers.theme.flatcolor.components;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.controls.HSlider;
import feathers.layout.RelativePosition;
import feathers.skins.CircleSkin;
import feathers.skins.TabSkin;
import feathers.style.ClassVariantStyleProvider;
import ui.feathers.theme.flatcolor.FlatColorTheme;

/**
 * ...
 * @author Matse
 */
class HSliderStyles 
{

	static public function initialize(theme:FlatColorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(HSlider, null) == null) {
			styleProvider.setStyleFunction(HSlider, null, function(slider:HSlider):Void {
				if (slider.thumbSkin == null) {
					var thumb = new Button();
					thumb.styleProvider = null;
					thumb.keepDownStateOnRollOut = true;

					var backgroundSkin = new CircleSkin();
					backgroundSkin.fill = theme.getLightFill();
					backgroundSkin.border = theme.getContrastBorderLight();
					backgroundSkin.setFillForState(ButtonState.DOWN, theme.getThemeFillLight());
					backgroundSkin.setFillForState(ButtonState.DISABLED, theme.getLightFillDark());
					backgroundSkin.width = 22.0 + theme.lineThickness * 2;
					backgroundSkin.height = 22.0 + theme.lineThickness * 2;
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
					trackSkin.cornerRadius = 6.0 + theme.lineThickness * 2;
					trackSkin.cornerRadiusPosition = RelativePosition.LEFT;
					trackSkin.width = 100.0;
					trackSkin.height = 6.0 + theme.lineThickness * 2;
					slider.trackSkin = trackSkin;

					// if the track skin is already styled, don't style the secondary
					// track skin with its default either
					if (slider.secondaryTrackSkin == null) {
						var secondaryTrackSkin = new TabSkin();
						secondaryTrackSkin.fill = theme.getLightFillLight();
						secondaryTrackSkin.border = theme.getContrastBorderLight();
						secondaryTrackSkin.cornerRadius = 6.0 + theme.lineThickness * 2;
						secondaryTrackSkin.cornerRadiusPosition = RelativePosition.RIGHT;
						secondaryTrackSkin.width = 100.0;
						secondaryTrackSkin.height = 6.0 + theme.lineThickness * 2;
						slider.secondaryTrackSkin = secondaryTrackSkin;
					}
				}
			});
		}
	}
	
}