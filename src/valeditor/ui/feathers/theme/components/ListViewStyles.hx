package valeditor.ui.feathers.theme.components;
import feathers.controls.ListView;
import feathers.controls.ScrollPolicy;
import feathers.data.ListViewItemState;
import feathers.layout.HorizontalListLayout;
import feathers.skins.RectangleSkin;
import feathers.style.ClassVariantStyleProvider;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.display.Shape;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import valedit.ValEditKeyFrame;
import valeditor.ui.feathers.renderers.BitmapScrollRenderer;
import valeditor.ui.feathers.renderers.FrameItemState;
import valeditor.ui.feathers.theme.ValEditorTheme;
import valeditor.ui.feathers.theme.simple.SimpleTheme;
import valeditor.ui.feathers.variant.ListViewVariant;

/**
 * ...
 * @author Matse
 */
class ListViewStyles 
{
	static public var BMD:BitmapData;
	static private var rectMap:Map<FrameItemState, Rectangle> = new Map<FrameItemState, Rectangle>();
	static private var itemWidth:Int = 8;
	static private var itemHeight:Int = 18;
	static private var theme:ValEditorTheme;
	
	static public function initialize(theme:ValEditorTheme, styleProvider:ClassVariantStyleProvider):Void
	{
		ListViewStyles.theme = theme;
		theme.registerForColorUpdate(colorUpdate);
		
		colorUpdate(theme);
		
		if (styleProvider.getStyleFunction(ListView, ListViewVariant.TIMELINE) == null)
		{
			styleProvider.setStyleFunction(ListView, ListViewVariant.TIMELINE, timeLine);
		}
	}
	
