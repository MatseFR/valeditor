package valeditor.ui.feathers.view;

import feathers.controls.Button;
import feathers.controls.HDividedBox;
import feathers.controls.HScrollBar;
import feathers.controls.HSlider;
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
import feathers.layout.HorizontalLayoutData;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.utils.DisplayObjectRecycler;
import juggler.animation.IAnimatable;
import openfl.Lib;
import openfl.display.Shape;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import valedit.ValEditLayer;
import valedit.events.PlayEvent;
import valeditor.ValEditor;
import valeditor.ValEditorContainer;
import valeditor.ValEditorLayer;
import valeditor.ValEditorTimeLine;
import valeditor.events.ContainerEvent;
import valeditor.events.EditorEvent;
import valeditor.events.TimeLineEvent;
import valeditor.ui.feathers.controls.item.LayerItem;
import valeditor.ui.feathers.controls.item.TimeLineItem;
import valeditor.ui.feathers.variant.ButtonVariant;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valeditor.ui.feathers.variant.ListViewVariant;
import valeditor.ui.feathers.variant.ScrollContainerVariant;
import valeditor.ui.feathers.variant.ToggleButtonVariant;

/**
 * ...
 * @author Matse
 */
class ScenarioView extends LayoutGroup implements IAnimatable
{
	private var _mainBox:HDividedBox;
	
	private var _layerGroup:LayoutGroup;
	private var _layerTopGroup:LayoutGroup;
	private var _layerList:ListView;
	private var _layerBottomGroup:LayoutGroup;
	
	private var _layerAddButton:Button;
	private var _layerRemoveButton:Button;
	private var _layerRenameButton:Button;
	
	private var _timeLineMainGroup:LayoutGroup;
	private var _timeLineTopGroup:LayoutGroup;
	private var _timeLineTopControlsGroup:LayoutGroup;
	private var _timeLineRulerList:ListView;
	private var _timeLineNumberList:ListView;
	private var _timeLineGroup:LayoutGroup;
	private var _timeLineList:ScrollContainer;
	private var _timeLineBottomGroup:LayoutGroup;
	private var _timeLineControlsGroup:LayoutGroup;
	
	private var _frameFirstButton:Button;
	private var _framePreviousButton:Button;
	private var _playStopButton:ToggleButton;
	private var _frameNextButton:Button;
	private var _frameLastButton:Button;
	
	private var _timeLineItems:Array<TimeLineItem> = new Array<TimeLineItem>();
	
	private var _hScrollBar:HScrollBar;
	private var _vScrollBar:VScrollBar;
	
	private var _container:ValEditorContainer;
	private var _currentTimeLineItem:TimeLineItem;
	
	// TESTING
	private var _cursor:LayoutGroup;
	private var _indicatorContainer:ScrollContainer;
	private var _indicator:LayoutGroup;
	
	private var _pt:Point = new Point();
	//\TESTING
	
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
		this._layerTopGroup.variant = LayoutGroupVariant.TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.RIGHT;
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
		this._layerBottomGroup.variant = LayoutGroupVariant.TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.setPadding(Padding.MINIMAL);
		hLayout.gap = Spacing.MINIMAL;
		this._layerBottomGroup.layout = hLayout;
		this._layerGroup.addChild(this._layerBottomGroup);
		
		this._layerAddButton = new Button(null, onLayerAddButton);
		this._layerAddButton.variant = ButtonVariant.ADD;
		this._layerBottomGroup.addChild(this._layerAddButton);
		
		this._layerRemoveButton = new Button(null, onLayerRemoveButton);
		this._layerRemoveButton.variant = ButtonVariant.REMOVE;
		this._layerRemoveButton.enabled = false;
		this._layerBottomGroup.addChild(this._layerRemoveButton);
		
		this._layerRenameButton = new Button(null, null);
		this._layerRenameButton.variant = ButtonVariant.RENAME;
		this._layerBottomGroup.addChild(this._layerRenameButton);
		
