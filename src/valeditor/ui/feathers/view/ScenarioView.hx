package valeditor.ui.feathers.view;

import feathers.controls.Button;
import feathers.controls.HDividedBox;
import feathers.controls.HScrollBar;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.ToggleButton;
import feathers.controls.VScrollBar;
import feathers.controls.popups.CalloutPopUpAdapter;
import feathers.core.InvalidationFlag;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.ListViewEvent;
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
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import juggler.animation.IAnimatable;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import valedit.events.PlayEvent;
import valedit.utils.ReverseIterator;
import valeditor.ValEditor;
import valeditor.ValEditorContainer;
import valeditor.ValEditorLayer;
import valeditor.ValEditorTimeLine;
import valeditor.editor.Selection;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.layer.LayerAdd;
import valeditor.editor.action.layer.LayerIndexDown;
import valeditor.editor.action.layer.LayerIndexUp;
import valeditor.editor.action.layer.LayerLock;
import valeditor.editor.action.layer.LayerRemove;
import valeditor.editor.action.layer.LayerVisible;
import valeditor.editor.action.timeline.TimeLineSetFrameIndex;
import valeditor.events.ContainerEvent;
import valeditor.events.EditorEvent;
import valeditor.events.LayerEvent;
import valeditor.events.TimeLineEvent;
import valeditor.ui.feathers.controls.item.TimeLineItem;
import valeditor.ui.feathers.data.FrameData;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.renderers.BitmapScrollRenderer;
import valeditor.ui.feathers.renderers.LayerItemRenderer;
import valeditor.ui.feathers.renderers.MenuItemRenderer;
import valeditor.ui.feathers.variant.ButtonVariant;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valeditor.ui.feathers.variant.ListViewVariant;
import valeditor.ui.feathers.variant.ScrollContainerVariant;
import valeditor.ui.feathers.variant.ToggleButtonVariant;

/**
 * ...
 * @author Matse
 */
@:styleContext
class ScenarioView extends LayoutGroup implements IAnimatable
{
	public var lockIconBitmapData(get, set):BitmapData;
	public var visibleIconBitmapData(get, set):BitmapData;
	
	private var _lockIconBitmapData:BitmapData;
	private function get_lockIconBitmapData():BitmapData { return this._lockIconBitmapData; }
	private function set_lockIconBitmapData(value:BitmapData):BitmapData
	{
		if (this._initialized)
		{
			this._lockIcon.bitmapData = value;
			this._lockIcon.smoothing = true;
			this._layerTopGroup.setInvalid(InvalidationFlag.LAYOUT);
		}
		return this._lockIconBitmapData = value;
	}
	
	private var _visibleIconBitmapData:BitmapData;
	private function get_visibleIconBitmapData():BitmapData { return this._visibleIconBitmapData; }
	private function set_visibleIconBitmapData(value:BitmapData):BitmapData
	{
		if (this._initialized)
		{
			this._visibleIcon.bitmapData = value;
			this._visibleIcon.smoothing = true;
			this._layerTopGroup.setInvalid(InvalidationFlag.LAYOUT);
		}
		return this._visibleIconBitmapData = value;
	}
	
	private var _mainBox:HDividedBox;
	
	private var _layerGroup:LayoutGroup;
	private var _layerTopGroup:LayoutGroup;
	private var _lockIcon:Bitmap;
	private var _visibleIcon:Bitmap;
	private var _layerList:ListView;
	private var _layerBottomGroup:LayoutGroup;
	
	private var _layerAddButton:Button;
	private var _layerRemoveButton:Button;
	private var _layerRenameButton:Button;
	private var _layerUpButton:Button;
	private var _layerDownButton:Button;
	
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
	private var _timeLineToItem:Map<ValEditorTimeLine, TimeLineItem> = new Map<ValEditorTimeLine, TimeLineItem>();
	
	private var _hScrollBar:HScrollBar;
	private var _vScrollBar:VScrollBar;
	
	private var _container:ValEditorContainer;
	private var _currentTimeLineItem:TimeLineItem;
	
	private var _cursor:LayoutGroup;
	private var _indicatorContainer:ScrollContainer;
	private var _indicator:LayoutGroup;
	
	private var _rulerPt:Point = new Point();
	
