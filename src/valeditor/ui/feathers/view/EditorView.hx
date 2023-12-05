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
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.Lib;
import openfl.events.Event;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import valeditor.ui.UIConfig;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.controls.ObjectLibrary;
import valeditor.ui.feathers.controls.SelectionInfo;
import valeditor.ui.feathers.controls.TemplateLibrary;
import valeditor.ui.feathers.controls.ToggleLayoutGroup;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.renderers.MenuItemRenderer;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
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
	private var _scenario:ScenarioView;
	
	// right content
	private var _objectInfoGroup:ToggleLayoutGroup;
	private var _objectInfo:SelectionInfo;
	private var _propertiesGroup:ToggleLayoutGroup;
	private var _editContainer:ScrollContainer;
	
	// menus
	private var _menuCallbacks:Map<String, Dynamic->Void> = new Map<String, Dynamic->Void>();
	private var _menuCollections:Map<String, ArrayCollection<MenuItem>> = new Map<String, ArrayCollection<MenuItem>>();
	private var _menuIDList:Array<String> = new Array<String>();
	private var _menuIDToItemToEnabled:Map<String, Dynamic->Bool> = new Map<String, Dynamic->Bool>();
	private var _menuIDToItemToText:Map<String, Dynamic->String> = new Map<String, Dynamic->String>();
	private var _menuIDToText:Map<String, String> = new Map<String, String>();
	
	private var _isFirstResize:Bool = true;
	
	private var _pt:Point = new Point();
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	public function addMenu(menuID:String, menuText:String, callback:Dynamic->Void, ?items:Array<MenuItem>, ?itemToText:Dynamic->String, ?itemToEnabled:Dynamic->Bool):Void
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
		
		var collection:ArrayCollection<MenuItem> = new ArrayCollection<MenuItem>(items);
		this._menuCollections.set(menuID, collection);
		
		if (this._initialized)
		{
			createMenu(menuID);
		}
	}
	
	public function addMenuItem(menuID:String, item:Dynamic):Void
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
		//if (this._menuIDToItemToEnabled.exists(menuID))
		//{
			//itemToEnabled = this._menuIDToItemToEnabled.get(menuID);
		//}
		//else
		//{
			//itemToEnabled = defaultItemToEnabled;
		//}
		//menu.itemToEnabled = itemToEnabled;
		//if (this._menuIDToItemToText.exists(menuID))
		//{
			//itemToText = this._menuIDToItemToText.get(menuID);
		//}
		//else
		//{
			//itemToText = defaultItemToText;
		//}
		//menu.itemToText = itemToText;
		menu.itemToEnabled = defaultItemToEnabled;
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
		
		this.addEventListener(Event.RESIZE, onResize);
	}
	
	private function defaultItemToEnabled(item:Dynamic):Bool
	{
		return item.enabled;
	}
	
	private function defaultItemToText(item:Dynamic):String
	{
		return item.text;
	}
	
	private function onDisplayAreaResize(evt:Event):Void
	{
		this._pt.setTo(this._displayArea.x, this._displayArea.y);
		var loc:Point = this._displayArea.localToGlobal(this._pt);
		ValEditor.viewPort.update(loc.x, loc.y, this._displayArea.width, this._displayArea.height);
		
	}
	
	private function onMenuChange(evt:Event):Void
	{
		var menu:PopUpListView = cast evt.target;
		if (menu.selectedIndex == -1) return;
		var item:MenuItem = menu.selectedItem;
		menu.selectedIndex = -1;
		if (!item.enabled) return;
		var callback:Dynamic->Void = this._menuCallbacks.get(menu.name);
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