	static private function colorUpdate(theme:SimpleTheme):Void
	{
		var matrix:Matrix = new Matrix();
		var rect:Rectangle = new Rectangle(0, 0, itemWidth, itemHeight);
		var spacing:Int = 1;
		if (BMD == null)
		{
			BMD = new BitmapData(itemWidth * 36 + 35, itemHeight);
		}
		var shape:Shape = new Shape();
		var graphics:Graphics = shape.graphics;
		
		// FRAME
		drawCell(graphics, theme.lightColor, theme.contrastColorLighter);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.FRAME(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// FRAME selected
		drawCell(graphics, theme.focusColor, theme.contrastColorLighter);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.FRAME(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// FRAME_5
		drawCell(graphics, theme.lightColorDark, theme.contrastColorLighter);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.FRAME_5(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// FRAME_5 selected
		drawCell(graphics, theme.focusColor, theme.contrastColorLighter);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.FRAME_5(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_SINGLE
		drawCell(graphics, theme.lightColorDarker, theme.contrastColor);
		drawIcon_start(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_SINGLE(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_SINGLE selected
		drawCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_start(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_SINGLE(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_SINGLE_EMPTY
		drawCell(graphics, theme.lightColor, theme.contrastColor);
		drawIcon_startEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_SINGLE_EMPTY(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_SINGLE_EMPTY selected
		drawCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_startEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_SINGLE_EMPTY(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_SINGLE_TWEEN
		drawCell(graphics, theme.themeColor, theme.contrastColor);
		drawIcon_startTween(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_SINGLE_TWEEN(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_SINGLE_TWEEN selected
		drawCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_startTween(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_SINGLE_TWEEN(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_SINGLE_TWEEN_EMPTY
		drawCell(graphics, theme.lightColor, theme.contrastColor);
		drawIcon_startTweenEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_SINGLE_TWEEN_EMPTY(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_SINGLE_TWEEN_EMPTY selected
		drawCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_startTweenEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_SINGLE_TWEEN_EMPTY(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_START
		drawFreeCell(graphics, theme.lightColorDarker, theme.contrastColor);
		drawIcon_start(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_START(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_START selected
		drawFreeCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_start(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_START(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_START_EMPTY
		drawFreeCell(graphics, theme.lightColor, theme.contrastColor);
		drawIcon_startEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_START_EMPTY(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_START_EMPTY selected
		drawFreeCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_startEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_START_EMPTY(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_START_TWEEN
		drawFreeCell(graphics, theme.themeColor, theme.contrastColor);
		drawIcon_startTween(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_START_TWEEN(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_START_TWEEN selected
		drawFreeCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_startTween(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_START_TWEEN(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_START_TWEEN_EMPTY
		drawFreeCell(graphics, theme.lightColor, theme.contrastColor);
		drawIcon_startTweenEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_START_TWEEN_EMPTY(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_START_TWEEN_EMPTY selected
		drawFreeCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_startTweenEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_START_TWEEN_EMPTY(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME
		drawFreeCell(graphics, theme.lightColorDarker, theme.contrastColor);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME selected
		drawFreeCell(graphics, theme.focusColor, theme.contrastColor);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_EMPTY
		drawFreeCell(graphics, theme.lightColor, theme.contrastColor);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_EMPTY(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_EMPTY selected
		drawFreeCell(graphics, theme.focusColor, theme.contrastColor);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_EMPTY(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_TWEEN
		drawFreeCell(graphics, theme.themeColor, theme.contrastColor);
		drawIcon_tween(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_TWEEN(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_TWEEN selected
		drawFreeCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_tween(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_TWEEN(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_TWEEN_EMPTY
		drawFreeCell(graphics, theme.lightColor, theme.contrastColor);
		drawIcon_tweenEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_TWEEN_EMPTY(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_TWEEN_EMPTY selected
		drawFreeCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_tweenEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_TWEEN_EMPTY(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_END
		drawCell(graphics, theme.lightColorDarker, theme.contrastColor);
		drawIcon_end(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_END(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_END selected
		drawCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_end(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_END(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_END_EMPTY
		drawCell(graphics, theme.lightColor, theme.contrastColor);
		drawIcon_endEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_END_EMPTY(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_END_EMPTY selected
		drawCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_endEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_END_EMPTY(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_END_TWEEN
		drawCell(graphics, theme.themeColor, theme.contrastColor);
		drawIcon_endTween(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_END_TWEEN(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_END_TWEEN selected
		drawCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_endTween(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_END_TWEEN(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_END_TWEEN_EMPTY
		drawCell(graphics, theme.lightColor, theme.contrastColor);
		drawIcon_endTweenEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_END_TWEEN_EMPTY(false), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
		
		// KEYFRAME_END_TWEEN_EMPTY selected
		drawCell(graphics, theme.focusColor, theme.contrastColor);
		drawIcon_endTweenEmpty(graphics);
		BMD.draw(shape, matrix, null, null, null, true);
		rectMap.set(FrameItemState.KEYFRAME_END_TWEEN_EMPTY(true), rect.clone());
		graphics.clear();
		matrix.translate(itemWidth + spacing, 0);
		rect.x += itemWidth + spacing;
	}
	
	static private function drawCell(graphics:Graphics, fillColor:Int, lineColor:Int):Void
	{
		graphics.beginFill(fillColor);
		graphics.drawRect(0, 0, itemWidth, itemHeight);
		graphics.endFill();
		
		graphics.lineStyle(1, lineColor);
		graphics.moveTo(0, 0);
		graphics.lineTo(itemWidth - 1, 0);
		graphics.lineTo(itemWidth - 1, itemHeight - 1);
		graphics.lineTo(0, itemHeight - 1);
		graphics.lineStyle();
	}
	
	static private function drawFreeCell(graphics:Graphics, fillColor:Int, lineColor:Int):Void
	{
		graphics.beginFill(fillColor);
		graphics.drawRect(0, 0, itemWidth, itemHeight);
		graphics.endFill();
		
		graphics.lineStyle(1, lineColor);
		graphics.moveTo(0, 0);
		graphics.lineTo(itemWidth, 0);
		graphics.moveTo(0, itemHeight - 1);
		graphics.lineTo(itemWidth, itemHeight - 1);
		
		graphics.lineStyle(1, theme.contrastColorLighter);
		graphics.moveTo(itemWidth - 1, 0);
		graphics.lineTo(itemWidth - 1, 2);
		graphics.moveTo(itemWidth - 1, itemHeight);
		graphics.lineTo(itemWidth - 1, itemHeight - 2);
		graphics.lineStyle();
	}
	
	static private function drawIcon_start(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawCircle(1 + 2.5, 12.5, 2.5);
		graphics.endFill();
	}
	
	static private function drawIcon_startEmpty(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawRect(2, 10, 3, 1);
		graphics.drawRect(2, 14, 3, 1);
		graphics.drawRect(1, 11, 1, 3);
		graphics.drawRect(5, 11, 1, 3);
		graphics.endFill();
	}
	
	static private function drawIcon_startTween(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawCircle(1 + 2.5, 12.5, 2.5);
		graphics.drawRect(6, 12, 2, 1);
		graphics.endFill();
	}
	
	static private function drawIcon_startTweenEmpty(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawRect(2, 10, 3, 1);
		graphics.drawRect(2, 14, 3, 1);
		graphics.drawRect(1, 11, 1, 3);
		graphics.drawRect(5, 11, 1, 3);
		graphics.endFill();
	}
	
	static private function drawIcon_tween(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawRect(0, 12, 8, 1);
		graphics.endFill();
	}
	
	static private function drawIcon_tweenEmpty(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawRect(2, 12, 3, 1);
		graphics.endFill();
	}
	
	static private function drawIcon_end(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawRect(1, 7, 5, 1);
		graphics.drawRect(1, 15, 5, 1);
		graphics.drawRect(1, 8, 1, 7);
		graphics.drawRect(5, 8, 1, 7);
		graphics.endFill();
	}
	
	static private function drawIcon_endEmpty(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawRect(1, 7, 5, 1);
		graphics.drawRect(1, 15, 5, 1);
		graphics.drawRect(1, 8, 1, 7);
		graphics.drawRect(5, 8, 1, 7);
		graphics.endFill();
	}
	
	static private function drawIcon_endTween(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawRect(0, 12, 5, 1);
		graphics.drawRect(2, 10, 1, 1);
		graphics.drawRect(3, 11, 1, 1);
		graphics.drawRect(3, 13, 1, 1);
		graphics.drawRect(2, 14, 1, 1);
		graphics.endFill();
	}
	
	static private function drawIcon_endTweenEmpty(graphics:Graphics):Void
	{
		graphics.beginFill(theme.contrastColor, 1);
		graphics.drawRect(2, 12, 3, 1);
		graphics.endFill();
	}
	
	static private function timeLine(list:ListView):Void
	{
		list.scrollPolicyX = ScrollPolicy.OFF;
		list.scrollPolicyY = ScrollPolicy.OFF;
		list.layout = new HorizontalListLayout();
		
		if (list.backgroundSkin == null) {
			var backgroundSkin = new RectangleSkin();
			backgroundSkin.fill = theme.getLightFill();
			backgroundSkin.width = 10.0;
			backgroundSkin.height = 10.0;
			list.backgroundSkin = backgroundSkin;
		}
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return BitmapScrollRenderer.fromPool(BMD, rectMap);
		});
		recycler.update = itemUpdate;
		recycler.destroy = itemDestroy;
		list.itemRendererRecycler = recycler;
	}
	
	static private function itemDestroy(itemRenderer:BitmapScrollRenderer):Void
	{
		itemRenderer.pool();
	}
	
	static private var _frame:ValEditKeyFrame;
	static private function itemUpdate(itemRenderer:BitmapScrollRenderer, state:ListViewItemState):Void
	{
		_frame = state.data.frame;
		if (_frame != null)
		{
			if (_frame.indexStart == _frame.indexEnd)
			{
				// KEYFRAME_SINGLE
				if (_frame.isEmpty)
				{
					if (_frame.tween)
					{
						itemRenderer.state = FrameItemState.KEYFRAME_SINGLE_TWEEN_EMPTY(state.selected);
					}
					else
					{
						itemRenderer.state = FrameItemState.KEYFRAME_SINGLE_EMPTY(state.selected);
					}
				}
				else
				{
					if (_frame.tween)
					{
						itemRenderer.state = FrameItemState.KEYFRAME_SINGLE_TWEEN(state.selected);
					}
					else
					{
						itemRenderer.state = FrameItemState.KEYFRAME_SINGLE(state.selected);
					}
				}
			}
			else
			{
				if (_frame.indexStart == state.index)
				{
					// KEYFRAME_START
					if (_frame.isEmpty)
					{
						if (_frame.tween)
						{
							itemRenderer.state = FrameItemState.KEYFRAME_START_TWEEN_EMPTY(state.selected);
						}
						else
						{
							itemRenderer.state = FrameItemState.KEYFRAME_START_EMPTY(state.selected);
						}
					}
					else
					{
						if (_frame.tween)
						{
							itemRenderer.state = FrameItemState.KEYFRAME_START_TWEEN(state.selected);
						}
						else
						{
							itemRenderer.state = FrameItemState.KEYFRAME_START(state.selected);
						}
					}
				}
				else if (_frame.indexEnd == state.index)
				{
					// KEYFRAME_END
					if (_frame.isEmpty)
					{
						if (_frame.tween)
						{
							itemRenderer.state = FrameItemState.KEYFRAME_END_TWEEN_EMPTY(state.selected);
						}
						else
						{
							itemRenderer.state = FrameItemState.KEYFRAME_END_EMPTY(state.selected);
						}
					}
					else
					{
						if (_frame.tween)
						{
							itemRenderer.state = FrameItemState.KEYFRAME_END_TWEEN(state.selected);
						}
						else
						{
							itemRenderer.state = FrameItemState.KEYFRAME_END(state.selected);
						}
					}
				}
				else
				{
					// KEYFRAME
					if (_frame.isEmpty)
					{
						if (_frame.tween)
						{
							itemRenderer.state = FrameItemState.KEYFRAME_TWEEN_EMPTY(state.selected);
						}
						else
						{
							itemRenderer.state = FrameItemState.KEYFRAME_EMPTY(state.selected);
						}
					}
					else
					{
						if (_frame.tween)
						{
							itemRenderer.state = FrameItemState.KEYFRAME_TWEEN(state.selected);
						}
						else
						{
							itemRenderer.state = FrameItemState.KEYFRAME(state.selected);
						}
					}
				}
			}
			_frame = null;
		}
		else
		{
			if ((state.index + 1) % 5 == 0)
			{
				itemRenderer.state = FrameItemState.FRAME_5(state.selected);
			}
			else
			{
				itemRenderer.state = FrameItemState.FRAME(state.selected);
			}
		}
	}
	
}