package valeditor.ui.feathers.view;

import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.PopUpListView;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.VDividedBox;
import feathers.controls.popups.CalloutPopUpAdapter;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.events.ListViewEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import valeditor.ui.UIConfig;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ObjectLibrary;
import valeditor.ui.feathers.controls.SelectionInfo;
import valeditor.ui.feathers.controls.TemplateLibrary;
import valeditor.ui.feathers.controls.ToggleLayoutGroup;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.renderers.MenuItemRenderer;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valeditor.ui.feathers.variant.ListViewVariant;
import valeditor.ui.feathers.variant.ToggleButtonVariant;

/**
 * ...
 * @author Matse
 */
class EditorView extends LayoutGroup 
{
	static public inline var ID:String = "editor-view";
	
	public var editContainer(get, never):ScrollContainer;
	private function get_editContainer():ScrollContainer { return this._editContainer; }
	
	private var _menuBar:LayoutGroup;
	
	private var _mainBox:HDividedBox;
	private var _leftBox:LayoutGroup;
	private var _centerBox:VDividedBox;
	private var _rightBox:LayoutGroup;
	
	// left content
	private var _templateLibGroup:ToggleLayoutGroup;
	private var _templateLib:TemplateLibrary;
	private var _objectGroup:ToggleLayoutGroup;
	private var _objectLib:ObjectLibrary;
	
	// center content
	private var _displayArea:LayoutGroup;
	private var _displayRect:Rectangle = new Rectangle();
	private var _scenario:ScenarioView;
	
	// right content
	private var _objectInfoGroup:ToggleLayoutGroup;
	private var _objectInfo:SelectionInfo;
	private var _propertiesGroup:ToggleLayoutGroup;
	private var _editContainer:ScrollContainer;
	
	// menus
	private var _menuCallbacks:Map<String, MenuItem->Void> = new Map<String, MenuItem->Void>();
	private var _menuCollections:Map<String, ArrayCollection<MenuItem>> = new Map<String, ArrayCollection<MenuItem>>();
	private var _menuIDList:Array<String> = new Array<String>();
	private var _menuIDToItemToEnabled:Map<String, Dynamic->Bool> = new Map<String, Dynamic->Bool>();
	private var _menuIDToItemToText:Map<String, Dynamic->String> = new Map<String, Dynamic->String>();
	private var _menuIDToText:Map<String, String> = new Map<String, String>();
	
	private var _isFirstResize:Bool = true;
	
	private var _pt:Point = new Point();
	
	private var _contextMenu:ListView;
	private var _contextMenuCollection:ArrayCollection<MenuItem>;
	private var _popupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	private var _contextMenuSprite:Sprite;
	private var _contextMenuPt:Point = new Point();
	
	private var _copyMenuItem:MenuItem;
	private var _cutMenuItem:MenuItem;
	private var _pasteMenuItem:MenuItem;
	private var _deleteMenuItem:MenuItem;
	private var _selectAllMenuItem:MenuItem;
	private var _unselectAllMenuItem:MenuItem;
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	public function addMenu(menuID:String, menuText:String, callback:Dynamic->Void, items:ArrayCollection<MenuItem>, ?itemToText:Dynamic->String, ?itemToEnabled:Dynamic->Bool):Void
	{
		this._menuIDList.push(menuID);
		this._menuIDToText.set(menuID, menuText);
		this._menuCallbacks.set(menuID, callback);
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
		_menuCollections.get(menuID).add(item);
	}
	