	private var _frameContextMenu:ListView;
	private var _frameContextMenuCollection:ArrayCollection<MenuItem>;
	private var _framePopupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	
	private var _insertFrameItem:MenuItem;
	private var _insertKeyFrameItem:MenuItem;
	private var _removeFrameItem:MenuItem;
	private var _removeKeyFrameItem:MenuItem;
	
	private var _layerContextMenu:ListView;
	private var _layerContextMenuCollection:ArrayCollection<MenuItem>;
	private var _layerPopupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	private var _contextSelectedLayers:Array<ValEditorLayer> = new Array<ValEditorLayer>();
	private var _contextOtherLayers:Array<ValEditorLayer> = new Array<ValEditorLayer>();
	
	private var _insertLayerItem:MenuItem;
	private var _removeLayerItem:MenuItem;
	private var _showAllLayerItem:MenuItem;
	private var _unlockAllLayerItem:MenuItem;
	private var _lockOthersLayerItem:MenuItem;
	private var _hideOthersLayerItem:MenuItem;
	private var _moveDownLayerItem:MenuItem;
	private var _moveUpLayerItem:MenuItem;
	
	private var _contextMenuSprite:Sprite;
	private var _contextMenuPt:Point = new Point();
	private var _contextMenuRect:Rectangle = new Rectangle();
	
	private var _lastFrameIndex:Int;
	private var _selection:Selection = new Selection();
	
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
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.paddingRight = Padding.MINIMAL;
		hLayout.gap = Spacing.MINIMAL;
		this._layerTopGroup.layout = hLayout;
		this._layerGroup.addChild(this._layerTopGroup);
		
		this._visibleIcon = new Bitmap(this._visibleIconBitmapData, PixelSnapping.AUTO, true);
		this._layerTopGroup.addChild(this._visibleIcon);
		
		this._lockIcon = new Bitmap(this._lockIconBitmapData, PixelSnapping.AUTO, true);
		this._layerTopGroup.addChild(this._lockIcon);
		
		this._layerList = new ListView();
		this._layerList.variant = ListView.VARIANT_BORDERLESS;
		var layerRecycler = DisplayObjectRecycler.withFunction(() -> {
			var renderer:LayerItemRenderer = LayerItemRenderer.fromPool();
			renderer.addEventListener(MouseEvent.RIGHT_CLICK, onLayerItemRightClick);
			return renderer;
		});
		layerRecycler.destroy = layerItemDestroy;
		layerRecycler.reset = layerItemReset;
		layerRecycler.update = layerItemUpdate;
		this._layerList.itemRendererRecycler = layerRecycler;
		this._layerList.allowMultipleSelection = true;
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
		this._layerAddButton.toolTip = "add new layer";
		this._layerBottomGroup.addChild(this._layerAddButton);
		
		this._layerRemoveButton = new Button(null, onLayerRemoveButton);
		this._layerRemoveButton.variant = ButtonVariant.REMOVE;
		this._layerRemoveButton.toolTip = "remove selected layer(s)";
		this._layerRemoveButton.enabled = false;
		this._layerBottomGroup.addChild(this._layerRemoveButton);
		
		this._layerRenameButton = new Button(null, onLayerRenameButton);
		this._layerRenameButton.variant = ButtonVariant.RENAME;
		this._layerRenameButton.toolTip = "rename selected layer";
		this._layerBottomGroup.addChild(this._layerRenameButton);
		
		this._layerUpButton = new Button(null, onLayerUpButton);
		this._layerUpButton.variant = ButtonVariant.UP;
		this._layerUpButton.toolTip = "move selected layer(s) up";
		this._layerBottomGroup.addChild(this._layerUpButton);
		
		this._layerDownButton = new Button(null, onLayerDownButton);
		this._layerDownButton.variant = ButtonVariant.DOWN;
		this._layerDownButton.toolTip = "move selected layer(s) down";
		this._layerBottomGroup.addChild(this._layerDownButton);
		
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
		this._frameFirstButton.toolTip = "first frame";
		this._timeLineControlsGroup.addChild(this._frameFirstButton);
		