		// TIMELINES
		this._timeLineMainGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._timeLineMainGroup.layout = vLayout;
		this._mainBox.addChild(this._timeLineMainGroup);
		
		this._timeLineTopGroup = new LayoutGroup();
		this._timeLineTopGroup.variant = LayoutGroupVariant.TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.paddingBottom = 1;
		hLayout.paddingTop = 2;
		this._timeLineTopGroup.layout = hLayout;
		this._timeLineTopGroup.addEventListener(MouseEvent.MOUSE_DOWN, onRulerMouseDown);
		this._timeLineMainGroup.addChild(this._timeLineTopGroup);
		
		this._timeLineTopControlsGroup = new LayoutGroup();
		this._timeLineTopControlsGroup.layout = new AnchorLayout();
		this._timeLineTopControlsGroup.mouseEnabled = false;
		this._timeLineTopControlsGroup.mouseChildren = false;
		this._timeLineTopGroup.addChild(this._timeLineTopControlsGroup);
		
		this._timeLineRulerList = new ListView();
		this._timeLineRulerList.variant = ListViewVariant.TIMELINE_RULER;
		this._timeLineRulerList.layoutData = new AnchorLayoutData(null, 0, null, 0);
		this._timeLineTopControlsGroup.addChild(this._timeLineRulerList);
		
		this._timeLineNumberList = new ListView();
		this._timeLineNumberList.variant = ListViewVariant.TIMELINE_NUMBERS;
		this._timeLineNumberList.layoutData = new AnchorLayoutData(null, 0, 0, 0);
		this._timeLineTopControlsGroup.addChild(this._timeLineNumberList);
		
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
		
		this._indicatorContainer = new ScrollContainer();
		this._indicatorContainer.variant = ScrollContainerVariant.TRANSPARENT;
		this._indicatorContainer.mouseEnabled = false;
		this._indicatorContainer.mouseChildren = false;
		this._indicatorContainer.layoutData = new AnchorLayoutData(0, new Anchor(0, this._vScrollBar), 0, 0);
		this._indicatorContainer.scrollPolicyX = ScrollPolicy.OFF;
		this._indicatorContainer.scrollPolicyY = ScrollPolicy.OFF;
		this._indicatorContainer.layout = new AnchorLayout();
		this._timeLineGroup.addChild(this._indicatorContainer);
		
		this._timeLineBottomGroup = new LayoutGroup();
		this._timeLineBottomGroup.variant = LayoutGroupVariant.TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.paddingRight = 12;
		this._timeLineBottomGroup.layout = hLayout;
		this._timeLineMainGroup.addChild(this._timeLineBottomGroup);
		
		this._timeLineControlsGroup = new LayoutGroup();
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.setPadding(Padding.MINIMAL);
		hLayout.gap = Spacing.MINIMAL;
		this._timeLineControlsGroup.layout = hLayout;
		this._timeLineBottomGroup.addChild(this._timeLineControlsGroup);
		
		this._hScrollBar = new HScrollBar();
		this._hScrollBar.snapInterval = 8.0;
		this._hScrollBar.layoutData = new HorizontalLayoutData(100);
		this._hScrollBar.addEventListener(Event.CHANGE, onHScrollBarChange);
		this._timeLineBottomGroup.addChild(this._hScrollBar);
		
		this._frameFirstButton = new Button(null, onFrameFirstButton);
		this._frameFirstButton.variant = ButtonVariant.FRAME_FIRST;
		this._timeLineControlsGroup.addChild(this._frameFirstButton);
		
		this._framePreviousButton = new Button(null, onFramePreviousButton);
		this._framePreviousButton.variant = ButtonVariant.FRAME_PREVIOUS;
		this._timeLineControlsGroup.addChild(this._framePreviousButton);
		
		this._playStopButton = new ToggleButton(null, false, onPlayStopButton);
		this._playStopButton.variant = ToggleButtonVariant.PLAY_STOP;
		this._timeLineControlsGroup.addChild(this._playStopButton);
		
