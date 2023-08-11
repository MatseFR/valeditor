package valeditor.ui.feathers.controls.item;

import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.ScrollPolicy;
import feathers.data.ListViewItemState;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalListLayout;
import feathers.layout.VerticalLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import valedit.ValEditKeyFrame;
import valeditor.ValEditorTimeLine;
import valeditor.ui.feathers.renderers.FrameItemRenderer;
import valeditor.ui.feathers.renderers.FrameItemState;

/**
 * ...
 * @author Matse
 */
class TimeLineItem extends LayoutGroup 
{
	static private var _POOL:Array<TimeLineItem> = new Array<TimeLineItem>();
	
	static public function fromPool(timeLine:ValEditorTimeLine = null):TimeLineItem
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(timeLine);
		return new TimeLineItem(timeLine);
	}
	
	public var timeLine(get, set):ValEditorTimeLine;
	
	private var _timeLine:ValEditorTimeLine;
	private function get_timeLine():ValEditorTimeLine { return this._timeLine; }
	private function set_timeLine(value:ValEditorTimeLine):ValEditorTimeLine
	{
		if (this._timeLine == value) return value;
		if (value != null)
		{
			this._list.dataProvider = value.frameCollection;
		}
		else
		{
			this._list.dataProvider = null;
		}
		return this._timeLine = value;
	}
	
	private var _list:ListView;
	
	private var _frame:ValEditKeyFrame;

	public function new(timeLine:ValEditorTimeLine) 
	{
		super();
		initializeNow();
		this.timeLine = timeLine;
	}
	
	public function clear():Void
	{
		this.timeLine = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		this.layout = vLayout;
		
		this._list = new ListView();
		this._list.variant = ListView.VARIANT_BORDERLESS;
		var listLayout:HorizontalListLayout = new HorizontalListLayout();
		this._list.layout = listLayout;
		this._list.scrollPolicyX = ScrollPolicy.OFF;
		this._list.scrollPolicyY = ScrollPolicy.OFF;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return FrameItemRenderer.fromPool();
		});
		recycler.update = itemUpdate;
		recycler.destroy = itemDestroy;
		this._list.itemRendererRecycler = recycler;
		
		this._list.addEventListener(Event.CHANGE, onListChange);
		addChild(this._list);
		
		this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	
	public function timeLineUpdate(state:ListViewItemState):Void
	{
		if (!state.selected)
		{
			this._list.selectedIndex = -1;
		}
		this.timeLine = state.data.timeLine;
	}
	
	private function itemDestroy(itemRenderer:FrameItemRenderer):Void
	{
		itemRenderer.pool();
	}
	
	private function itemUpdate(itemRenderer:FrameItemRenderer, state:ListViewItemState):Void
	{
		this._frame = state.data.frame;
		if (this._frame != null)
		{
			if (this._frame.indexStart == this._frame.indexEnd)
			{
				// KEYFRAME_SINGLE
				if (this._frame.isEmpty)
				{
					if (this._frame.tween)
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
					if (this._frame.tween)
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
				if (this._frame.indexStart == state.index)
				{
					// KEYFRAME_START
					if (this._frame.isEmpty)
					{
						if (this._frame.tween)
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
						if (this._frame.tween)
						{
							itemRenderer.state = FrameItemState.KEYFRAME_START_TWEEN(state.selected);
						}
						else
						{
							itemRenderer.state = FrameItemState.KEYFRAME_START(state.selected);
						}
					}
				}
				else if (this._frame.indexEnd == state.index)
				{
					// KEYFRAME_END
					if (this._frame.isEmpty)
					{
						if (this._frame.tween)
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
						if (this._frame.tween)
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
					if (this._frame.isEmpty)
					{
						if (this._frame.tween)
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
						if (this._frame.tween)
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
	
	private function setTo(timeLine:ValEditorTimeLine):TimeLineItem
	{
		this.timeLine = timeLine;
		return this;
	}
	
	private function onKeyDown(evt:KeyboardEvent):Void
	{
		switch (evt.keyCode)
		{
			case Keyboard.F5 :
				if (evt.shiftKey)
				{
					this._timeLine.removeFrame();
				}
				else
				{
					this._timeLine.insertFrame();
				}
			
			case Keyboard.F6 :
				if (evt.shiftKey)
				{
					this._timeLine.removeKeyFrame();
				}
				else
				{
					this._timeLine.insertKeyFrame();
				}
		}
		
		evt.stopPropagation();
	}
	
	private function onListChange(evt:Event):Void
	{
		if (this._list.selectedIndex != -1)
		{
			this.timeLine.parent.frameIndex = this._list.selectedIndex;
			if (this._list.selectedItem.frame != null)
			{
				ValEditor.selection.object = this._list.selectedItem.frame;
			}
		}
	}
	
}