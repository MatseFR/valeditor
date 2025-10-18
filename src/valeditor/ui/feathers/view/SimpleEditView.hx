package valeditor.ui.feathers.view;
import feathers.controls.HDividedBox;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.PopUpListView;
import feathers.controls.ScrollContainer;
import feathers.controls.ScrollPolicy;
import feathers.data.ArrayCollection;
import feathers.data.ListViewItemState;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.AutoSizeMode;
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
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.renderers.MenuItemRenderer;
import valeditor.ui.feathers.theme.variant.LayoutGroupVariant;
import valeditor.ui.feathers.theme.variant.PopUpListViewVariant;

/**
 * ...
 * @author Matse
 */
class SimpleEditView extends LayoutGroup
{
	public var displayArea(get, never):LayoutGroup;
	public var displayCenter(default, null):Point = new Point();
	public var displayRect(default, null):Rectangle = new Rectangle();
	public var editContainer(default, null):ScrollContainer;
	
	private function get_displayArea():LayoutGroup { return this._displayAreaBox; }
	
	private var _menuBar:LayoutGroup;
	
	private var _mainBox:HDividedBox;
	private var _displayAreaBox:LayoutGroup;
	private var _rightBox:LayoutGroup;
	
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
		
		this.autoSizeMode = AutoSizeMode.STAGE;
		
		initializeNow();
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
		
		// display area box
		this._displayAreaBox = new LayoutGroup();
		this._displayAreaBox.layoutData = new VerticalLayoutData(100, 100);
		this._mainBox.addChild(this._displayAreaBox);
		
		// right box
		this._rightBox = new LayoutGroup();
		this._rightBox.minWidth = UIConfig.VALUE_MIN_WIDTH;
		this._rightBox.maxWidth = UIConfig.VALUE_MAX_WIDTH;
		this._rightBox.width = this._rightBox.minWidth;// + (this._rightBox.maxWidth - this._rightBox.minWidth) / 2.0;
		this._rightBox.layout = new AnchorLayout();
		this._mainBox.addChild(this._rightBox);
		
		// edit container
		this.editContainer = new ScrollContainer();
		this.editContainer.layoutData = new AnchorLayoutData(0, 0, 0, 0);
		this.editContainer.scrollPolicyX = ScrollPolicy.OFF;
		this.editContainer.scrollPolicyY = ScrollPolicy.ON;
		this.editContainer.fixedScrollBars = true;
		vLayout = new VerticalLayout();
		vLayout.horizontalAlign = HorizontalAlign.JUSTIFY;
		vLayout.verticalAlign = VerticalAlign.TOP;
		vLayout.gap = Spacing.VERTICAL_GAP;
		vLayout.paddingBottom = vLayout.paddingTop = Spacing.DEFAULT;
		this.editContainer.layout = vLayout;
		this._rightBox.addChild(this.editContainer);
		
		this._displayAreaBox.addEventListener(Event.RESIZE, onDisplayAreaResize);
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
	
	private function onDisplayAreaResize(evt:Event):Void
	{
		var displayX:Float = this.x + this._mainBox.x;
		var displayY:Float = this.y + this._mainBox.y;
		this.displayCenter.setTo(displayX + this._displayAreaBox.width / 2.0, displayY + this._displayAreaBox.height / 2.0);
		this.displayRect.setTo(displayX, displayY, this._displayAreaBox.width, this._displayAreaBox.height);
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