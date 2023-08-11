package valeditor.ui.feathers.view;

import feathers.controls.Button;
import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.ScrollPolicy;
import feathers.data.ListViewItemState;
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
import valeditor.ValEditor;
import valeditor.ValEditorContainer;
import valeditor.ValEditorLayer;
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
	
	private var _timeLineGroup:LayoutGroup;
	private var _timeLineTopGroup:LayoutGroup;
	private var _timeLineList:ListView;
	private var _timeLineBottomGroup:LayoutGroup;
	
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
		this._layerGroup.addChild(this._layerList);
		
		this._layerBottomGroup = new LayoutGroup();
		this._layerBottomGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._layerBottomGroup.layout = hLayout;
		this._layerGroup.addChild(this._layerBottomGroup);
		
		this._layerAddButton = new Button("+", onLayerAddButton);
		this._layerBottomGroup.addChild(this._layerAddButton);
		
		this._layerRemoveButton = new Button("-", onLayerRemoveButton);
		this._layerBottomGroup.addChild(this._layerRemoveButton);
		
		// TIMELINES
		this._timeLineGroup = new LayoutGroup();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._timeLineGroup.layout = vLayout;
		this._mainBox.addChild(this._timeLineGroup);
		
		this._timeLineTopGroup = new LayoutGroup();
		this._timeLineTopGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		this._timeLineTopGroup.layout = hLayout;
		this._timeLineGroup.addChild(this._timeLineTopGroup);
		
		this._timeLineList = new ListView();
		this._timeLineList.variant = ListView.VARIANT_BORDERLESS;
		var timeLineRecycler = DisplayObjectRecycler.withFunction(() -> {
			return TimeLineItem.fromPool();
		});
		timeLineRecycler.destroy = timeLineItemDestroy;
		timeLineRecycler.reset = timeLineItemReset;
		timeLineRecycler.update = timeLineItemUpdate;
		this._timeLineList.itemRendererRecycler = timeLineRecycler;
		this._timeLineList.layoutData = new VerticalLayoutData(null, 100);
		this._timeLineList.scrollPolicyX = ScrollPolicy.OFF;
		this._timeLineList.scrollPolicyY = ScrollPolicy.OFF;
		this._timeLineGroup.addChild(this._timeLineList);
		
		this._timeLineBottomGroup = new LayoutGroup();
		this._timeLineBottomGroup.variant = LayoutGroup.VARIANT_TOOL_BAR;
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._timeLineBottomGroup.layout = hLayout;
		this._timeLineGroup.addChild(this._timeLineBottomGroup);
		
		ValEditor.addEventListener(EditorEvent.CONTAINER_CLOSE, onContainerClose);
		ValEditor.addEventListener(EditorEvent.CONTAINER_OPEN, onContainerOpen);
		
		listsChangeEnable();
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
		this._timeLineList.removeEventListener(Event.CHANGE, onTimeLineListChange);
	}
	
	private function listsChangeEnable():Void
	{
		this._layerList.addEventListener(Event.CHANGE, onLayerListChange);
		this._timeLineList.addEventListener(Event.CHANGE, onTimeLineListChange);
	}
	
	private function timeLineItemDestroy(itemRenderer:TimeLineItem):Void
	{
		itemRenderer.pool();
	}
	
	private function timeLineItemReset(itemRenderer:TimeLineItem, state:ListViewItemState):Void
	{
		
	}
	
	private function timeLineItemUpdate(itemRenderer:TimeLineItem, state:ListViewItemState):Void
	{
		itemRenderer.timeLineUpdate(state);
	}
	
	private function onContainerClose(evt:EditorEvent):Void
	{
		this._layerList.dataProvider = null;
		this._timeLineList.dataProvider = null;
	}
	
	private function onContainerOpen(evt:EditorEvent):Void
	{
		var container:ValEditorContainer = cast evt.object;
		this._layerList.dataProvider = container.layerCollection;
		this._timeLineList.dataProvider = container.layerCollection;
		var layerIndex:Int = container.getLayerIndex(container.currentLayer);
		this._layerList.selectedIndex = layerIndex;
		this._timeLineList.selectedIndex = layerIndex;
		container.addEventListener(ContainerEvent.LAYER_SELECTED, onLayerSelected);
	}
	
	private function onLayerAddButton(evt:TriggerEvent):Void
	{
		if (this._layerList.selectedIndex != -1)
		{
			listsChangeDisable();
			ValEditor.currentContainer.addLayerAt(new ValEditorLayer(), this._layerList.selectedIndex);
			listsChangeEnable();
		}
	}
	
	private function onLayerListChange(evt:Event):Void
	{
		if (this._layerList.selectedIndex != -1)
		{
			ValEditor.currentContainer.currentLayer = ValEditor.currentContainer.getLayerAt(this._layerList.selectedIndex);
		}
	}
	
	private function onLayerRemoveButton(evt:TriggerEvent):Void
	{
		if (this._layerList.selectedIndex != -1 && ValEditor.currentContainer.layerCollection.length > 1)
		{
			ValEditor.currentContainer.removeLayerAt(this._layerList.selectedIndex);
		}
	}
	
	private function onLayerSelected(evt:ContainerEvent):Void
	{
		var layer:ValEditorLayer = cast evt.object;
		var layerIndex:Int = ValEditor.currentContainer.getLayerIndex(layer);
		this._layerList.selectedIndex = layerIndex;
		this._timeLineList.selectedIndex = layerIndex;
	}
	
	private function onTimeLineListChange(evt:Event):Void
	{
		if (this._timeLineList.selectedIndex != -1)
		{
			ValEditor.currentContainer.currentLayer = ValEditor.currentContainer.getLayerAt(this._timeLineList.selectedIndex);
		}
	}
	
}