		this._framePreviousButton = new Button(null, onFramePreviousButton);
		this._framePreviousButton.variant = ButtonVariant.FRAME_PREVIOUS;
		this._framePreviousButton.toolTip = "previous frame";
		this._timeLineControlsGroup.addChild(this._framePreviousButton);
		
		this._playStopButton = new ToggleButton(null, false, onPlayStopButton);
		this._playStopButton.variant = ToggleButtonVariant.PLAY_STOP;
		this._playStopButton.toolTip = "play/stop";
		this._timeLineControlsGroup.addChild(this._playStopButton);
		
		this._frameNextButton = new Button(null, onFrameNextButton);
		this._frameNextButton.variant = ButtonVariant.FRAME_NEXT;
		this._frameNextButton.toolTip = "next frame";
		this._timeLineControlsGroup.addChild(this._frameNextButton);
		
		this._frameLastButton = new Button(null, onFrameLastButton);
		this._frameLastButton.variant = ButtonVariant.FRAME_LAST;
		this._frameLastButton.toolTip = "last frame";
		this._timeLineControlsGroup.addChild(this._frameLastButton);
		
		this._timeLineList.addEventListener(Event.RESIZE, onTimeLineResize);
		
		this._indicator = new LayoutGroup();
		this._indicator.variant = LayoutGroupVariant.TIMELINE_INDICATOR;
		this._indicator.layoutData = new AnchorLayoutData(0, null, 0);
		this._indicatorContainer.addChild(this._indicator);
		
		this._insertFrameItem = new MenuItem("insert frame", "Insert frame", true, "F5");
		this._insertKeyFrameItem = new MenuItem("insert keyframe", "Insert keyframe", true, "F6");
		this._removeFrameItem = new MenuItem("remove frame", "Remove frame", true, "Shift+F5");
		this._removeKeyFrameItem = new MenuItem("remove keyframe", "Remove keyframe", true, "Shift+F6");
		
		this._frameContextMenuCollection = new ArrayCollection<MenuItem>([
			this._insertFrameItem,
			this._insertKeyFrameItem,
			this._removeFrameItem,
			this._removeKeyFrameItem
		]);
		
		var recycler = DisplayObjectRecycler.withFunction(()->{
			return new MenuItemRenderer();
		});
		
		recycler.update = (renderer:MenuItemRenderer, state:ListViewItemState) -> {
			renderer.text = state.data.text;
			renderer.shortcutText = state.data.shortcutText;
			renderer.iconBitmapData = state.data.iconBitmapData;
			renderer.enabled = state.data.enabled;
		};
		
		this._frameContextMenu = new ListView(this._frameContextMenuCollection);
		this._frameContextMenu.variant = ListViewVariant.CONTEXT_MENU;
		var listLayout:VerticalListLayout = new VerticalListLayout();
		listLayout.requestedRowCount = this._frameContextMenuCollection.length;
		this._frameContextMenu.layout = listLayout;
		this._frameContextMenu.itemRendererRecycler = recycler;
		this._frameContextMenu.itemToEnabled = function(item:Dynamic):Bool {
			return item.enabled;
		}
		this._frameContextMenu.itemToText = function(item:Dynamic):String {
			return item.text;
		}
		
		this._frameContextMenu.addEventListener(Event.CHANGE, onFrameContextMenuChange);
		this._frameContextMenu.addEventListener(ListViewEvent.ITEM_TRIGGER, onFrameContextMenuItemTrigger);
		
		this._insertLayerItem = new MenuItem("insert layer", "Insert layer");
		this._removeLayerItem = new MenuItem("remove layer", "Remove layer(s)");
		this._showAllLayerItem = new MenuItem("show all", "Show all");
		this._unlockAllLayerItem = new MenuItem("unlock all", "Unlock all");
		this._hideOthersLayerItem = new MenuItem("hide others", "Hide other(s)");
		this._lockOthersLayerItem = new MenuItem("lock others", "Lock other(s)");
		this._moveUpLayerItem = new MenuItem("move up", "Move up layer(s)");
		this._moveDownLayerItem = new MenuItem("move down", "Move down layer(s)");
		
		this._layerContextMenuCollection = new ArrayCollection<MenuItem>([
			this._insertLayerItem,
			this._removeLayerItem,
			this._showAllLayerItem,
			this._unlockAllLayerItem,
			this._hideOthersLayerItem,
			this._lockOthersLayerItem,
			this._moveUpLayerItem,
			this._moveDownLayerItem
		]);
		
