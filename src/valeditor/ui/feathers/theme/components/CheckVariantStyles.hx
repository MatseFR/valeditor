package valeditor.ui.feathers.theme.components;
import feathers.controls.Check;
import feathers.controls.ToggleButtonState;
import feathers.graphics.FillStyle;
import feathers.skins.MultiSkin;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Shape;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.theme.variant.CheckVariant;

/**
 * ...
 * @author Matse
 */
class CheckVariantStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		CheckVariantStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(Check, CheckVariant.LAYER) == null)
		{
			styleProvider.setStyleFunction(Check, CheckVariant.LAYER, layer);
		}
	}
	
	static private function layer(check:Check):Void
	{
		var size:Float = 16.0;
		
		if (check.textFormat == null)
		{
			check.textFormat = theme.getTextFormat();
		}
		
		if (check.disabledTextFormat == null)
		{
			check.disabledTextFormat = theme.getTextFormat_disabled();
		}
		
		if (check.backgroundSkin == null)
		{
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = FillStyle.SolidColor(0xff0000, 0.0);
			backgroundSkin.border = null;
			check.backgroundSkin = backgroundSkin;
		}
		
		if (check.icon == null)
		{
			var icon = new MultiSkin();
			check.icon = icon;
			
			var defaultIcon = new RectangleSkin();
			defaultIcon.width = size;
			defaultIcon.height = size;
			defaultIcon.minWidth = size;
			defaultIcon.minHeight = size;
			defaultIcon.border = theme.getContrastBorderLight();
			defaultIcon.disabledBorder = theme.getContrastBorderLighter();
			defaultIcon.setBorderForState(DOWN(false), theme.getThemeBorderDark());
			defaultIcon.setFillForState(DOWN(false), theme.getThemeFillDark());
			defaultIcon.setFillForState(HOVER(false), theme.getThemeFillLight());
			defaultIcon.fill = theme.getLightFillLight();
			defaultIcon.disabledFill = theme.getLightFillDark();
			icon.defaultView = defaultIcon;
			
			var selectedIcon = new RectangleSkin();
			selectedIcon.width = size;
			selectedIcon.height = size;
			selectedIcon.minWidth = size;
			selectedIcon.minHeight = size;
			selectedIcon.border = theme.getThemeBorderDark();
			selectedIcon.setFillForState(HOVER(true), theme.getThemeFillLight());
			selectedIcon.setFillForState(DOWN(true), theme.getThemeFillDark());
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
			checkMark.x = size / 2.0;
			checkMark.y = size / 2.0;
			selectedIcon.addChild(checkMark);
			icon.selectedView = selectedIcon;
			
			var disabledAndSelectedIcon = new RectangleSkin();
			disabledAndSelectedIcon.width = size;
			disabledAndSelectedIcon.height = size;
			disabledAndSelectedIcon.minWidth = size;
			disabledAndSelectedIcon.minHeight = size;
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
			disabledCheckMark.x = size / 2.0;
			disabledCheckMark.y = size / 2.0;
			disabledAndSelectedIcon.addChild(disabledCheckMark);
			icon.setViewForState(DISABLED(true), disabledAndSelectedIcon);
		}
		
		if (check.focusRectSkin == null)
		{
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
	}
	
}