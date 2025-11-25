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
import feathers.layout.AnchorLayout.Anchor;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
import feathers.layout.VerticalLayoutData;
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import valeditor.ui.feathers.controls.ToggleLayoutGroup;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.renderers.MenuItemRenderer;
import valeditor.ui.feathers.theme.variant.LayoutGroupVariant;
import valeditor.ui.feathers.theme.variant.PopUpListViewVariant;

/**
 * ...
 * @author Matse
 */
class SimpleEditViewBase extends LayoutGroup 
{
	public var centerBox(default, null):VDividedBox;
	public var displayAreaGroup(default, null):LayoutGroup;
	public var displayCenter(default, null):Point = new Point();
	public var displayRect(default, null):Rectangle = new Rectangle();
	public var mainBox(default, null):HDividedBox;
	public var menuGroup(default, null):LayoutGroup;
	
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
		
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		
		this.layout = new AnchorLayout();
		
		// menu bar
		this.menuGroup = new LayoutGroup();
		this.menuGroup.variant = LayoutGroupVariant.MENU_BAR;
		this.menuGroup.layoutData = new AnchorLayoutData(0, 0, null, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		hLayout.paddingBottom = 2;
		this.menuGroup.layout = hLayout;
		addChild(this.menuGroup);
		
		for (menuID in this._menuIDList)
		{
			createMenu(menuID);
		}
		
		// main box
		this.mainBox = new HDividedBox();
		this.mainBox.layoutData = new AnchorLayoutData(new Anchor(0, this.menuGroup), 0, 0, 0);
		addChild(this.mainBox);
		
		// left group
		//this.leftGroup = new LayoutGroup();
		//this.leftGroup.variant = LayoutGroupVariant.CONTENT;
		//this.leftGroup.minWidth = UIConfig.VALUE_MIN_WIDTH;
		//this.leftGroup.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		//this.leftGroup.width = this.leftGroup.minWidth;// + (this.leftGroup.maxWidth - this.leftGroup.minWidth) / 2.0;
		//this.leftGroup.layout = new AnchorLayout();
		//this.mainBox.addChild(this.leftGroup);
		
		// center box
		this.centerBox = new VDividedBox();
		this.mainBox.addChild(this.centerBox);
		
		// display area group
		this.displayAreaGroup = new LayoutGroup();
		this.displayAreaGroup.layoutData = new VerticalLayoutData(100, 100);
		this.centerBox.addChild(this.displayAreaGroup);
		
		this.displayAreaGroup.addEventListener(Event.RESIZE, onDisplayAreaResize);
	}
	
	private function createEditContainer_toggleGroup():ToggleLayoutGroup
	{
		var editContainer:ToggleLayoutGroup = new ToggleLayoutGroup();
		return editContainer;
	}
	
	private function createEditContainer_scroll():ScrollContainer
	{
		var editContainer:ScrollContainer = new ScrollContainer();
		//editContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		editContainer.scrollPolicyX = ScrollPolicy.OFF;
		editContainer.scrollPolicyY = ScrollPolicy.ON;
		editContainer.fixedScrollBars = true;
		var vLayout:VerticalLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = vLayout.paddingTop = Spacing.DEFAULT;
		editContainer.layout = vLayout;
		return editContainer;
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
		this.menuGroup.addChild(menu);
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
		var displayX:Float = this.x + this.mainBox.x;
		var displayY:Float = this.y + this.mainBox.y;
		this.displayCenter.setTo(displayX + this.displayAreaGroup.width / 2.0, displayY + this.displayAreaGroup.height / 2.0);
		this.displayRect.setTo(displayX, displayY, this.displayAreaGroup.width, this.displayAreaGroup.height);
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
	
}