		recycler = DisplayObjectRecycler.withFunction(()->{
			return new MenuItemRenderer();
		});
		
		recycler.update = (renderer:MenuItemRenderer, state:ListViewItemState) -> {
			renderer.text = state.data.text;
			renderer.shortcutText = state.data.shortcutText;
			renderer.iconBitmapData = state.data.iconBitmapData;
			renderer.enabled = state.data.enabled;
		};
		
		this._layerContextMenu = new ListView(this._layerContextMenuCollection);
		this._layerContextMenu.variant = ListViewVariant.CONTEXT_MENU;
		var listLayout:VerticalListLayout = new VerticalListLayout();
		listLayout.requestedRowCount = this._layerContextMenuCollection.length;
		this._layerContextMenu.layout = listLayout;
		this._layerContextMenu.itemRendererRecycler = recycler;
		this._layerContextMenu.itemToEnabled = function(item:Dynamic):Bool {
			return item.enabled;
		}
		this._layerContextMenu.itemToText = function(item:Dynamic):String {
			return item.text;
		}
		
		this._layerContextMenu.addEventListener(Event.CHANGE, onLayerContextMenuChange);
		this._layerContextMenu.addEventListener(ListViewEvent.ITEM_TRIGGER, onLayerContextMenuItemTrigger);
		
		this._contextMenuSprite = new Sprite();
		this._contextMenuSprite.mouseEnabled = false;
		this._contextMenuSprite.graphics.beginFill(0xff0000, 0);
		this._contextMenuSprite.graphics.drawRect(0, 0, 4, 4);
		this._contextMenuSprite.graphics.endFill();
		addChild(this._contextMenuSprite);
		
		ValEditor.addEventListener(EditorEvent.CONTAINER_CLOSE, onContainerClose);
		ValEditor.addEventListener(EditorEvent.CONTAINER_OPEN, onContainerOpen);
		
