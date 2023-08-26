package valeditor.ui.feathers.view;

import feathers.controls.Button;
import feathers.controls.HDividedBox;
import feathers.controls.HScrollBar;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.ToggleButton;
import feathers.controls.ToggleButtonState;
import feathers.controls.VScrollBar;
import feathers.data.ListViewItemState;
import feathers.events.ScrollEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.events.Event;
import valedit.ValEditLayer;
import valedit.events.PlayEvent;
import valeditor.ValEditor;
import valeditor.ValEditorContainer;
import valeditor.ValEditorLayer;
import valeditor.ValEditorTimeLine;
import valeditor.events.ContainerEvent;
import valeditor.events.EditorEvent;
import valeditor.ui.feathers.controls.item.LayerItem;
import valeditor.ui.feathers.controls.item.TimeLineItem;

/**
 * ...
 * @author Matse
 */
class ScenarioView extends LayoutGroup 
{
	private var _mainBox:HDividedBox;
	
	private var _layerGroup:LayoutGroup;
	private var _layerTopGroup:LayoutGroup;
	private var _layerList:ListView;
	private var _layerBottomGroup:LayoutGroup;
	
	private var _layerAddButton:Button;
	private var _layerRemoveButton:Button;
	
	private var _timeLineMainGroup:LayoutGroup;
	private var _timeLineTopGroup:LayoutGroup;
	private var _timeLineGroup:LayoutGroup;
	private var _timeLineList:ScrollContainer;
	private var _timeLineBottomGroup:LayoutGroup;
	private var _timeLineControlsGroup:LayoutGroup;
	
	private var _playStopButton:ToggleButton;
	
	private var _timeLineItems:Array<TimeLineItem> = new Array<TimeLineItem>();
	
	private var _hScrollBar:HScrollBar;
	private var _vScrollBar:VScrollBar;
	
	private var _container:ValEditorContainer;
	private var _currentTimeLineItem:TimeLineItem;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		var startWidth:Float;
		
		this.layout = new AnchorLayout();
		
		this._mainBox = new HDividedBox();
		this._mainBox.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		addChild(this._mainBox);
		
		// LAYERS
		this._layerGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._layerGroup.layout = vLayout;
		startWidth = Lib.current.stage.stageWidth / 6;
		this._layerGroup.width = startWidth >= this._layerGroup.minWidth ? startWidth : this._layerGroup.minWidth;
		this._mainBox.addChild(this._layerGroup);
		
		this._layerTopGroup = new LayoutGroup();
		this._layerTopGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		this._layerTopGroup.layout = hLayout;
		this._layerGroup.addChild(this._layerTopGroup);
		
		this._layerList = new ListView();
		this._layerList.variant = ListView.VARIANT_BORDERLESS;
		var layerRecycler = DisplayObjectRecycler.withFunction(() -> {
			return LayerItem.fromPool();
		});
		layerRecycler.destroy = layerItemDestroy;
		layerRecycler.reset = layerItemReset;
		layerRecycler.update = layerItemUpdate;
		this._layerList.itemRendererRecycler = layerRecycler;
		this._layerList.layoutData = new VerticalLayoutData(null, 100);
		this._layerList.scrollPolicyX = ScrollPolicy.OFF;
		this._layerList.scrollPolicyY = ScrollPolicy.OFF;
		this._layerList.addEventListener(ScrollEvent.SCROLL, onLayerListScroll);
		this._layerGroup.addChild(this._layerList);
		
		this._layerBottomGroup = new LayoutGroup();
		this._layerBottomGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		//hLayout.setPadding(Padding.DEFAULT);
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._layerBottomGroup.layout = hLayout;
		this._layerGroup.addChild(this._layerBottomGroup);
		
		this._layerAddButton = new Button("+", onLayerAddButton);
		this._layerBottomGroup.addChild(this._layerAddButton);
		
		this._layerRemoveButton = new Button("-", onLayerRemoveButton);
		this._layerBottomGroup.addChild(this._layerRemoveButton);
		
		// TIMELINES
		this._timeLineMainGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._timeLineMainGroup.layout = vLayout;
		this._mainBox.addChild(this._timeLineMainGroup);
		
		this._timeLineTopGroup = new LayoutGroup();
		this._timeLineTopGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		this._timeLineTopGroup.layout = hLayout;
		this._timeLineMainGroup.addChild(this._timeLineTopGroup);
		
		this._timeLineGroup = new LayoutGroup();
		this._timeLineGroup.layoutData = new VerticalLayoutData(null, 100);
		this._timeLineGroup.layout = new AnchorLayout();
		this._timeLineMainGroup.addChild(this._timeLineGroup);
		
