package valeditor.ui.feathers.theme.components;
import feathers.controls.Button;
import feathers.controls.ButtonState;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Shape;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.variant.ButtonVariant;

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
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.ADD) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.ADD, add);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.REMOVE) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.REMOVE, remove);
		}
		
		if (styleProvider.getStyleFunction(Button, ButtonVariant.RENAME) == null)
		{
			styleProvider.setStyleFunction(Button, ButtonVariant.RENAME, rename);
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
		
		//if (btn.textFormat == null) {
			//btn.textFormat = theme.getTextFormat();
		//}
		//if (btn.disabledTextFormat == null) {
			//btn.disabledTextFormat = theme.getTextFormat_disabled();
		//}
		
		//btn.paddingTop = 4.0;
		//btn.paddingRight = 10.0;
		//btn.paddingBottom = 4.0;
		//btn.paddingLeft = 10.0;
		//btn.gap = 4.0;
	}
	
	static private function add(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		drawAddIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		drawAddIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function remove(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		drawRemoveIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		drawRemoveIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function rename(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		drawRenameIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		drawRenameIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function frameFirst(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		drawFrameFirstIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		drawFrameFirstIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function frameLast(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		drawFrameLastIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		drawFrameLastIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function frameNext(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		drawFrameNextIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		drawFrameNextIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function framePrevious(btn:Button):Void
	{
		common(btn);
		
		var icon:Shape = new Shape();
		drawFramePreviousIcon(icon, theme.contrastColor);
		btn.icon = icon;
		
		icon = new Shape();
		drawFramePreviousIcon(icon, theme.contrastColorLighter);
		btn.setIconForState(DISABLED, icon);
	}
	
	static private function drawAddIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.drawRect(4.0, 9.0, 12.0, 2.0);
		//icon.graphics.drawRect(9.0, 4.0, 2.0, 12.0);
		icon.graphics.drawRect(9.0, 4.0, 2.0, 5.0);
		icon.graphics.drawRect(9.0, 11.0, 2.0, 5.0);
		icon.graphics.endFill();
	}
	
	static private function drawRemoveIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.drawRect(4.0, 9.0, 12.0, 2.0);
		icon.graphics.endFill();
	}
	
	static private function drawRenameIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.drawRect(7.0, 4.0, 6.0, 2.0);
		icon.graphics.drawRect(7.0, 14.0, 6.0, 2.0);
		icon.graphics.drawRect(9.0, 6.0, 2.0, 8.0);
		icon.graphics.endFill();
	}
	
	static private function drawFrameFirstIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(16.0, 4.0);
		icon.graphics.lineTo(8.0, 10.0);
		icon.graphics.lineTo(16.0, 16.0);
		icon.graphics.lineTo(16.0, 4.0);
		icon.graphics.drawRect(4.0, 4.0, 2.0, 12.0);
		icon.graphics.endFill();
	}
	
	static private function drawFrameLastIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(4.0, 4.0);
		icon.graphics.lineTo(12.0, 10.0);
		icon.graphics.lineTo(4.0, 16.0);
		icon.graphics.lineTo(4.0, 4.0);
		icon.graphics.drawRect(14.0, 4.0, 2.0, 12.0);
		icon.graphics.endFill();
	}
	
	static private function drawFrameNextIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(8.0, 4.0);
		icon.graphics.lineTo(16.0, 10.0);
		icon.graphics.lineTo(8.0, 16.0);
		icon.graphics.lineTo(8.0, 4.0);
		icon.graphics.drawRect(4.0, 4.0, 2.0, 12.0);
		icon.graphics.endFill();
	}
	
	static private function drawFramePreviousIcon(icon:Shape, color:Int):Void
	{
		icon.graphics.beginFill(0xff00ff, 0.0);
		icon.graphics.drawRect(0.0, 0.0, 20.0, 20.0);
		icon.graphics.endFill();
		icon.graphics.beginFill(color);
		icon.graphics.moveTo(12.0, 4.0);
		icon.graphics.lineTo(4.0, 10.0);
		icon.graphics.lineTo(12.0, 16.0);
		icon.graphics.lineTo(12.0, 4.0);
		icon.graphics.drawRect(14.0, 4.0, 2.0, 12.0);
		icon.graphics.endFill();
	}
	
}