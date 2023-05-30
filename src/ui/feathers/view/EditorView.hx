package ui.feathers.view;

import editor.MouseController;
import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.PopUpListView;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.controls.VDividedBox;
import feathers.controls.navigators.TabItem;
import feathers.controls.navigators.TabNavigator;
import feathers.data.ArrayCollection;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import openfl.events.Event;
import openfl.events.MouseEvent;
import ui.feathers.Spacing;
import ui.feathers.controls.SelectionInfo;
import ui.feathers.controls.ObjectLibrary;
import ui.feathers.controls.TemplateLibrary;
import ui.feathers.controls.ToggleLayoutGroup;
import ui.feathers.variant.LayoutGroupVariant;
import ui.feathers.variant.ToggleButtonVariant;

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
	private var _objectLibGroup:ToggleLayoutGroup;
	private var _libNavigator:TabNavigator;
	private var _objectLib:ObjectLibrary;
	private var _templateLib:TemplateLibrary;
	
	// center content
	private var _displayArea:LayoutGroup;
	
	// right content
	private var _objectInfoGroup:ToggleLayoutGroup;
	private var _objectInfo:SelectionInfo;
	private var _propertiesGroup:ToggleLayoutGroup;
	private var _editContainer:ScrollContainer;
	
	// menus
	private var _menuCallbacks:Map<String, Dynamic->Void> = new Map<String, Dynamic->Void>();
	private var _menuCollections:Map<String, ArrayCollection<Dynamic>> = new Map<String, ArrayCollection<Dynamic>>();
	private var _menuIDList:Array<String> = new Array<String>();
	private var _menuIDToItemToEnabled:Map<String, Dynamic->Bool> = new Map<String, Dynamic->Bool>();
	private var _menuIDToItemToText:Map<String, Dynamic->String> = new Map<String, Dynamic->String>();
	private var _menuIDToText:Map<String, String> = new Map<String, String>();
	
	public function new() 
	{
		super();
		initializeNow();
	}
	
	public function addMenu(menuID:String, menuText:String, callback:Dynamic->Void, ?items:Array<Dynamic>, ?itemToText:Dynamic->String, ?itemToEnabled:Dynamic->Bool):Void
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
		
		var collection:ArrayCollection<Dynamic> = new ArrayCollection<Dynamic>(items);
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
		this._menuBar.addChild(menu);
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		var vLayout:VerticalLayout;
		
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
		this._leftBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._leftBox);
		
		this._leftBox.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverUI);
		this._leftBox.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutUI);
		
		this._centerBox = new VDividedBox();
		this._mainBox.addChild(this._centerBox);
		
		this._rightBox = new LayoutGroup();
		this._rightBox.minWidth = UIConfig.VALUE_MIN_WIDTH;
		this._rightBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._rightBox);
		
		this._rightBox.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverUI);
		this._rightBox.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutUI);
		
		// left content
		this._objectLibGroup = new ToggleLayoutGroup();
		this._objectLibGroup.toggleVariant = ToggleButtonVariant.PANEL;
		this._objectLibGroup.contentVariant = LayoutGroupVariant.CONTENT;
		this._objectLibGroup.text = "Library";
		this._objectLibGroup.isOpen = true;
		this._objectLibGroup.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this._objectLibGroup.contentLayout = new AnchorLayout();
		this._leftBox.addChild(this._objectLibGroup);
		
		this._objectLib = new ObjectLibrary();
		this._templateLib = new TemplateLibrary();
		
		var views:ArrayCollection<TabItem> = new ArrayCollection<TabItem>([
			TabItem.withDisplayObject("Objects", this._objectLib),
			TabItem.withDisplayObject("Templates", this._templateLib)
		]);
		
		this._libNavigator = new TabNavigator(views);
		this._libNavigator.layoutData = new AnchorLayoutData(Padding.MINIMAL, 0, 0, 0);
		this._objectLibGroup.addContent(this._libNavigator);
		//this._objectLib.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		////this._objectLib.minWidth = UIConfig.LEFT_MIN_WIDTH;
		////this._objectLib.maxWidth = UIConfig.LEFT_MAX_WIDTH;
		////this._leftBox.addChild(this._objectLib);
		//this._objectLibGroup.addContent(this._objectLib);
		
		
		// center content
		this._displayArea = new LayoutGroup();
		//this._displayArea.variant = LayoutGroupVariant.SCENE;
		this._displayArea.addEventListener(Event.RESIZE, onDisplayAreaResize);
		//this._displayArea.minWidth = UIConfig.CENTER_MIN_WIDTH;
		this._centerBox.addChild(this._displayArea);
		
		//this._displayArea.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverScene);
		
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
		//this._editContainer.minWidth = UIConfig.VALUE_MIN_WIDTH;
		//this._editContainer.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		//this._editContainer.width = UIConfig.VALUE_MIN_WIDTH + (UIConfig.VALUE_MAX_WIDTH - UIConfig.VALUE_MIN_WIDTH) / 2;
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
		//this._rightBox.addChild(this._editContainer);
		this._propertiesGroup.addContent(this._editContainer);
	}
	
	private function defaultItemToEnabled(item:Dynamic):Bool
	{
		return true;
	}
	
	private function defaultItemToText(item:Dynamic):String
	{
		return item.text;
	}
	
	private function onDisplayAreaResize(evt:Event):Void
	{
		
	}
	
	private function onMenuChange(evt:Event):Void
	{
		var menu:PopUpListView = cast evt.target;
		if (menu.selectedIndex == -1) return;
		var item:Dynamic = menu.selectedItem;
		menu.selectedIndex = -1;
		var callback:Dynamic->Void = this._menuCallbacks.get(menu.name);
		if (callback != null) callback(item);
	}
	
	private function onMouseOutUI(evt:MouseEvent):Void
	{
		//trace("onMouseOutUI");
		MouseController.isMouseOverUI = false;
	}
	
	private function onMouseOverUI(evt:MouseEvent):Void
	{
		//trace("onMouseOverUI");
		MouseController.isMouseOverUI = true;
	}
	
}