		this._vScrollBar = new VScrollBar();
		this._vScrollBar.snapInterval = 1.0;
		this._vScrollBar.layoutData = new AnchorLayoutData(0, 0, 0);
		this._vScrollBar.addEventListener(Event.CHANGE, onVScrollBarChange);
		this._timeLineGroup.addChild(this._vScrollBar);
		
		this._timeLineList = new ScrollContainer();
		this._timeLineList.layoutData = new AnchorLayoutData(0, new Anchor(0, this._vScrollBar), 0, 0);
		this._timeLineList.scrollPolicyX = ScrollPolicy.OFF;
		this._timeLineList.scrollPolicyY = ScrollPolicy.OFF;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._timeLineList.layout = vLayout;
		this._timeLineList.addEventListener(ScrollEvent.SCROLL, onTimeLineListScroll);
		this._timeLineGroup.addChild(this._timeLineList);
		
		this._timeLineBottomGroup = new LayoutGroup();
		this._timeLineBottomGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		this._timeLineBottomGroup.layout = new AnchorLayout();
		this._timeLineMainGroup.addChild(this._timeLineBottomGroup);
		
		this._hScrollBar = new HScrollBar();
		this._hScrollBar.snapInterval = 1.0;
		//this._hScrollBar.layoutData = new AnchorLayoutData(0, 0, null, 0);
		this._hScrollBar.addEventListener(Event.CHANGE, onHScrollBarChange);
		this._timeLineBottomGroup.addChild(this._hScrollBar);
		
		this._timeLineControlsGroup = new LayoutGroup();
		this._timeLineControlsGroup.layoutData = new AnchorLayoutData(new Anchor(0, this._hScrollBar), 0, null, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		//hLayout.setPadding(Padding.DEFAULT);
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._timeLineControlsGroup.layout = hLayout;
		this._timeLineBottomGroup.addChild(this._timeLineControlsGroup);
		
		this._playStopButton = new ToggleButton("P", false, onPlayStopButton);
		this._timeLineControlsGroup.addChild(this._playStopButton);
		
		this._timeLineList.addEventListener(Event.RESIZE, onTimeLineResize);
		
		ValEditor.addEventListener(EditorEvent.CONTAINER_CLOSE, onContainerClose);
		ValEditor.addEventListener(EditorEvent.CONTAINER_OPEN, onContainerOpen);
		
		listsChangeEnable();
	}
	
	private function onTimeLineResize(evt:Event):Void
	{
		updateHScrollBar();
		this._hScrollBar.width = this._timeLineList.width;
		this._hScrollBar.page = this._timeLineList.width;
		
		updateVScrollBar();
		this._vScrollBar.page = this._timeLineList.height;
	}
	
	private function layerItemDestroy(itemRenderer:LayerItem):Void
	{
		itemRenderer.pool();
	}
	
	private function layerItemReset(itemRenderer:LayerItem, state:ListViewItemState):Void
	{
		
	}
	
	private function layerItemUpdate(itemRenderer:LayerItem, state:ListViewItemState):Void
	{
		itemRenderer.layer = state.data;
	}
	
	private function listsChangeDisable():Void
	{
		this._layerList.removeEventListener(Event.CHANGE, onLayerListChange);
	}
	
	private function listsChangeEnable():Void
	{
		this._layerList.addEventListener(Event.CHANGE, onLayerListChange);
	}
	
	private function updateHScrollBar():Void
	{
		var item:TimeLineItem = null;
		if (this._timeLineItems.length != 0)
		{
			item = this._timeLineItems[0];
		}
		
		if (item != null)
		{
			this._hScrollBar.minimum = item.minScrollX;
			this._hScrollBar.maximum = item.maxScrollX;
		}
	}
	
	private function updateVScrollBar():Void
	{
		this._vScrollBar.minimum = this._timeLineList.minScrollY;
		this._vScrollBar.maximum = this._timeLineList.maxScrollY;
	}
	
	private function onContainerClose(evt:EditorEvent):Void
	{
		this._container.removeEventListener(ContainerEvent.LAYER_SELECTED, onLayerSelected);
		this._container.removeEventListener(PlayEvent.PLAY, onPlay);
		this._container.removeEventListener(PlayEvent.STOP, onStop);
		this._layerList.dataProvider = null;
		for (item in this._timeLineItems)
		{
			destroyTimeLineItem(item);
		}
		this._timeLineItems.resize(0);
		this._timeLineList.removeChildren();
		this._currentTimeLineItem = null;
	}
	
