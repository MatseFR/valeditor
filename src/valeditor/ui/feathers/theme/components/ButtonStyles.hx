package valeditor.ui.feathers.theme.components;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Shape;
import valeditor.ui.feathers.theme.IconGraphics;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.theme.variant.ButtonVariant;

/**
 * ...
 * @author Matse
 */
class ButtonStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ButtonStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.MENU) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.MENU, menu);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.ADD) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.ADD, add);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.OPEN) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.OPEN, open);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.REMOVE) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.REMOVE, remove);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.RENAME) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.RENAME, rename);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.UP) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.UP, up);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.DOWN) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.DOWN, down);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.FRAME_FIRST) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.FRAME_FIRST, frameFirst);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.FRAME_LAST) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.FRAME_LAST, frameLast);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.FRAME_NEXT) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.FRAME_NEXT, frameNext);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.FRAME_PREVIOUS) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.FRAME_PREVIOUS, framePrevious);
		}
	}
	
	static private function common(btn:Button):Void
	{
		if (btn.backgroundSkin == null)
		{
			var skin = new RectangleSkin();
			skin.fill = theme.getLightFillLight();
			skin.disabledFill = theme.getLightFillDark();
			skin.setFillForState(DOWN, theme.getThemeFill());
			skin.setFillForState(HOVER, theme.getThemeFillLight());
			skin.border = theme.getContrastBorderLight();
			skin.setBorderForState(DOWN, theme.getThemeBorderDark());
			skin.disabledBorder = theme.getContrastBorderLighter();
			skin.cornerRadius = 3.0;
			btn.backgroundSkin = skin;
		}
		
		if (btn.focusRectSkin == null) {
			var focusRectSkin = new RectangleSkin();
			focusRectSkin.fill = null;
			focusRectSkin.border = theme.getFocusBorder();
			focusRectSkin.cornerRadius = 3.0;
			btn.focusRectSkin = focusRectSkin;
		}
	}
	
	static private function menu(btn:Button):Void
	{
		if (btn.backgroundSkin == null)
		{
			var skin = new RectangleSkin();
			skin.fill = theme.getLightFill();
			skin.setFillForState(DOWN, theme.getLightFillDark());
			skin.setFillForState(HOVER, theme.getLightFillDark());
			btn.backgroundSkin = skin;
		}
		if (btn.textFormat == null)
		{
			btn.textFormat = theme.getTextFormat();
		}
		if (btn.disabledTextFormat == null)
		{
			btn.disabledTextFormat = theme.getTextFormat_disabled();
		}
		
		btn.paddingTop = 4.0;
		btn.paddingRight = 10.0;
		btn.paddingBottom = 4.0;
		btn.paddingLeft = 10.0;
		btn.gap = 4.0;
	}
	
	static private function add(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawAddIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawAddIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function open(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawOpenIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawOpenIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function remove(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawRemoveIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawRemoveIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function rename(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawRenameIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawRenameIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function up(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawUpIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawUpIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function down(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawDownIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawDownIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function frameFirst(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawFrameFirstIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawFrameFirstIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function frameLast(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawFrameLastIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawFrameLastIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function frameNext(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawFrameNextIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawFrameNextIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function framePrevious(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		IconGraphics.drawFramePreviousIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		IconGraphics.drawFramePreviousIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
}