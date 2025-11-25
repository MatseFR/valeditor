package valeditor.ui.feathers.view;

import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.PopUpListView;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.VDividedBox;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.ListViewEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Rectangle;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.container.ContainerMakeCurrent;
import valeditor.editor.action.selection.SelectionClear;
import valeditor.events.EditorEvent;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.renderers.MenuItemRenderer;
import valeditor.ui.feathers.theme.variant.LayoutGroupVariant;
import valeditor.ui.feathers.theme.variant.ListViewVariant;
import valeditor.ui.feathers.theme.variant.PopUpListViewVariant;

/**
 * ...
 * @author Matse
 */
class EditViewBase extends LayoutGroup 
{
	public var propertiesContainer(get, never):ScrollContainer;
	private function get_propertiesContainer():ScrollContainer { return this._propertiesContainer; }
	
	private var _menuBar:LayoutGroup;
	
	private var _mainBox:HDividedBox;
	private var _leftBox:LayoutGroup;
	private var _centerBox:VDividedBox;
	private var _rightBox:LayoutGroup;
	
	// center content
	private var _sceneGroup:LayoutGroup;
	private var _containerList:ListView;
	private var _displayArea:LayoutGroup;
	private var _displayRect:Rectangle = new Rectangle();
	private var _scenario:ScenarioView;
	
	// right content
	private var _propertiesGroup:LayoutGroup;
	private var _propertiesContainer:ScrollContainer;
	
	// menus
	private var _menuCallbacks:Map<String, MenuItem->Void> = new Map<String, MenuItem->Void>();
	private var _menuCollections:Map<String, ArrayCollection<MenuItem>> = new Map<String, ArrayCollection<MenuItem>>();
	private var _menuIDList:Array<String> = new Array<String>();
	private var _menuIDToItemToEnabled:Map<String, Dynamic->Bool> = new Map<String, Dynamic->Bool>();
	private var _menuIDToItemToText:Map<String, Dynamic->String> = new Map<String, Dynamic->String>();
	private var _menuIDToText:Map<String, String> = new Map<String, String>();
	private var _menuOpenListeners:Map<String, Event->Void> = new Map<String, Event->Void>();

	public function new() 
	{
		super();
		initializeNow();
	}
	
	public function addMenu(menuID:String, menuText:String, callback:Dynamic->Void, openListener:Event->Void, items:ArrayCollection<MenuItem>, ?itemToText:Dynamic->String, ?itemToEnabled:Dynamic->Bool):Void
	{
		this._menuIDList.push(menuID);
		this._menuIDToText.set(menuID, menuText);
		this._menuCallbacks.set(menuID, callback);
		this._menuOpenListeners.set(menuID, openListener);
		if (itemToText != null)
		{
			this._menuIDToItemToText.set(menuID, itemToText);
		}
		if (itemToEnabled != null)
		{
			this._menuIDToItemToEnabled.set(menuID, itemToEnabled);
		}
		
		this._menuCollections.set(menuID, items);
		
		if (this._initialized)
		{
			createMenu(menuID);
		}
	}
	
	public function addMenuItem(menuID:String, item:MenuItem):Void
	{
		this._menuCollections.get(menuID).add(item);
	}
	