		this._frameNextButton = new Button(null, onFrameNextButton);
		this._frameNextButton.variant = ButtonVariant.FRAME_NEXT;
		this._timeLineControlsGroup.addChild(this._frameNextButton);
		
		this._frameLastButton = new Button(null, onFramePreviousButton);
		this._frameLastButton.variant = ButtonVariant.FRAME_LAST;
		this._timeLineControlsGroup.addChild(this._frameLastButton);
		
		this._timeLineList.addEventListener(Event.RESIZE, onTimeLineResize);
		
		this._indicator = new LayoutGroup();
		this._indicator.variant = LayoutGroupVariant.TIMELINE_INDICATOR;
		this._indicator.layoutData = new AnchorLayoutData(0, null, 0);
		this._indicatorContainer.addChild(this._indicator);
		
		ValEditor.addEventListener(EditorEvent.CONTAINER_CLOSE, onContainerClose);
		ValEditor.addEventListener(EditorEvent.CONTAINER_OPEN, onContainerOpen);
		
		listsChangeEnable();
	}
	
	private function onRulerMouseDown(evt:MouseEvent):Void
	{
		_pt.x = evt.stageX;
		
		if (this._currentTimeLineItem != null)
		{
			this._currentTimeLineItem.clearSelection();
		}
		
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onRulerMouseMove);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, onRulerMouseUp);
		ValEditor.juggler.add(this);
	}
	
	private function onRulerMouseMove(evt:MouseEvent):Void
	{
		_pt.x = evt.stageX;
	}
	
	public function advanceTime(time:Float):Void
	{
		var loc:Point = this._timeLineTopControlsGroup.globalToLocal(_pt);
		var index:Int;
		var indexMax:Int = this._timeLineRulerList.dataProvider.length - 1; // this._container.timeLine.lastFrameIndex;
		
		if (loc.x < 0.0)
		{
			loc.x = 0.0;
			this._hScrollBar.value = Math.max(this._hScrollBar.value - 8.0, this._hScrollBar.minimum);
		}
		else if (loc.x > this._timeLineTopControlsGroup.width)
		{
			loc.x = this._timeLineTopControlsGroup.width;
			this._hScrollBar.value = Math.min(this._hScrollBar.value + 8.0, this._hScrollBar.maximum);
		}
		index = Math.floor((this._hScrollBar.value + loc.x) / 8);
		if (index > indexMax) index = indexMax;
		setPlayHeadIndex(index);
	}
	
	private function onRulerMouseUp(evt:MouseEvent):Void
	{
		this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onRulerMouseMove);
		this.stage.removeEventListener(MouseEvent.MOUSE_UP, onRulerMouseUp);
		ValEditor.juggler.remove(this);
	}
	
	private function setPlayHeadIndex(index:Int):Void
	{
		this._timeLineRulerList.selectedIndex = index;
		this._indicator.x = index * 8;
		this._container.frameIndex = index;
	}
	
	private function onTimeLineResize(evt:Event):Void
	{
		this._layerTopGroup.height = this._timeLineTopGroup.height;
		this._timeLineTopControlsGroup.width = this._timeLineList.width;
		
		updateHScrollBar();
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
		this._timeLineRulerList.validateNow();
		this._hScrollBar.minimum = this._timeLineRulerList.minScrollX;
		this._hScrollBar.maximum = this._timeLineRulerList.maxScrollX;
	}
	
	private function updateVScrollBar():Void
	{
		this._vScrollBar.minimum = this._timeLineList.minScrollY;
		this._vScrollBar.maximum = this._timeLineList.maxScrollY;
	}
	
	private function onContainerClose(evt:EditorEvent):Void
	{
		this._container.removeEventListener(ContainerEvent.LAYER_ADDED, onLayerAdded);
		this._container.removeEventListener(ContainerEvent.LAYER_REMOVED, onLayerRemoved);
		this._container.removeEventListener(ContainerEvent.LAYER_SELECTED, onLayerSelected);
		this._container.removeEventListener(PlayEvent.PLAY, onPlay);
		this._container.removeEventListener(PlayEvent.STOP, onStop);
		this._container.timeLine.removeEventListener(TimeLineEvent.NUM_FRAMES_CHANGE, onNumFramesChange);
		this._container.timeLine.removeEventListener(TimeLineEvent.FRAME_INDEX_CHANGE, onTimeLineFrameIndexChange);
		this._layerList.dataProvider = null;
		this._timeLineRulerList.dataProvider = null;
		this._timeLineNumberList.dataProvider = null;
		
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
		this._container.addEventListener(ContainerEvent.LAYER_ADDED, onLayerAdded);
		this._container.addEventListener(ContainerEvent.LAYER_REMOVED, onLayerRemoved);
		this._container.addEventListener(ContainerEvent.LAYER_SELECTED, onLayerSelected);
		this._container.addEventListener(PlayEvent.PLAY, onPlay);
		this._container.addEventListener(PlayEvent.STOP, onStop);
		this._container.timeLine.addEventListener(TimeLineEvent.NUM_FRAMES_CHANGE, onNumFramesChange);
		this._container.timeLine.addEventListener(TimeLineEvent.FRAME_INDEX_CHANGE, onTimeLineFrameIndexChange);
		this._layerList.dataProvider = this._container.layerCollection;
		this._timeLineRulerList.dataProvider = cast(this._container.timeLine, ValEditorTimeLine).frameCollection;
		this._timeLineNumberList.dataProvider = cast(this._container.timeLine, ValEditorTimeLine).frameCollection;
		
		setPlayHeadIndex(this._container.frameIndex);
		
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
	
	private function onFrameFirstButton(evt:TriggerEvent):Void
	{
		ValEditor.firstFrame();
	}
	
	private function onFrameLastButton(evt:TriggerEvent):Void
	{
		ValEditor.lastFrame();
	}
	
	private function onFrameNextButton(evt:TriggerEvent):Void
	{
		ValEditor.nextFrame();
	}
	
	private function onFramePreviousButton(evt:TriggerEvent):Void
	{
		ValEditor.previousFrame();
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
	
	private function onLayerAdded(evt:ContainerEvent):Void
	{
		this._layerRemoveButton.enabled = this._layerList.selectedIndex != -1 && this._container.numLayers > 1;
	}
	
	private function onLayerListChange(evt:Event):Void
	{
		if (this._layerList.selectedIndex != -1)
		{
			this._container.currentLayer = this._container.getLayerAt(this._layerList.selectedIndex);
		}
		this._layerRemoveButton.enabled = this._layerList.selectedIndex != -1 && this._container.numLayers > 1;
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
			this._timeLineList.validateNow();
			this._currentTimeLineItem = null;
			
			this._container.removeLayerAt(this._layerList.selectedIndex);
			
			updateVScrollBar();
		}
	}
	
	private function onLayerRemoved(evt:ContainerEvent):Void
	{
		this._layerRemoveButton.enabled = this._layerList.selectedIndex != -1 && this._container.numLayers > 1;
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
	
	private function onNumFramesChange(evt:TimeLineEvent):Void
	{
		updateHScrollBar();
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
	
	private function onTimeLineFrameIndexChange(evt:TimeLineEvent):Void
	{
		setPlayHeadIndex(this._container.frameIndex);
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
		var scrollX:Float = this._hScrollBar.value;
		for (item in this._timeLineItems)
		{
			item.scrollX = scrollX;
		}
		this._indicatorContainer.scrollX = scrollX;
		this._timeLineNumberList.scrollX = scrollX;
		this._timeLineRulerList.scrollX = scrollX;
	}
	
	private function onVScrollBarChange(evt:Event):Void
	{
		this._layerList.scrollY = this._vScrollBar.value;
		this._timeLineList.scrollY = this._vScrollBar.value;
	}
	
}