	private function onContainerOpen(evt:EditorEvent):Void
	{
		this._container = cast evt.object;
		this._container.addEventListener(ContainerEvent.LAYER_SELECTED, onLayerSelected);
		this._container.addEventListener(PlayEvent.PLAY, onPlay);
		this._container.addEventListener(PlayEvent.STOP, onStop);
		this._layerList.dataProvider = this._container.layerCollection;
		
		for (layer in this._container.layerCollection)
		{
			createTimeLineItem(cast layer.timeLine, this._timeLineItems.length);
		}
		this._timeLineList.validateNow();
		
		var layerIndex:Int = this._container.getLayerIndex(this._container.currentLayer);
		this._layerList.selectedIndex = layerIndex;
		
		this._currentTimeLineItem = this._timeLineItems[layerIndex];
		this._currentTimeLineItem.isCurrent = true;
		
		this._hScrollBar.value = 0.0;
		
		updateHScrollBar();
		updateVScrollBar();
	}
	
	private function createTimeLineItem(timeLine:ValEditorTimeLine, index:Int):Void
	{
		var item:TimeLineItem = TimeLineItem.fromPool(timeLine);
		item.addEventListener(Event.SELECT, onTimeLineItemSelected);
		item.addEventListener(Event.SCROLL, onTimeLineItemScroll);
		this._timeLineItems.insert(index, item);
		this._timeLineList.addChildAt(item, index);
		
		item.scrollX = this._hScrollBar.value;
	}
	
	private function destroyTimeLineItem(item:TimeLineItem):Void
	{
		item.removeEventListener(Event.SELECT, onTimeLineItemSelected);
		item.pool();
	}
	
	private function onLayerAddButton(evt:TriggerEvent):Void
	{
		if (this._layerList.selectedIndex != -1)
		{
			listsChangeDisable();
			
			var layer:ValEditorLayer = ValEditor.createLayer();
			createTimeLineItem(cast layer.timeLine, this._layerList.selectedIndex);
			this._timeLineList.validateNow();
			updateVScrollBar();
			
			this._container.addLayerAt(layer, this._layerList.selectedIndex);
			
			listsChangeEnable();
		}
	}
	
	private function onLayerListChange(evt:Event):Void
	{
		if (this._layerList.selectedIndex != -1)
		{
			this._container.currentLayer = this._container.getLayerAt(this._layerList.selectedIndex);
		}
	}
	
	private function onLayerListScroll(evt:ScrollEvent):Void
	{
		this._vScrollBar.value = this._layerList.scrollY;
	}
	
	private function onLayerRemoveButton(evt:TriggerEvent):Void
	{
		if (this._layerList.selectedIndex != -1 && this._container.layerCollection.length > 1)
		{
			destroyTimeLineItem(this._currentTimeLineItem);
			this._timeLineItems.remove(this._currentTimeLineItem);
			this._timeLineList.removeChild(this._currentTimeLineItem);
			this._currentTimeLineItem = null;
			
			this._container.removeLayerAt(this._layerList.selectedIndex);
		}
	}
	
	private function onLayerSelected(evt:ContainerEvent):Void
	{
		var layer:ValEditorLayer = cast evt.object;
		var layerIndex:Int = this._container.getLayerIndex(layer);
		this._layerList.selectedIndex = layerIndex;
		
		if (this._currentTimeLineItem != null)
		{
			this._currentTimeLineItem.isCurrent = false;
		}
		this._currentTimeLineItem = this._timeLineItems[layerIndex];
		this._currentTimeLineItem.isCurrent = true;
		this._currentTimeLineItem.selectedIndex = layer.timeLine.frameIndex;
	}
	
	private function onPlayStopButton(evt:Event):Void
	{
		ValEditor.playStop();
	}
	
	private function onPlay(evt:PlayEvent):Void
	{
		this._playStopButton.removeEventListener(Event.CHANGE, onPlayStopButton);
		this._playStopButton.selected = true;
		this._playStopButton.addEventListener(Event.CHANGE, onPlayStopButton);
	}
	
	private function onStop(evt:PlayEvent):Void
	{
		this._playStopButton.removeEventListener(Event.CHANGE, onPlayStopButton);
		this._playStopButton.selected = false;
		this._playStopButton.addEventListener(Event.CHANGE, onPlayStopButton);
	}
	
	private function onTimeLineItemScroll(evt:Event):Void
	{
		var timeLineItem:TimeLineItem = cast evt.target;
		this._hScrollBar.value = timeLineItem.scrollX;
	}
	
	private function onTimeLineItemSelected(evt:Event):Void
	{
		var layer:ValEditLayer = this._container.getLayerAt(this._timeLineItems.indexOf(cast evt.target));
		this._container.currentLayer = layer;
	}
	
	private function onTimeLineListScroll(evt:ScrollEvent):Void
	{
		this._vScrollBar.value = this._timeLineList.scrollY;
	}
	
	private function onHScrollBarChange(evt:Event):Void
	{
		for (item in this._timeLineItems)
		{
			item.scrollX = this._hScrollBar.value;
		}
	}
	
	private function onVScrollBarChange(evt:Event):Void
	{
		this._layerList.scrollY = this._vScrollBar.value;
		this._timeLineList.scrollY = this._vScrollBar.value;
	}
	
}