	private function createMenu(menuID:String):Void
	{
		var itemToEnabled:Dynamic->Bool;
		var itemToText:Dynamic->String;
		var collection:ArrayCollection<Dynamic> = this._menuCollections.get(menuID);
		var menu:PopUpListView = new PopUpListView(collection, onMenuChange);
		
		menu.listViewFactory = function():ListView
		{
			var layout:VerticalListLayout = new VerticalListLayout();
			layout.requestedRowCount = collection.length;
			var listView:ListView = new ListView();
			listView.layout = layout;
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
		this._menuBar.layout = hLayout;
		addChild(this._menuBar);
		
		for (menuID in this._menuIDList)
		{
			createMenu(menuID);
		}
		
		this._mainBox = new HDividedBox();
		this._mainBox.layoutData = new AnchorLayoutData(new Anchor(0, this._menuBar), 0, 0, 0);
		addChild(this._mainBox);
		
		this._leftBox = new LayoutGroup();
		this._leftBox.minWidth = UIConfig.LEFT_MIN_WIDTH;
		this._leftBox.maxWidth = UIConfig.LEFT_MAX_WIDTH;
		startWidth = Lib.current.stage.stageWidth / 5;
		this._leftBox.width = startWidth >= this._leftBox.minWidth ? startWidth : this._leftBox.minWidth;
		this._leftBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._leftBox);
		
		this._leftBox.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverUI);
		this._leftBox.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutUI);
		
		this._centerBox = new VDividedBox();
		this._mainBox.addChild(this._centerBox);
		
		this._rightBox = new LayoutGroup();
		this._rightBox.minWidth = UIConfig.VALUE_MIN_WIDTH;
		this._rightBox.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		startWidth = Lib.current.stage.stageWidth / 5;
		this._rightBox.width = startWidth >= this._rightBox.minWidth ? startWidth : this._rightBox.minWidth;
		this._rightBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._rightBox);
		
		this._rightBox.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverUI);
		this._rightBox.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutUI);
		
		// left content
		this._templateLibGroup = new ToggleLayoutGroup();
		this._templateLibGroup.contentVariant = LayoutGroupVariant.CONTENT;
		this._templateLibGroup.toggleVariant = ToggleButtonVariant.PANEL;
		this._templateLibGroup.text = "Library";
		this._templateLibGroup.isOpen = true;
		this._templateLibGroup.layoutData = new AnchorLayoutData(0, 0, new Anchor(0, this._objectGroup), 0);
		this._templateLibGroup.contentLayout = new AnchorLayout();
		this._leftBox.addChild(this._templateLibGroup);
		
		//this._objectLib = new ObjectLibrary();
		this._templateLib = new TemplateLibrary();
		this._templateLib.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._templateLibGroup.addContent(this._templateLib);
		//var views:ArrayCollection<TabItem> = new ArrayCollection<TabItem>([
			//TabItem.withDisplayObject("Objects", this._objectLib),
			//TabItem.withDisplayObject("Templates", this._templateLib)
		//]);
		//
		//this._libNavigator = new TabNavigator(views);
		//this._libNavigator.layoutData = new AnchorLayoutData(Padding.MINIMAL, 0, 0, 0);
		//this._objectLibGroup.addContent(this._libNavigator);
		
		//this._objectGroup = new ToggleLayoutGroup();
		//this._objectGroup.contentVariant = LayoutGroupVariant.CONTENT;
		//this._objectGroup.toggleVariant = ToggleButtonVariant.PANEL;
		//this._objectGroup.text = "Objects";
		//this._objectGroup.isOpen = true;
		
		// center content
		this._displayArea = new LayoutGroup();
		//this._displayArea.variant = LayoutGroupVariant.VIEWPORT_DEBUG;
		this._displayArea.addEventListener(Event.RESIZE, onDisplayAreaResize);
		this._centerBox.addChild(this._displayArea);
		
		this._scenario = new ScenarioView();
		startHeight = Lib.current.stage.stageHeight / 4;
		this._scenario.height = startHeight >= this._scenario.minHeight ? startHeight : this._scenario.minHeight;
		this._centerBox.addChild(this._scenario);
		
		// right content
		this._objectInfoGroup = new ToggleLayoutGroup();
		this._objectInfoGroup.contentVariant = LayoutGroupVariant.CONTENT;
		this._objectInfoGroup.toggleVariant = ToggleButtonVariant.PANEL;
		this._objectInfoGroup.text = "Info";
		this._objectInfoGroup.isOpen = true;
		this._objectInfoGroup.layoutData = new AnchorLayoutData(0, 0, null, 0);
		this._rightBox.addChild(this._objectInfoGroup);
		
		this._objectInfo = new SelectionInfo();
		this._objectInfoGroup.addContent(this._objectInfo);
		
		this._propertiesGroup = new ToggleLayoutGroup();
		this._propertiesGroup.toggleVariant = ToggleButtonVariant.PANEL;
		this._propertiesGroup.text = "Properties";
		this._propertiesGroup.isOpen = true;
		this._propertiesGroup.layoutData = new AnchorLayoutData(new Anchor(0, this._objectInfoGroup), 0, 0, 0);
		this._propertiesGroup.contentLayout = new AnchorLayout();
		this._rightBox.addChild(this._propertiesGroup);
		
		this._editContainer = new ScrollContainer();
		this._editContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._editContainer.scrollPolicyX = ScrollPolicy.OFF;
		this._editContainer.scrollPolicyY = ScrollPolicy.ON;
		this._editContainer.fixedScrollBars = true;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = vLayout.paddingTop = Spacing.DEFAULT;
		this._editContainer.layout = vLayout;
		this._propertiesGroup.addContent(this._editContainer);
		
		this._copyMenuItem = new MenuItem("copy", "Copy", true, "Ctrl+C");
		this._cutMenuItem = new MenuItem("cut", "Cut", true, "Ctrl+X");
		this._pasteMenuItem = new MenuItem("paste", "Paste", true, "Ctrl+V");
		this._deleteMenuItem = new MenuItem("delete", "Delete", true, "Del");
		this._selectAllMenuItem = new MenuItem("select all", "Select all", true, "Ctrl+A");
		this._unselectAllMenuItem = new MenuItem("unselect all", "Unselect all", true, "Ctrl+Shift+A");
		
		this._contextMenuCollection = new ArrayCollection<MenuItem>([
			this._copyMenuItem,
			this._cutMenuItem,
			this._pasteMenuItem,
			this._deleteMenuItem,
			this._selectAllMenuItem,
			this._unselectAllMenuItem
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
		
		this._contextMenu = new ListView(this._contextMenuCollection);
		this._contextMenu.variant = ListViewVariant.CONTEXT_MENU;
		var listLayout:VerticalListLayout = new VerticalListLayout();
		listLayout.requestedRowCount = this._contextMenuCollection.length;
		this._contextMenu.layout = listLayout;
		this._contextMenu.itemRendererRecycler = recycler;
		this._contextMenu.itemToEnabled = function(item:Dynamic):Bool {
			return item.enabled;
		}
		this._contextMenu.itemToText = function(item:Dynamic):String {
			return item.text;
		}
		
		this._contextMenu.addEventListener(Event.CHANGE, onContextMenuChange);
		this._contextMenu.addEventListener(ListViewEvent.ITEM_TRIGGER, onContextMenuItemTrigger);
		Lib.current.stage.addEventListener(MouseEvent.RIGHT_CLICK, onContextMenuStageRightClick);
		
		this._contextMenuSprite = new Sprite();
		this._contextMenuSprite.mouseEnabled = false;
		this._contextMenuSprite.graphics.beginFill(0xff0000, 0);
		this._contextMenuSprite.graphics.drawRect(-2, -2, 2, 2);
		this._contextMenuSprite.graphics.endFill();
		addChild(this._contextMenuSprite);
		
		this.addEventListener(Event.RESIZE, onResize);
	}
	
	private function closeContextMenu():Void
	{
		this._popupAdapter.close();
		this._contextMenu.selectedIndex = -1;
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onContextMenuStageMouseDown);
		this.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onContextMenuStageMouseDown);
	}
	
	private function defaultItemToEnabled(item:Dynamic):Bool
	{
		return item.enabled;
	}
	
	private function defaultItemToText(item:Dynamic):String
	{
		return item.text;
	}
	
	private function onContextMenuChange(evt:Event):Void
	{
		if (this._contextMenu.selectedItem == null) return;
		
		switch (this._contextMenu.selectedItem.id)
		{
			case "copy" :
				ValEditor.copy();
			
			case "cut" :
				ValEditor.cut();
			
			case "paste" :
				ValEditor.paste();
			
			case "delete" :
				ValEditor.delete();
			
			case "select all" :
				ValEditor.selectAll();
			
			case "unselect all" :
				ValEditor.unselectAll();
		}
	}
	
	private function onContextMenuItemTrigger(evt:ListViewEvent):Void
	{
		closeContextMenu();
	}
	
	private function onContextMenuStageRightClick(evt:MouseEvent):Void
	{
		if (FeathersWindows.isWindowOpen) return;
		
		if (ValEditor.currentContainer.ignoreRightClick) return;
		
		if (this._displayRect.contains(evt.stageX, evt.stageY))
		{
			this._contextMenuPt.x = evt.stageX;
			this._contextMenuPt.y = evt.stageY;
			this._contextMenuSprite.x = this._contextMenuPt.x;
			this._contextMenuSprite.y = this._contextMenuPt.y;
			
			if (this._popupAdapter.active)
			{
				closeContextMenu();
			}
			
			var isObjectSelected:Bool = ValEditor.selection.numObjects != 0 && (Std.isOfType(ValEditor.selection.object, ValEditorObject) || Std.isOfType(ValEditor.selection.object, ValEditorObjectGroup));
			var isObjectInClipboard:Bool = ValEditor.clipboard.numObjects != 0 && (Std.isOfType(ValEditor.clipboard.object, ValEditorObject) || Std.isOfType(ValEditor.clipboard.object, ValEditorObjectGroup));
			
			this._copyMenuItem.enabled = isObjectSelected;
			this._cutMenuItem.enabled = isObjectSelected;
			this._pasteMenuItem.enabled = isObjectInClipboard;
			this._deleteMenuItem.enabled = isObjectSelected;
			this._selectAllMenuItem.enabled = true;//ValEditor.currentContainer;
			this._unselectAllMenuItem.enabled = isObjectSelected;
			this._contextMenuCollection.updateAll();
			this._contextMenu.selectedIndex = -1;
			this._popupAdapter.open(this._contextMenu, this._contextMenuSprite);
			this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onContextMenuStageMouseDown);
			this.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onContextMenuStageMouseDown);
		}
	}
	
	private function onContextMenuStageMouseDown(evt:MouseEvent):Void
	{
		if (this._contextMenu.hitTestPoint(evt.stageX, evt.stageY))
		{
			return;
		}
		
		closeContextMenu();
	}
	
	private function onDisplayAreaResize(evt:Event):Void
	{
		this._pt.setTo(this._displayArea.x, this._displayArea.y);
		var loc:Point = this._displayArea.localToGlobal(this._pt);
		this._displayRect.setTo(loc.x, loc.y, this._displayArea.width, this._displayArea.height);
		ValEditor.viewPort.update(loc.x, loc.y, this._displayRect.width, this._displayRect.height);
		
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
		// TODO : not needed ?
	}
	
}