		this._layerList.addEventListener(Event.CHANGE, onLayerListChange);
	}
	
	private function onFrameContextMenuChange(evt:Event):Void
	{
		if (this._frameContextMenu.selectedItem == null) return;
		
		if (!this._frameContextMenu.selectedItem.enabled) return;
		
		var action:MultiAction;
		
		switch (this._frameContextMenu.selectedItem.id)
		{
			case "insert frame" :
				action = MultiAction.fromPool();
				ValEditor.insertFrame(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case "insert keyframe" :
				action = MultiAction.fromPool();
				ValEditor.insertKeyFrame(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case "remove frame" :
				action = MultiAction.fromPool();
				ValEditor.removeFrame(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
			
			case "remove keyframe" :
				action = MultiAction.fromPool();
				ValEditor.removeKeyFrame(action);
				if (action.numActions != 0)
				{
					ValEditor.actionStack.add(action);
				}
				else
				{
					action.pool();
				}
		}
	}
	
	private function onFrameContextMenuItemTrigger(evt:ListViewEvent):Void
	{
		if (!evt.state.enabled)
		{
			return;
		}
		closeFrameContextMenu();
	}
	
	private function onLayerContextMenuChange(evt:Event):Void
	{
		if (this._layerContextMenu.selectedItem == null) return;
		
		if (!this._layerContextMenu.selectedItem.enabled) return;
		
		switch (this._layerContextMenu.selectedItem.id)
		{
			case "insert layer" :
				var layer:ValEditorLayer = ValEditor.createLayer();
				
				var layers:Array<ValEditorLayer> = [layer];
				var action:LayerAdd = LayerAdd.fromPool();
				action.setup(this._container, layers, this._layerList.selectedIndex);
				ValEditor.actionStack.add(action);
			
			case "remove layer" :
				this._currentTimeLineItem = null;
				
				var action:LayerRemove = LayerRemove.fromPool();
				var layers:Array<ValEditorLayer> = new Array<ValEditorLayer>();
				for (layer in this._layerList.selectedItems)
				{
					layers.push(layer);
				}
				action.setup(this._container, layers);
				ValEditor.actionStack.add(action);
			
			case "show all" :
				var action:LayerVisible = LayerVisible.fromPool();
				for (layer in this._container.layerCollection)
				{
					if (!layer.visible)
					{
						action.addLayer(layer, true);
					}
				}
				ValEditor.actionStack.add(action);
			
			case "unlock all" :
				var action:LayerLock = LayerLock.fromPool();
				for (layer in this._container.layerCollection)
				{
					if (layer.locked)
					{
						action.addLayer(layer, false);
					}
				}
				ValEditor.actionStack.add(action);
			
			case "hide others" :
				for (layer in this._layerList.selectedItems)
				{
					this._contextSelectedLayers.push(layer);
				}
				this._container.getOtherLayers(this._contextSelectedLayers, this._contextOtherLayers);
				var action:LayerVisible = LayerVisible.fromPool();
				for (layer in this._contextSelectedLayers)
				{
					if (!layer.visible)
					{
						action.addLayer(layer, true);
					}
				}
				for (layer in this._contextOtherLayers)
				{
					if (layer.visible)
					{
						action.addLayer(layer, false);
					}
				}
				this._contextSelectedLayers.resize(0);
				this._contextOtherLayers.resize(0);
				ValEditor.actionStack.add(action);
			
			case "lock others" :
				for (layer in this._layerList.selectedItems)
				{
					this._contextSelectedLayers.push(layer);
				}
				this._container.getOtherLayers(this._contextSelectedLayers, this._contextOtherLayers);
				var action:LayerLock = LayerLock.fromPool();
				for (layer in this._contextSelectedLayers)
				{
					if (layer.locked)
					{
						action.addLayer(layer, false);
					}
				}
				for (layer in this._contextOtherLayers)
				{
					if (!layer.locked)
					{
						action.addLayer(layer, true);
					}
				}
				this._contextSelectedLayers.resize(0);
				this._contextOtherLayers.resize(0);
				ValEditor.actionStack.add(action);
			
			case "move up" :
				var action:LayerIndexUp = LayerIndexUp.fromPool();
				var layers:Array<ValEditorLayer> = new Array<ValEditorLayer>();
				for (layer in this._layerList.selectedItems)
				{
					layers.push(layer);
				}
				action.setup(this._container, layers);
				ValEditor.actionStack.add(action);
			
			case "move down" :
				var action:LayerIndexDown = LayerIndexDown.fromPool();
				var layers:Array<ValEditorLayer> = new Array<ValEditorLayer>();
				for (layer in this._layerList.selectedItems)
				{
					layers.push(layer);
				}
				action.setup(this._container, layers);
				ValEditor.actionStack.add(action);
		}
	}
	
	private function onLayerContextMenuItemTrigger(evt:ListViewEvent):Void
	{
		if (!evt.state.enabled)
		{
			return;
		}
		closeLayerContextMenu();
	}
	
	private function onRulerMouseDown(evt:MouseEvent):Void
	{
		this._lastFrameIndex = this._container.frameIndex;
		
		this._rulerPt.x = evt.stageX;
		
		if (this._currentTimeLineItem != null)
		{
			this._currentTimeLineItem.clearSelection();
		}
		
		this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onRulerMouseMove);
		this.stage.addEventListener(MouseEvent.MOUSE_UP, onRulerMouseUp);
		ValEditor.juggler.add(this);
		
		// copy current selection
		this._selection.copyFrom(ValEditor.selection);
	}
	
	private function onRulerMouseMove(evt:MouseEvent):Void
	{
		this._rulerPt.x = evt.stageX;
	}
	
	public function advanceTime(time:Float):Void
	{
		var loc:Point = this._timeLineTopControlsGroup.globalToLocal(this._rulerPt);
		var index:Int;
		var indexMax:Int = this._timeLineRulerList.dataProvider.length - 1;
		
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
		
		if (this._container.frameIndex != this._lastFrameIndex)
		{
			var setFrameIndex:TimeLineSetFrameIndex = TimeLineSetFrameIndex.fromPool();
			// use copied selection
			setFrameIndex.setup(cast this._container.timeLine, this._container.frameIndex, this._lastFrameIndex, this._selection);
			ValEditor.actionStack.add(setFrameIndex);
			this._selection.clear();
		}
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
	
	private function layerItemDestroy(itemRenderer:LayerItemRenderer):Void
	{
		itemRenderer.removeEventListener(MouseEvent.RIGHT_CLICK, onLayerItemRightClick);
		itemRenderer.pool();
	}
	
	private function layerItemReset(itemRenderer:LayerItemRenderer, state:ListViewItemState):Void
	{
		
	}
	
	private function layerItemUpdate(itemRenderer:LayerItemRenderer, state:ListViewItemState):Void
	{
		itemRenderer.layer = state.data;
	}
	
	private function updateHScrollBar():Void
	{
		this._timeLineRulerList.validateNow();
		this._hScrollBar.minimum = this._timeLineRulerList.minScrollX;
		this._hScrollBar.maximum = this._timeLineRulerList.maxScrollX;
	}
	
	private function updateLayerControls():Void
	{
		this._layerRemoveButton.enabled = this._layerList.selectedIndex != -1 && this._container.numLayers > 1;
		this._layerRenameButton.enabled = this._layerList.selectedIndices.length == 1;
		this._layerUpButton.enabled = this._layerList.selectedIndices.indexOf(0) == -1;
		this._layerDownButton.enabled = this._layerList.selectedIndices.indexOf(this._container.numLayers - 1) == -1;
	}
	
	private function updateVScrollBar():Void
	{
		this._vScrollBar.minimum = this._timeLineList.minScrollY;
		this._vScrollBar.maximum = this._timeLineList.maxScrollY;
	}
	
	private function closeFrameContextMenu():Void
	{
		this._framePopupAdapter.close();
		this._frameContextMenu.selectedIndex = -1;
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onFrameContextMenuStageMouseDown);
		this.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onFrameContextMenuStageMouseDown);
	}
	
	private function closeLayerContextMenu():Void
	{
		this._layerPopupAdapter.close();
		this._layerContextMenu.selectedIndex = -1;
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onLayerContextMenuStageMouseDown);
		this.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onLayerContextMenuStageMouseDown);
	}
	
	private function createTimeLineItem(layer:ValEditorLayer, index:Int):Void
	{
		var timeLine:ValEditorTimeLine = cast layer.timeLine;
		var item:TimeLineItem = TimeLineItem.fromPool(layer);
		item.addEventListener(Event.SCROLL, onTimeLineItemScroll);
		item.addEventListener(MouseEvent.RIGHT_CLICK, onTimeLineFrameRightClick);
		this._timeLineItems.insert(index, item);
		this._timeLineList.addChildAt(item, index);
		this._timeLineToItem.set(timeLine, item);
		
		item.scrollX = this._hScrollBar.value;
	}
	
	private function destroyTimeLineItem(item:TimeLineItem):Void
	{
		item.removeEventListener(Event.SCROLL, onTimeLineItemScroll);
		item.removeEventListener(MouseEvent.RIGHT_CLICK, onTimeLineFrameRightClick);
		this._timeLineItems.remove(item);
		this._timeLineList.removeChild(item);
		this._timeLineToItem.remove(item.timeLine);
		item.pool();
	}
	
	private function layerRegister(layer:ValEditorLayer):Void
	{
		layer.addEventListener(LayerEvent.LOCK_CHANGE, onLayerChange);
		layer.addEventListener(LayerEvent.VISIBLE_CHANGE, onLayerChange);
		
		createTimeLineItem(cast layer, this._container.getLayerIndex(layer));
	}
	
	private function layerUnregister(layer:ValEditorLayer):Void
	{
		layer.removeEventListener(LayerEvent.LOCK_CHANGE, onLayerChange);
		layer.removeEventListener(LayerEvent.VISIBLE_CHANGE, onLayerChange);
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
		
		for (i in new ReverseIterator(this._timeLineItems.length - 1, 0))
		{
			destroyTimeLineItem(this._timeLineItems[i]);
		}
		
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
			layerRegister(layer);
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
	
	private function onFrameContextMenuStageMouseDown(evt:MouseEvent):Void
	{
		this._contextMenuPt.setTo(this._frameContextMenu.x, this._frameContextMenu.y);
		var pt:Point = this._frameContextMenu.localToGlobal(this._contextMenuPt);
		this._contextMenuRect.setTo(pt.x, pt.y, this._frameContextMenu.width, this._frameContextMenu.height);
		if (_contextMenuRect.contains(evt.stageX, evt.stageY))
		{
			return;
		}
		
		closeFrameContextMenu();
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
			var layer:ValEditorLayer = ValEditor.createLayer();
			
			var layers:Array<ValEditorLayer> = [layer];
			var action:LayerAdd = LayerAdd.fromPool();
			action.setup(this._container, layers, this._layerList.selectedIndex);
			ValEditor.actionStack.add(action);
		}
	}
	
	private function onLayerAdded(evt:ContainerEvent):Void
	{
		layerRegister(evt.object);
		this._timeLineList.validateNow();
		updateVScrollBar();
		
		updateLayerControls();
	}
	
	private function onLayerChange(evt:LayerEvent):Void
	{
		
	}
	
	private function onLayerDownButton(evt:TriggerEvent):Void
	{
		var action:LayerIndexDown = LayerIndexDown.fromPool();
		var layers:Array<ValEditorLayer> = new Array<ValEditorLayer>();
		for (layer in this._layerList.selectedItems)
		{
			layers.push(layer);
		}
		action.setup(this._container, layers);
		ValEditor.actionStack.add(action);
	}
	
	private function onLayerContextMenuStageMouseDown(evt:MouseEvent):Void
	{
		this._contextMenuPt.setTo(this._layerContextMenu.x, this._layerContextMenu.y);
		var pt:Point = this._layerContextMenu.localToGlobal(this._contextMenuPt);
		this._contextMenuRect.setTo(pt.x, pt.y, this._layerContextMenu.width, this._layerContextMenu.height);
		if (this._contextMenuRect.contains(evt.stageX, evt.stageY))
		{
			return;
		}
		
		closeLayerContextMenu();
	}
	
	private function onLayerItemRightClick(evt:MouseEvent):Void
	{
		var itemRenderer:LayerItemRenderer = evt.currentTarget;
		var clickLayer:ValEditorLayer = itemRenderer.layer;
		
		if (this._layerList.selectedItems.indexOf(clickLayer) == -1)
		{
			this._layerList.selectedItem = clickLayer;
		}
		
		for (layer in this._layerList.selectedItems)
		{
			this._contextSelectedLayers.push(layer);
		}
		this._container.getOtherLayers(this._contextSelectedLayers, this._contextOtherLayers);
		
		var otherLayerUnlocked:Bool = false;
		var otherLayerVisible:Bool = false;
		for (layer in this._contextOtherLayers)
		{
			if (!layer.locked)
			{
				otherLayerUnlocked = true;
				break;
			}
		}
		
		for (layer in this._contextOtherLayers)
		{
			if (layer.visible)
			{
				otherLayerVisible = true;
				break;
			}
		}
		
		// context menu
		this._contextMenuPt.x = evt.stageX;
		this._contextMenuPt.y = evt.stageY;
		this._contextMenuPt = globalToLocal(this._contextMenuPt);
		this._contextMenuSprite.x = this._contextMenuPt.x;
		this._contextMenuSprite.y = this._contextMenuPt.y;
		
		if (this._layerPopupAdapter.active)
		{
			closeLayerContextMenu();
		}
		
		this._removeLayerItem.enabled = this._layerList.selectedItems.length != this._container.numLayers;
		this._showAllLayerItem.enabled = this._container.hasInvisibleLayer;
		this._unlockAllLayerItem.enabled = this._container.hasLockedLayer;
		this._lockOthersLayerItem.enabled = otherLayerUnlocked;
		this._hideOthersLayerItem.enabled = otherLayerVisible;
		this._moveUpLayerItem.enabled = this._layerList.selectedIndices.indexOf(0) == -1;
		this._moveDownLayerItem.enabled = this._layerList.selectedIndices.indexOf(this._container.numLayers - 1) == -1;
		
		this._layerContextMenu.selectedIndex = -1;
		this._layerPopupAdapter.open(this._layerContextMenu, this._contextMenuSprite);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onLayerContextMenuStageMouseDown);
		this.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onLayerContextMenuStageMouseDown);
		
		this._contextSelectedLayers.resize(0);
		this._contextOtherLayers.resize(0);
	}
	
	private function onLayerListChange(evt:Event):Void
	{
		if (this._layerList.selectedIndex != -1)
		{
			this._container.currentLayer = this._container.getLayerAt(this._layerList.selectedIndex);
		}
		updateLayerControls();
	}
	
	private function onLayerListScroll(evt:ScrollEvent):Void
	{
		this._vScrollBar.value = this._layerList.scrollY;
	}
	
	private function onLayerRemoveButton(evt:TriggerEvent):Void
	{
		if (this._layerList.selectedIndex != -1 && this._container.layerCollection.length > 1)
		{
			this._currentTimeLineItem = null;
			
			var action:LayerRemove = LayerRemove.fromPool();
			var layers:Array<ValEditorLayer> = new Array<ValEditorLayer>();
			for (layer in this._layerList.selectedItems)
			{
				layers.push(layer);
			}
			action.setup(this._container, layers);
			ValEditor.actionStack.add(action);
		}
	}
	
	private function onLayerRemoved(evt:ContainerEvent):Void
	{
		var layer:ValEditorLayer = evt.object;
		var timeLineItem:TimeLineItem = this._timeLineToItem.get(cast layer.timeLine);
		destroyTimeLineItem(timeLineItem);
		this._timeLineList.validateNow();
		updateVScrollBar();
		updateLayerControls();
	}
	
	private function onLayerRenameButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showLayerRenameWindow(cast this._container.currentLayer);
	}
	
	private function onLayerSelected(evt:ContainerEvent):Void
	{
		if (this._currentTimeLineItem != null)
		{
			this._currentTimeLineItem.isCurrent = false;
		}
		
		var layer:ValEditorLayer = cast evt.object;
		if (layer == null) return;
		
		var layerIndex:Int = this._container.getLayerIndex(layer);
		this._layerList.selectedIndex = layerIndex;
		
		this._currentTimeLineItem = this._timeLineItems[layerIndex];
		this._currentTimeLineItem.isCurrent = true;
		this._currentTimeLineItem.selectedIndex = layer.timeLine.frameIndex;
	}
	
	private function onLayerUpButton(evt:TriggerEvent):Void
	{
		var action:LayerIndexUp = LayerIndexUp.fromPool();
		var layers:Array<ValEditorLayer> = new Array<ValEditorLayer>();
		for (layer in this._layerList.selectedItems)
		{
			layers.push(layer);
		}
		action.setup(this._container, layers);
		ValEditor.actionStack.add(action);
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
	
	private function onTimeLineFrameRightClick(evt:MouseEvent):Void
	{
		var timeLineItem:TimeLineItem = evt.currentTarget;
		var renderer:BitmapScrollRenderer = evt.target;
		var frameData:FrameData = renderer.frameData;
		timeLineItem.setSelectedFrame(frameData);
		
		// context menu
		this._contextMenuPt.x = evt.stageX;
		this._contextMenuPt.y = evt.stageY;
		this._contextMenuPt = globalToLocal(this._contextMenuPt);
		this._contextMenuSprite.x = this._contextMenuPt.x;
		this._contextMenuSprite.y = this._contextMenuPt.y;
		
		if (this._framePopupAdapter.active)
		{
			closeFrameContextMenu();
		}
		this._removeFrameItem.enabled = frameData.frame != null;
		this._removeKeyFrameItem.enabled = frameData.frame != null && frameData.frame.indexCurrent == frameData.frame.indexStart;
		this._frameContextMenuCollection.updateAt(this._frameContextMenuCollection.indexOf(this._removeFrameItem));
		this._frameContextMenuCollection.updateAt(this._frameContextMenuCollection.indexOf(this._removeKeyFrameItem));
		this._frameContextMenu.selectedIndex = -1;
		this._framePopupAdapter.open(this._frameContextMenu, this._contextMenuSprite);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onFrameContextMenuStageMouseDown);
		this.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onFrameContextMenuStageMouseDown);
	}
	
	private function onTimeLineItemScroll(evt:Event):Void
	{
		var timeLineItem:TimeLineItem = cast evt.target;
		this._hScrollBar.value = timeLineItem.scrollX;
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