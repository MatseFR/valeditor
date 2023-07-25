package valeditor.ui.feathers.view;

import feathers.controls.Button;
import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.ScrollContainer;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import openfl.Lib;
import valeditor.ValEditor;
import valeditor.ValEditorContainer;
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
	private var _layerList:ScrollContainer;
	private var _layerBottomGroup:LayoutGroup;
	
	private var _layerAddButton:Button;
	private var _layerRemoveButton:Button;
	
	private var _layerItems:Array<LayerItem> = new Array<LayerItem>();
	
	private var _timeLineGroup:LayoutGroup;
	private var _timeLineTopGroup:LayoutGroup;
	private var _timeLineList:ScrollContainer;
	private var _timeLineBottomGroup:LayoutGroup;
	
	private var _timeLineItems:Array<TimeLineItem> = new Array<TimeLineItem>();

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
		
		this._layerList = new ScrollContainer();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._layerList.layout = vLayout;
		this._layerList.layoutData = new VerticalLayoutData(null, 100);
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
		
		this._timeLineList = new ScrollContainer();
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._timeLineList.layout = vLayout;
		this._timeLineList.layoutData = new VerticalLayoutData(null, 100);
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
	}
	
	private function onContainerClose(evt:EditorEvent):Void
	{
		this._layerList.removeChildren();
		for (layerItem in this._layerItems)
		{
			layerItem.pool();
		}
		this._layerItems.resize(0);
		this._timeLineList.removeChildren();
		for (timeLineItem in this._timeLineItems)
		{
			timeLineItem.pool();
		}
		this._timeLineItems.resize(0);
	}
	
	private function onContainerOpen(evt:EditorEvent):Void
	{
		var container:ValEditorContainer = cast evt.object;
		var layerItem:LayerItem;
		var timeLineItem:TimeLineItem;
		
		for (layer in container.layerCollection)
		{
			layerItem = LayerItem.fromPool(layer);
			this._layerList.addChild(layerItem);
			this._layerItems.push(layerItem);
			timeLineItem = TimeLineItem.fromPool(cast layer.timeLine);
			this._timeLineList.addChild(timeLineItem);
			this._timeLineItems.push(timeLineItem);
		}
	}
	
	private function onLayerAddButton(evt:TriggerEvent):Void
	{
		
	}
	
	private function onLayerRemoveButton(evt:TriggerEvent):Void
	{
		
	}
	
}