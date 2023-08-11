package valeditor.ui.feathers.theme.components;
import feathers.skins.TopAndBottomBorderSkin;
import feathers.style.ClassVariantStyleProvider;
import openfl.display.Shape;
import valeditor.ui.feathers.renderers.FrameItemRenderer;
import valeditor.ui.feathers.renderers.FrameItemState;
import valeditor.ui.feathers.skins.TopBottomAndRightSkin;

/**
 * ...
 * @author Matse
 */
class FrameItemRendererStyles 
{
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		FrameItemRendererStyles.theme = theme;
		
		if (styleProvider.getStyleFunction(FrameItemRenderer, null) == null)
		{
			styleProvider.setStyleFunction(FrameItemRenderer, null, default_style);
		}
	}
	
	static private function default_style(item:FrameItemRenderer):Void
	{
		var width:Float = 8;
		var height:Float = 18;
		var skinB:TopAndBottomBorderSkin;
		
		item.width = width;
		item.height = height;
		
		// FRAME
		var skin:TopBottomAndRightSkin = new TopBottomAndRightSkin();
		skin.fill = theme.getLightFill();
		skin.border = theme.getContrastBorderLighter();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.FRAME(false), skin);
		
		item.backgroundSkin = skin; // TODO : at runtime this is currently needed for items to have correct dimensions - find out why ?
		
		// FRAME selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorderLighter();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.FRAME(true), skin);
		
		// FRAME_5
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getLightFillDark();
		skin.border = theme.getContrastBorderLighter();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.FRAME_5(false), skin);
		
		// FRAME_5 selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorderLighter();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.FRAME_5(true), skin);
		
		// KEYFRAME_SINGLE
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getLightFillDarker();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_SINGLE(false), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_SINGLE(false), start_icon());
		
		// KEYFRAME_SINGLE selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_SINGLE(true), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_SINGLE(true), start_icon());
		
		// KEYFRAME_SINGLE_EMPTY
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getLightFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_SINGLE_EMPTY(false), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_SINGLE_EMPTY(false), start_empty_icon());
		
		// KEYFRAME_SINGLE_EMPTY selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_SINGLE_EMPTY(true), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_SINGLE_EMPTY(true), start_empty_icon());
		
		// KEYFRAME_SINGLE_TWEEN
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getThemeFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_SINGLE_TWEEN(false), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_SINGLE_TWEEN(false), start_tween_icon());
		
		// KEYFRAME_SINGLE_TWEEN selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_SINGLE_TWEEN(true), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_SINGLE_TWEEN(true), start_tween_icon());
		
		// KEYFRAME_SINGLE_TWEEN_EMPTY
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getLightFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_SINGLE_TWEEN_EMPTY(false), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_SINGLE_TWEEN_EMPTY(false), start_tween_empty_icon());
		
		// KEYFRAME_SINGLE_TWEEN_EMPTY selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_SINGLE_TWEEN_EMPTY(true), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_SINGLE_TWEEN_EMPTY(true), start_tween_empty_icon());
		
		// KEYFRAME_START
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getLightFillDarker();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_START(false), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_START(false), start_icon());
		
		// KEYFRAME_START selected
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getFocusFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_START(true), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_START(true), start_icon());
		
		// KEYFRAME_START_EMPTY
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getLightFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_START_EMPTY(false), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_START_EMPTY(false), start_empty_icon());
		
		// KEYFRAME_START_EMPTY selected
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getFocusFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_START_EMPTY(true), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_START_EMPTY(true), start_empty_icon());
		
		// KEYFRAME_START_TWEEN
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getThemeFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_START_TWEEN(false), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_START_TWEEN(false), start_tween_icon());
		
		// KEYFRAME_START_TWEEN selected
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getFocusFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_START_TWEEN(true), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_START_TWEEN(true), start_tween_icon());
		
		// KEYFRAME_START_TWEEN_EMPTY
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getLightFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_START_TWEEN_EMPTY(false), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_START_TWEEN_EMPTY(false), start_tween_empty_icon());
		
		// KEYFRAME_START_TWEEN_EMPTY selected
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getFocusFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_START_TWEEN_EMPTY(true), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_START_TWEEN_EMPTY(true), start_tween_empty_icon());
		
		// KEYFRAME
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getLightFillDarker();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME(false), skinB);
		
		// KEYFRAME selected
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getFocusFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME(true), skinB);
		
		// KEYFRAME_EMPTY
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getLightFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_EMPTY(false), skinB);
		
		// KEYFRAME_EMPTY selected
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getFocusFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_EMPTY(true), skinB);
		
		// KEYFRAME_TWEEN
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getThemeFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_TWEEN(false), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_TWEEN(false), tween_icon());
		
		// KEYFRAME_TWEEN selected
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getFocusFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_TWEEN(true), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_TWEEN(true), tween_icon());
		
		// KEYFRAME_TWEEN_EMPTY
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getLightFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_TWEEN_EMPTY(false), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_TWEEN_EMPTY(false), tween_empty_icon());
		
		// KEYFRAME_TWEEN_EMPTY selected
		skinB = new TopAndBottomBorderSkin();
		skinB.fill = theme.getFocusFill();
		skinB.border = theme.getContrastBorder();
		skinB.width = width;
		skinB.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_TWEEN_EMPTY(false), skinB);
		
		item.setIconForState(FrameItemState.KEYFRAME_TWEEN_EMPTY(false), tween_empty_icon());
		
		// KEYFRAME_END
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getLightFillDarker();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_END(false), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_END(false), end_icon());
		
		// KEYFRAME_END selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_END(true), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_END(true), end_icon());
		
		// KEYFRAME_END_EMPTY
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getLightFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_END_EMPTY(false), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_END_EMPTY(false), end_icon());
		
		// KEYFRAME_END_EMPTY selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_END_EMPTY(true), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_END_EMPTY(true), end_icon());
		
		// KEYFRAME_END_TWEEN
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getThemeFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_END_TWEEN(false), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_END_TWEEN(false), end_tween_icon());
		
		// KEYFRAME_END_TWEEN selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_END_TWEEN(true), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_END_TWEEN(true), end_tween_icon());
		
		// KEYFRAME_END_TWEEN_EMPTY
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getLightFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_END_TWEEN_EMPTY(false), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_END_TWEEN_EMPTY(false), end_tween_empty_icon());
		
		// KEYFRAME_END_TWEEN_EMPTY selected
		skin = new TopBottomAndRightSkin();
		skin.fill = theme.getFocusFill();
		skin.border = theme.getContrastBorder();
		skin.width = width;
		skin.height = height;
		item.setSkinForState(FrameItemState.KEYFRAME_END_TWEEN_EMPTY(true), skin);
		
		item.setIconForState(FrameItemState.KEYFRAME_END_TWEEN_EMPTY(true), end_tween_empty_icon());
	}
	
	static private function start_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(theme.contrastColor, 0);
		icon.graphics.drawRect(0, 0, 6, 8);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawCircle(1 + 2.5, 2.5, 2.5);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function start_empty_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(0, 0);
		icon.graphics.drawRect(0, 0, 6, 8);
		//icon.graphics.lineStyle(1, theme.contrastColor);
		//icon.graphics.drawCircle(1 + 2.5, 2.5, 2.5);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawRect(2, 0, 3, 1);
		icon.graphics.drawRect(2, 4, 3, 1);
		icon.graphics.drawRect(1, 1, 1, 3);
		icon.graphics.drawRect(5, 1, 1, 3);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function start_tween_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(theme.contrastColor, 0);
		icon.graphics.drawRect(0, 0, 8, 8);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawCircle(1 + 2.5, 2.5, 2.5);
		icon.graphics.drawRect(6, 2, 2, 1);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function start_tween_empty_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(0, 0);
		icon.graphics.drawRect(0, 0, 6, 8);
		//icon.graphics.lineStyle(1, theme.contrastColor);
		//icon.graphics.drawCircle(1 + 2.5, 2.5, 2.5);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawRect(2, 0, 3, 1);
		icon.graphics.drawRect(2, 4, 3, 1);
		icon.graphics.drawRect(1, 1, 1, 3);
		icon.graphics.drawRect(5, 1, 1, 3);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function tween_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(0, 0);
		icon.graphics.drawRect(0, 0, 8, 6);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawRect(0, 0, 8, 1);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function tween_empty_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(0, 0);
		icon.graphics.drawRect(0, 0, 5, 6);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawRect(2, 0, 3, 1);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function end_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(0, 0);
		icon.graphics.drawRect(0, 0, 6, 11);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawRect(1, 0, 5, 1);
		icon.graphics.drawRect(1, 8, 5, 1);
		icon.graphics.drawRect(1, 1, 1, 7);
		icon.graphics.drawRect(5, 1, 1, 7);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function end_empty_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(0, 0);
		icon.graphics.drawRect(0, 0, 6, 11);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawRect(1, 0, 5, 1);
		icon.graphics.drawRect(1, 8, 5, 1);
		icon.graphics.drawRect(1, 1, 1, 7);
		icon.graphics.drawRect(5, 1, 1, 7);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function end_tween_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(0, 0);
		icon.graphics.drawRect(0, 0, 5, 8);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawRect(0, 2, 5, 1);
		icon.graphics.drawRect(2, 0, 1, 1);
		icon.graphics.drawRect(3, 1, 1, 1);
		icon.graphics.drawRect(3, 3, 1, 1);
		icon.graphics.drawRect(2, 4, 1, 1);
		icon.graphics.endFill();
		return icon;
	}
	
	static private function end_tween_empty_icon():Shape
	{
		var icon:Shape = new Shape();
		icon.graphics.beginFill(0, 0);
		icon.graphics.drawRect(0, 0, 5, 6);
		icon.graphics.beginFill(theme.contrastColor, 1);
		icon.graphics.drawRect(2, 0, 3, 1);
		icon.graphics.endFill();
		return icon;
	}
	
}