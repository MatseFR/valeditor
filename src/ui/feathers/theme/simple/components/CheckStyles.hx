package ui.feathers.theme.simple.components;
import feathers.controls.ToggleButtonState;
import feathers.controls.Check;
import feathers.graphics.FillStyle;
import feathers.graphics.LineStyle;
import feathers.skins.MultiSkin;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Shape;
import ui.feathers.theme.simple.SimpleTheme;

/**
 * ...
 * @author Matse
 */
class CheckStyles 
{
	
	static public function initialize(theme:SimpleTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		if (styleProvider.getStyleFunction(Check, null) == null) {
			styleProvider.setStyleFunction(Check, null, function(check:Check):Void {
				if (check.textFormat == null) {
					check.textFormat = theme.getTextFormat();
				}
				if (check.disabledTextFormat == null) {
					check.disabledTextFormat = theme.getTextFormat_disabled();
				}
				
				if (check.backgroundSkin == null) {
					var backgroundSkin = new RectangleSkin();
					backgroundSkin.fill = FillStyle.SolidColor(0xff0000, 0.0);
					backgroundSkin.border = null;
					check.backgroundSkin = backgroundSkin;
				}
				
				if (check.icon == null) {
					var icon = new MultiSkin();
					check.icon = icon;
					
					var defaultIcon = new RectangleSkin();
					defaultIcon.width = 20.0;
					defaultIcon.height = 20.0;
					defaultIcon.minWidth = 20.0;
					defaultIcon.minHeight = 20.0;
					defaultIcon.border = theme.getContrastBorderLight();
					defaultIcon.disabledBorder = theme.getContrastBorderLighter();
					defaultIcon.setBorderForState(DOWN(false), theme.getThemeBorderDark());
					defaultIcon.fill = theme.getLightFill();
					defaultIcon.disabledFill = theme.getLightFillDark();
					icon.defaultView = defaultIcon;
					
					var selectedIcon = new RectangleSkin();
					selectedIcon.width = 20.0;
					selectedIcon.height = 20.0;
					selectedIcon.minWidth = 20.0;
					selectedIcon.minHeight = 20.0;
					selectedIcon.border = theme.getThemeBorderDark();
					selectedIcon.disabledBorder = theme.getContrastBorderLighter();
					selectedIcon.setBorderForState(DOWN(true), theme.getThemeBorder());
					selectedIcon.fill = theme.getThemeFill();
					selectedIcon.disabledFill = theme.getThemeFillDark();
					var checkMark = new Shape();
					checkMark.graphics.beginFill(theme.contrastColor);
					checkMark.graphics.drawRect(-1.0, -8.0, 3.0, 14.0);
					checkMark.graphics.endFill();
					checkMark.graphics.beginFill(theme.contrastColor);
					checkMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
					checkMark.graphics.endFill();
					checkMark.rotation = 45.0;
					checkMark.x = 10.0;
					checkMark.y = 10.0;
					selectedIcon.addChild(checkMark);
					icon.selectedView = selectedIcon;
					
					var disabledAndSelectedIcon = new RectangleSkin();
					disabledAndSelectedIcon.width = 20.0;
					disabledAndSelectedIcon.height = 20.0;
					disabledAndSelectedIcon.minWidth = 20.0;
					disabledAndSelectedIcon.minHeight = 20.0;
					disabledAndSelectedIcon.border = theme.getContrastBorderLighter();
					disabledAndSelectedIcon.fill = theme.getThemeFillDark();
					var disabledCheckMark = new Shape();
					disabledCheckMark.graphics.beginFill(theme.contrastColorLighter);
					disabledCheckMark.graphics.drawRect(-1.0, -8.0, 3.0, 14.0);
					disabledCheckMark.graphics.endFill();
					disabledCheckMark.graphics.beginFill(theme.contrastColorLighter);
					disabledCheckMark.graphics.drawRect(-5.0, 3.0, 5.0, 3.0);
					disabledCheckMark.graphics.endFill();
					disabledCheckMark.rotation = 45.0;
					disabledCheckMark.x = 10.0;
					disabledCheckMark.y = 10.0;
					disabledAndSelectedIcon.addChild(disabledCheckMark);
					icon.setViewForState(DISABLED(true), disabledAndSelectedIcon);
				}
				
				if (check.focusRectSkin == null) {
					var focusRectSkin = new RectangleSkin();
					focusRectSkin.fill = null;
					focusRectSkin.border = theme.getFocusBorder();
					focusRectSkin.cornerRadius = 3.0;
					check.focusRectSkin = focusRectSkin;
					
					check.focusPaddingTop = 3.0;
					check.focusPaddingRight = 3.0;
					check.focusPaddingBottom = 3.0;
					check.focusPaddingLeft = 3.0;
				}
				
				check.horizontalAlign = LEFT;
				check.gap = 4.0;
			});
		}
	}
	
}