	private function createMenu(menuID:String):Void
	{
		var itemToEnabled:Dynamic->Bool;
		var itemToText:Dynamic->String;
		var collection:ArrayCollection<Dynamic> = this._menuCollections.get(menuID);
		var menu:PopUpListView = new PopUpListView(collection, onMenuChange);
		menu.variant = PopUpListViewVariant.MENU;
		
		var openListener:Event->Void = this._menuOpenListeners.get(menuID);
		
		if (openListener != null)
		{
			menu.addEventListener(Event.OPEN, openListener);
		}
		
		menu.listViewFactory = function():ListView
		{
			var layout:VerticalListLayout = new VerticalListLayout();
			layout.requestedRowCount = collection.length;
			var listView:ListView = new ListView();
			listView.layout = layout;
			listView.addEventListener(MouseEvent.CLICK, onMouseEvent);
			listView.addEventListener(MouseEvent.DOUBLE_CLICK, onMouseEvent);
			listView.addEventListener(MouseEvent.MIDDLE_CLICK, onMouseEvent);
			listView.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMouseEvent);
			listView.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMouseEvent);
			listView.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEvent);
			listView.addEventListener(MouseEvent.MOUSE_UP, onMouseEvent);
			listView.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseEvent);
			listView.addEventListener(MouseEvent.RIGHT_CLICK, onMouseEvent);
			listView.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onMouseEvent);
			listView.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onMouseEvent);
			listView.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardEvent);
			listView.addEventListener(KeyboardEvent.KEY_UP, onKeyboardEvent);
			return listView;
		}
		
		menu.name = menuID;
		menu.prompt = this._menuIDToText.get(menuID);
		menu.selectedIndex = -1;
		
		if (this._menuIDToItemToEnabled.exists(menuID))
		{
			itemToEnabled = this._menuIDToItemToEnabled.get(menuID);
		}
		else
		{
			itemToEnabled = defaultItemToEnabled;
		}
		menu.itemToEnabled = itemToEnabled;
		if (this._menuIDToItemToText.exists(menuID))
		{
			itemToText = this._menuIDToItemToText.get(menuID);
		}
		else
		{
			itemToText = defaultItemToText;
		}
		menu.itemToText = itemToText;
		
		var recycler = DisplayObjectRecycler.withFunction(()->{
			return new MenuItemRenderer();
		});
		
		recycler.update = (renderer:MenuItemRenderer, state:ListViewItemState) -> {
			renderer.text = state.data.text;
			renderer.shortcutText = state.data.shortcutText;
			renderer.iconBitmapData = state.data.iconBitmapData;
			renderer.enabled = state.data.enabled;
		};
		menu.itemRendererRecycler = recycler;
		this._menuBar.addChild(menu);
	}
	
	private function defaultItemToEnabled(item:Dynamic):Bool
	{
		return item.enabled;
	}
	
	private function defaultItemToText(item:Dynamic):String
	{
		return item.text;
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
		var startWidth:Float;
		var startHeight:Float;
		
		this.layout = new AnchorLayout();
		
		// menu bar
		this._menuBar = new LayoutGroup();
		this._menuBar.variant = LayoutGroupVariant.MENU_BAR;
		this._menuBar.layoutData = new AnchorLayoutData(0, 0, null, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		hLayout.paddingBottom = 2;
		this._menuBar.layout = hLayout;
		addChild(this._menuBar);
		
		for (menuID in this._menuIDList)
		{
			createMenu(menuID);
		}
		
		// main box
		this._mainBox = new HDividedBox();
		this._mainBox.layoutData = new AnchorLayoutData(new Anchor(0, this._menuBar), 0, 0, 0);
		addChild(this._mainBox);
		
		this._leftBox = new LayoutGroup();
		this._leftBox.variant = LayoutGroupVariant.CONTENT;
		this._leftBox.minWidth = UIConfig.LEFT_MIN_WIDTH;
		this._leftBox.maxWidth = UIConfig.LEFT_MAX_WIDTH;
		startWidth = Lib.current.stage.stageWidth / 5;
		this._leftBox.width = startWidth >= this._leftBox.minWidth ? startWidth : this._leftBox.minWidth;
		this._leftBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._leftBox);
		
		this._leftBox.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverUI);
		this._leftBox.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutUI);
		
		// center box
		this._centerBox = new VDividedBox();
		this._mainBox.addChild(this._centerBox);
		
		// right box
		this._rightBox = new LayoutGroup();
		this._rightBox.minWidth = UIConfig.VALUE_MIN_WIDTH;
		this._rightBox.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		startWidth = Lib.current.stage.stageWidth / 5;
		this._rightBox.width = startWidth >= this._rightBox.minWidth ? startWidth : this._rightBox.minWidth;
		this._rightBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._rightBox);
		
		this._rightBox.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverUI);
		this._rightBox.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutUI);
		
		// center content
		this._sceneGroup = new LayoutGroup();
		startWidth = Lib.current.stage.stageWidth - this._rightBox.width;
		this._sceneGroup.width = startWidth;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		this._sceneGroup.layout = vLayout;
		this._centerBox.addChild(this._sceneGroup);
		
		this._containerList = new ListView(ValEditor.openedContainerCollection);
		this._containerList.variant = ListViewVariant.OPEN_CONTAINERS;
		this._containerList.addEventListener(ListViewEvent.ITEM_TRIGGER, onContainerListItemTrigger);
		this._containerList.itemToText = function(item:Dynamic):String {
			return cast(item, ValEditorObject).objectID;
		};
		this._sceneGroup.addChild(this._containerList);
		
		this._displayArea = new LayoutGroup();
		//this._displayArea.variant = LayoutGroupVariant.VIEWPORT_DEBUG;
		this._displayArea.layoutData = new VerticalLayoutData(null, 100);
		this._displayArea.addEventListener(Event.RESIZE, onDisplayAreaResize);
		this._sceneGroup.addChild(this._displayArea);
		
		this._scenario = new ScenarioView();
		this._scenario.minHeight = UIConfig.SCENARIO_MIN_HEIGHT;
		startHeight = Lib.current.stage.stageHeight / 4;
		this._scenario.height = startHeight >= this._scenario.minHeight ? startHeight : this._scenario.minHeight;
		this._centerBox.addChild(this._scenario);
		
		// right content
		this._propertiesGroup = new LayoutGroup();
		this._propertiesGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._propertiesGroup.layout = new AnchorLayout();
		this._rightBox.addChild(this._propertiesGroup);
		
		this._propertiesContainer = new ScrollContainer();
		this._propertiesContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._propertiesContainer.scrollPolicyX = ScrollPolicy.OFF;
		this._propertiesContainer.scrollPolicyY = ScrollPolicy.ON;
		this._propertiesContainer.fixedScrollBars = true;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = vLayout.paddingTop = Spacing.DEFAULT;
		this._propertiesContainer.layout = vLayout;
		this._propertiesGroup.addChild(this._propertiesContainer);
		
		this.addEventListener(Event.RESIZE, onResize);
		
		ValEditor.addEventListener(EditorEvent.CONTAINER_OPEN, onContainerOpen);
		ValEditor.addEventListener(EditorEvent.CONTAINER_CLOSE, onContainerClose);
	}
	
	private function onContainerOpen(evt:EditorEvent):Void
	{
		this._containerList.selectedIndex = this._containerList.dataProvider.length - 1;
	}
	
	private function onContainerClose(evt:EditorEvent):Void
	{
		this._containerList.selectedIndex = this._containerList.dataProvider.length - 1;
	}
	
	private function onContainerListItemTrigger(evt:ListViewEvent):Void
	{
		var container:ValEditorObject = evt.state.data;
		if (container.object != ValEditor.currentContainer)
		{
			var action:MultiAction = MultiAction.fromPool();
			
			var selectionClear:SelectionClear = SelectionClear.fromPool();
			selectionClear.setup(ValEditor.selection);
			action.add(selectionClear);
			
			var makeCurrent:ContainerMakeCurrent = ContainerMakeCurrent.fromPool();
			makeCurrent.setup(container);
			action.add(makeCurrent);
			
			ValEditor.actionStack.add(action);
		}
	}
	
	private function onDisplayAreaResize(evt:Event):Void
	{
		// when we receive the event, _displayArea has been resized but not re-positionned by the layout so we have to work around this
		this._displayRect.setTo(this._centerBox.x, this._mainBox.y + this._containerList.height, this._displayArea.width, this._displayArea.height);
		ValEditor.viewPort.update(this._displayRect.x, this._displayRect.y, this._displayRect.width, this._displayRect.height);
	}
	
	private function onKeyboardEvent(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onMenuChange(evt:Event):Void
	{
		var menu:PopUpListView = cast evt.target;
		if (menu.selectedIndex == -1) return;
		var item:MenuItem = menu.selectedItem;
		menu.selectedIndex = -1;
		if (!item.enabled) return;
		var callback:MenuItem->Void = this._menuCallbacks.get(menu.name);
		if (callback != null) callback(item);
	}
	
	private function onMouseEvent(evt:MouseEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onMouseOutUI(evt:MouseEvent):Void
	{
		ValEditor.isMouseOverUI = false;
	}
	
	private function onMouseOverUI(evt:MouseEvent):Void
	{
		ValEditor.isMouseOverUI = true;
	}
	
	private function onResize(evt:Event):Void
	{
		this._leftBox.maxWidth = this.width * 0.4;
		this._rightBox.maxWidth = this.width * 0.4;
		this._scenario.maxHeight = this.height * 0.75;
	}
	
}