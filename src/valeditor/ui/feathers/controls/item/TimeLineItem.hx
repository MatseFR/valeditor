package valeditor.ui.feathers.controls.item;

import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.ScrollPolicy;
import feathers.data.ListViewItemState;
import feathers.events.ScrollEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalListLayout;
import feathers.layout.VerticalLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import valedit.ValEditKeyFrame;
import valeditor.ValEditorTimeLine;
import valeditor.events.DefaultEvent;
import valeditor.events.TimeLineEvent;
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
	
	public var isCurrent(get, set):Bool;
	public var maxScrollX(get, never):Float;
	public var minScrollX(get, never):Float;
	public var scrollX(get, set):Float;
	public var selectedIndex(get, set):Int;
	public var timeLine(get, set):ValEditorTimeLine;
	
	private var _isCurrent:Bool;
	private function get_isCurrent():Bool { return this._isCurrent; }
	private function set_isCurrent(value:Bool):Bool
	{
		if (!value)
		{
			this._list.selectedIndex = -1;
		}
		return this._isCurrent = value;
	}
	
	private function get_maxScrollX():Float { return this._list.maxScrollX; }
	
	private function get_minScrollX():Float { return this._list.minScrollX; }
	
	private function get_scrollX():Float { return this._list.scrollX; }
	private function set_scrollX(value:Float):Float
	{
		this._dispatchScrollEvents = false;
		this._list.scrollX = value;
		this._dispatchScrollEvents = true;
		return value;
	}
	
	private function get_selectedIndex():Int { return this._list.selectedIndex; }
	private function set_selectedIndex(value:Int):Int
	{
		return this._list.selectedIndex = value;
	}
	
	private var _timeLine:ValEditorTimeLine;
	private function get_timeLine():ValEditorTimeLine { return this._timeLine; }
	private function set_timeLine(value:ValEditorTimeLine):ValEditorTimeLine
	{
		if (this._timeLine == value) return value;
		
		if (this._timeLine != null)
		{
			this._timeLine.removeEventListener(TimeLineEvent.FRAME_INDEX_CHANGE, onTimeLineFrameIndexChange);
		}
		
		if (value != null)
		{
			value.addEventListener(TimeLineEvent.FRAME_INDEX_CHANGE, onTimeLineFrameIndexChange);
			this._list.dataProvider = value.frameCollection;
			this._list.validateNow();
		}
		else
		{
			this._list.dataProvider = null;
		}
		return this._timeLine = value;
	}
	
	private var _dispatchScrollEvents:Bool = true;
	private var _list:ListView;
	private var _frame:ValEditKeyFrame;
	
	private var _emptyString:String = null;

	public function new(timeLine:ValEditorTimeLine) 
	{
		super();
		initializeNow();
		this.timeLine = timeLine;
	}
	
	public function clear():Void
	{
		if (this._isCurrent)
		{
			if (this._list.selectedItem != null && this._list.selectedItem.frame != null)
			{
				ValEditor.selection.removeFrame(this._list.selectedItem.frame);
			}
			this._isCurrent = false;
		}
		this._dispatchScrollEvents = true;
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
		this._list.itemToText = itemToText;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return FrameItemRenderer.fromPool();
		});
		recycler.update = itemUpdate;
		recycler.destroy = itemDestroy;
		this._list.itemRendererRecycler = recycler;
		
		this._list.addEventListener(Event.CHANGE, onListChange);
		this._list.addEventListener(ScrollEvent.SCROLL, onListScroll);
		addChild(this._list);
		
		this.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
	}
	
	private function itemToText(data:Dynamic):String
	{
		return this._emptyString;
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
			this._frame = null;
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
				ValEditor.selection.object = this._timeLine.frameCurrent;
			
			case Keyboard.F6 :
				if (evt.shiftKey)
				{
					this._timeLine.removeKeyFrame();
				}
				else
				{
					this._timeLine.insertKeyFrame();
				}
				ValEditor.selection.object = this._timeLine.frameCurrent;
		}
		
		evt.stopPropagation();
	}
	
	private function onListChange(evt:Event):Void
	{
		if (this._list.selectedIndex != -1)
		{
			this._timeLine.parent.frameIndex = this._list.selectedIndex;
			if (this._list.selectedItem.frame != null)
			{
				ValEditor.selection.object = this._list.selectedItem.frame;
			}
			
			if (!this._isCurrent)
			{
				this._isCurrent = true;
				DefaultEvent.dispatch(this, Event.SELECT);
			}
		}
	}
	
	private function onListScroll(evt:ScrollEvent):Void
	{
		if (this._dispatchScrollEvents)
		{
			DefaultEvent.dispatch(this, Event.SCROLL);
		}
	}
	
	private function onTimeLineFrameIndexChange(evt:TimeLineEvent):Void
	{
		if (this._isCurrent)
		{
			this._list.selectedIndex = this._timeLine.frameIndex;
		}
	}
	
}