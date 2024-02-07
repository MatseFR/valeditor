package valeditor.ui.feathers.controls.item;

import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.events.ListViewEvent;
import feathers.events.ScrollEvent;
import feathers.layout.HorizontalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import valedit.ValEditKeyFrame;
import valeditor.ValEditorLayer;
import valeditor.ValEditorTimeLine;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.container.ContainerSetCurrentLayer;
import valeditor.editor.action.selection.SelectionSetObject;
import valeditor.editor.action.timeline.TimeLineSetFrameIndex;
import valeditor.editor.action.timeline.TimeLineSetSelectedFrameIndex;
import valeditor.events.DefaultEvent;
import valeditor.events.TimeLineEvent;
import valeditor.ui.feathers.data.FrameData;
import valeditor.ui.feathers.variant.ListViewVariant;

/**
 * ...
 * @author Matse
 */
class TimeLineItem extends LayoutGroup 
{
	static private var _POOL:Array<TimeLineItem> = new Array<TimeLineItem>();
	
	static public function fromPool(layer:ValEditorLayer = null):TimeLineItem
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(layer);
		return new TimeLineItem(layer);
	}
	
	public var isCurrent(get, set):Bool;
	public var layer(get, set):ValEditorLayer;
	public var maxScrollX(get, never):Float;
	public var minScrollX(get, never):Float;
	public var scrollX(get, set):Float;
	public var selectedIndex(get, set):Int;
	public var timeLine(get, never):ValEditorTimeLine;
	
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
	
	private var _layer:ValEditorLayer;
	private function get_layer():ValEditorLayer { return this._layer; }
	private function set_layer(value:ValEditorLayer):ValEditorLayer
	{
		if (this._layer == value) return value;
		
		if (value != null)
		{
			this._timeLine = cast value.timeLine;
			this._timeLine.addEventListener(TimeLineEvent.SELECTED_FRAME_INDEX_CHANGE, onTimeLineSelectedFrameIndexChange);
			this._list.dataProvider = this._timeLine.frameCollection;
			this._list.validateNow();
		}
		else
		{
			if (this._timeLine != null)
			{
				this._timeLine.removeEventListener(TimeLineEvent.SELECTED_FRAME_INDEX_CHANGE, onTimeLineSelectedFrameIndexChange);
			}
			this._timeLine = null;
			this._list.dataProvider = null;
		}
		return this._layer = value;
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
	//private function set_timeLine(value:ValEditorTimeLine):ValEditorTimeLine
	//{
		//if (this._timeLine == value) return value;
		//
		//if (value != null)
		//{
			//this._list.dataProvider = value.frameCollection;
			//this._list.validateNow();
		//}
		//else
		//{
			//this._list.dataProvider = null;
		//}
		//return this._timeLine = value;
	//}
	
	private var _dispatchScrollEvents:Bool = true;
	private var _list:ListView;
	private var _frame:ValEditKeyFrame;

	public function new(layer:ValEditorLayer) 
	{
		super();
		initializeNow();
		this.layer = layer;
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
		this.layer = null;
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
		this._list.variant = ListViewVariant.TIMELINE;
		//this._list.addEventListener(Event.CHANGE, onListChange);
		this._list.addEventListener(ListViewEvent.ITEM_TRIGGER, onListItemTrigger);
		this._list.addEventListener(ScrollEvent.SCROLL, onListScroll);
		addChild(this._list);
		
		//addEventListener(MouseEvent.CLICK, onMouseClick);
	}
	
	public function clearSelection():Void
	{
		this._list.selectedIndex = -1;
	}
	
	public function setSelectedFrame(frameData:FrameData):Void
	{
		this._list.selectedItem = frameData;
	}
	
	private function setTo(layer:ValEditorLayer):TimeLineItem
	{
		this.layer = layer;
		return this;
	}
	
	//private function onListChange(evt:Event):Void
	//{
		//handleListSelection();
	//}
	
	private function onListItemTrigger(evt:ListViewEvent):Void
	{
		var action:MultiAction = MultiAction.fromPool();
		
		if (this.layer.container.currentLayer != this.layer)
		{
			var setCurrentLayer:ContainerSetCurrentLayer = ContainerSetCurrentLayer.fromPool();
			setCurrentLayer.setup(cast this.layer.container, this.layer);
			action.add(setCurrentLayer);
		}
		
		if (this._timeLine.selectedFrameIndex != evt.state.index)
		{
			var setSelectedFrameIndex:TimeLineSetSelectedFrameIndex = TimeLineSetSelectedFrameIndex.fromPool();
			setSelectedFrameIndex.setup(this._timeLine, evt.state.index);
			action.add(setSelectedFrameIndex);
		}
		
		if (this._timeLine.parent.frameIndex != evt.state.index)
		{
			var setFrameIndex:TimeLineSetFrameIndex = TimeLineSetFrameIndex.fromPool();
			setFrameIndex.setup(cast this._timeLine.parent, evt.state.index);
			action.add(setFrameIndex);
		}
		
		if (ValEditor.selection.object != evt.state.data.frame)
		{
			var selectionSetObject:SelectionSetObject = SelectionSetObject.fromPool();
			selectionSetObject.setup(evt.state.data.frame);
			action.add(selectionSetObject);
		}
		
		if (action.numActions != 0)
		{
			ValEditor.actionStack.add(action);
		}
		else
		{
			action.pool();
		}
	}
	
	private function onListScroll(evt:ScrollEvent):Void
	{
		if (this._dispatchScrollEvents)
		{
			DefaultEvent.dispatch(this, Event.SCROLL);
		}
	}
	
	//private function onMouseClick(evt:MouseEvent):Void
	//{
		//handleListSelection();
	//}
	
	private function onTimeLineSelectedFrameIndexChange(evt:TimeLineEvent):Void
	{
		this._list.selectedIndex = this._timeLine.selectedFrameIndex;
	}
	
	//private function handleListSelection():Void
	//{
		//if (this._list.selectedIndex != -1)
		//{
			//this._timeLine.parent.frameIndex = this._list.selectedIndex;
			//if (this.stage.focus == this._list)
			//{
				//if (this._list.selectedItem.frame != null)
				//{
					//ValEditor.selection.object = this._list.selectedItem.frame;
				//}
				//else
				//{
					//ValEditor.selection.object = null;
				//}
			//}
			//
			//if (!this._isCurrent)
			//{
				//this._isCurrent = true;
				//DefaultEvent.dispatch(this, Event.SELECT);
			//}
		//}
	//}
	
}