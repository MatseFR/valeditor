package valeditor.ui.feathers.controls;

import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.LayoutGroup;
import feathers.controls.ListView;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.controls.popups.CalloutPopUpAdapter;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.data.ListViewItemState;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalListLayout;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import valeditor.ValEditorObject;
import valeditor.ValEditorObjectGroup;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.container.ContainerMakeCurrent;
import valeditor.editor.action.container.ContainerOpen;
import valeditor.editor.action.object.ObjectRemove;
import valeditor.editor.action.object.ObjectRemoveKeyFrame;
import valeditor.editor.action.object.ObjectSelect;
import valeditor.editor.action.object.ObjectUnselect;
import valeditor.editor.action.selection.SelectionClear;
import valeditor.events.SelectionEvent;
import valeditor.ui.feathers.data.MenuItem;
import valeditor.ui.feathers.renderers.MenuItemRenderer;
import valeditor.ui.feathers.variant.ButtonVariant;
import valeditor.ui.feathers.variant.ItemRendererVariant;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
import valeditor.ui.feathers.variant.ListViewVariant;
import valeditor.ui.feathers.variant.SortOrderHeaderRendererVariant;

/**
 * ...
 * @author Matse
 */
class ObjectList extends LayoutGroup 
{
	public var collection(get, set):ArrayCollection<ValEditorObject>;
	public var isGlobal:Bool = false;
	
	private var _collection:ArrayCollection<ValEditorObject>;
	private function get_collection():ArrayCollection<ValEditorObject> { return this._collection; }
	private function set_collection(value:ArrayCollection<ValEditorObject>):ArrayCollection<ValEditorObject>
	{
		this._collection = value;
		if (this._initialized)
		{
			this._grid.dataProvider = this._collection;
		}
		return this._collection;
	}
	
	private var _grid:GridView;
	private var _idColumn:GridViewColumn;
	private var _templateColumn:GridViewColumn;
	private var _classColumn:GridViewColumn;
	private var _footer:LayoutGroup;
	
	private var _objectAddButton:Button;
	private var _objectRemoveButton:Button;
	private var _objectRenameButton:Button;
	private var _objectOpenButton:Button;
	
	private var _contextMenu:ListView;
	private var _contextMenuCollection:ArrayCollection<MenuItem>;
	private var _popupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	private var _contextMenuSprite:Sprite;
	private var _contextMenuPt:Point = new Point();
	
	private var _addObjectMenuItem:MenuItem;
	private var _openObjectMenuItem:MenuItem;
	private var _removeObjectMenuItem:MenuItem;
	private var _renameObjectMenuItem:MenuItem;

	public function new() 
	{
		super();
	}
	
	override function initialize():Void 
	{
		super.initialize();
		
		var hLayout:HorizontalLayout;
		
		this.layout = new AnchorLayout();
		
		this._footer = new LayoutGroup();
		this._footer.variant = LayoutGroupVariant.TOOL_BAR;
		this._footer.layoutData = new AnchorLayoutData(null, 0, 0, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.TOP;
		hLayout.setPadding(Padding.MINIMAL);
		hLayout.gap = Spacing.MINIMAL;
		this._footer.layout = hLayout;
		addChild(this._footer);
		
		this._objectAddButton = new Button(null, onObjectAddButton);
		this._objectAddButton.variant = ButtonVariant.ADD;
		this._objectAddButton.toolTip = "add new object";
		this._objectAddButton.enabled = false;
		this._footer.addChild(this._objectAddButton);
		
		this._objectRemoveButton = new Button(null, onObjectRemoveButton);
		this._objectRemoveButton.variant = ButtonVariant.REMOVE;
		this._objectRemoveButton.toolTip = "remove selected object(s)";
		this._objectRemoveButton.enabled = false;
		this._footer.addChild(this._objectRemoveButton);
		
		this._objectRenameButton = new Button(null, onObjectRenameButton);
		this._objectRenameButton.variant = ButtonVariant.RENAME;
		this._objectRenameButton.toolTip = "rename selected object";
		this._objectRenameButton.enabled = false;
		this._footer.addChild(this._objectRenameButton);
		
		this._objectOpenButton = new Button(null, onObjectOpenButton);
		this._objectOpenButton.variant = ButtonVariant.OPEN;
		this._objectOpenButton.toolTip = "open selected container object";
		this._objectOpenButton.enabled = false;
		this._footer.addChild(this._objectOpenButton);
		
		var recycler = DisplayObjectRecycler.withFunction(()->{
			var renderer:ItemRenderer = new ItemRenderer();
			renderer.variant = ItemRendererVariant.CRAMPED;
			return renderer;
		});
		recycler.update = (renderer:ItemRenderer, state:GridViewCellState) -> {
			renderer.text = cast(state.data, ValEditorObject).objectID;
		};
		this._idColumn = new GridViewColumn("id");
		this._idColumn.cellRendererRecycler = recycler;
		
		recycler = DisplayObjectRecycler.withFunction(()->{
			var renderer:ItemRenderer = new ItemRenderer();
			renderer.variant = ItemRendererVariant.CRAMPED;
			return renderer;
		});
		recycler.update = (renderer:ItemRenderer, state:GridViewCellState) -> {
			var object:ValEditorObject = cast state.data;
			if (object.template != null)
			{
				renderer.text = object.template.id;
			}
			else
			{
				renderer.text = "";
			}
		};
		this._templateColumn = new GridViewColumn("template", 80.0);
		this._templateColumn.cellRendererRecycler = recycler;
		
		recycler = DisplayObjectRecycler.withFunction(()->{
			var renderer:ItemRenderer = new ItemRenderer();
			renderer.variant = ItemRendererVariant.CRAMPED;
			return renderer;
		});
		recycler.update = (renderer:ItemRenderer, state:GridViewCellState) -> {
			//renderer.text = cast(state.data, ValEditorObject).clss.className;
			renderer.text = state.data.clss.className;
		};
		this._classColumn = new GridViewColumn("class");
		this._classColumn.cellRendererRecycler = recycler;
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			this._idColumn,
			this._templateColumn,
			this._classColumn
		]);
		
		this._grid = new GridView(this._collection, columns, onGridChange);
		this._grid.customHeaderRendererVariant = SortOrderHeaderRendererVariant.CRAMPED;
		this._grid.variant = GridView.VARIANT_BORDERLESS;
		this._grid.allowMultipleSelection = true;
		this._grid.resizableColumns = true;
		this._grid.sortableColumns = true;
		this._grid.layoutData = new AnchorLayoutData(0, 0, new Anchor(0, this._footer), 0);
		addChild(this._grid);
		
		this._grid.addEventListener(KeyboardEvent.KEY_DOWN, onGridKeyDown, false, 500);
		this._grid.addEventListener(KeyboardEvent.KEY_UP, onGridKeyUp);
		this._grid.addEventListener(FocusEvent.FOCUS_IN, onGridFocusIn);
		this._grid.addEventListener(FocusEvent.FOCUS_OUT, onGridFocusOut);
		this._grid.addEventListener(MouseEvent.CLICK, onGridMouseClick);
		
		// context menu
		this._addObjectMenuItem = new MenuItem("add", "Add object", false);
		this._openObjectMenuItem = new MenuItem("open", "Open container");
		this._removeObjectMenuItem = new MenuItem("remove", "Remove selected object(s)", true, "Del");
		this._renameObjectMenuItem = new MenuItem("rename", "Rename");
		
		this._contextMenuCollection = new ArrayCollection<MenuItem>([
			this._addObjectMenuItem,
			this._openObjectMenuItem,
			this._removeObjectMenuItem,
			this._renameObjectMenuItem
		]);
		
		var contextRecycler = DisplayObjectRecycler.withFunction(()->{
			return new MenuItemRenderer();
		});
		
		contextRecycler.update = (renderer:MenuItemRenderer, state:ListViewItemState) -> {
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
		this._contextMenu.itemRendererRecycler = contextRecycler;
		this._contextMenu.itemToEnabled = function(item:Dynamic):Bool {
			return item.enabled;
		};
		this._contextMenu.itemToText = function(item:Dynamic):String {
			return item.text;
		};
		
		this._contextMenu.addEventListener(Event.CHANGE, onContextMenuChange);
		this._contextMenu.addEventListener(ListViewEvent.ITEM_TRIGGER, onContextMenuItemTrigger);
		this._grid.addEventListener(MouseEvent.RIGHT_CLICK, onContextMenuRightClick);
		
		this._contextMenuSprite = new Sprite();
		this._contextMenuSprite.mouseEnabled = false;
		this._contextMenuSprite.graphics.beginFill(0xff0000, 0);
		this._contextMenuSprite.graphics.drawRect( -2, -2, 2, 2);
		this._contextMenuSprite.graphics.endFill();
		addChild(this._contextMenuSprite);
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onSelectionChange);
		
		updateSelection(ValEditor.selection.object);
	}
	
	private function closeContextMenu():Void
	{
		this._popupAdapter.close();
		this._contextMenu.selectedIndex = -1;
		this.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onContextMenuStageMouseDown);
		this.stage.removeEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onContextMenuStageMouseDown);
	}
	
	private function onContextMenuChange(evt:Event):Void
	{
		if (this._contextMenu.selectedItem == null) return;
		
		if (!this._contextMenu.selectedItem.enabled) return;
		
		var action:MultiAction;
		var object:ValEditorObject = this._grid.selectedItem;
		
		switch (this._contextMenu.selectedItem.id) 
		{
			case "add" :
				// TODO
			
			case "open" :
				onObjectOpenButton(null);
			
			case "remove" :
				onObjectRemoveButton(null);
			
			case "rename" :
				onObjectRenameButton(null);
		}
	}
	
	private function onContextMenuItemTrigger(evt:ListViewEvent):Void
	{
		if (!evt.state.enabled)
		{
			return;
		}
		closeContextMenu();
	}
	
	private function onContextMenuRightClick(evt:MouseEvent):Void
	{
		var obj:DisplayObject = evt.target;
		var object:ValEditorObject = null;
		while (true)
		{
			if (obj == null) break;
			if (obj is ItemRenderer)
			{
				object = cast(obj, ItemRenderer).data;
				break;
			}
			obj = obj.parent;
		}
		
		if (object != null && this._grid.selectedItems.indexOf(object) == -1)
		{
			var action:MultiAction = MultiAction.fromPool();
			
			var selectionClear:SelectionClear = SelectionClear.fromPool();
			selectionClear.setup(ValEditor.selection);
			action.add(selectionClear);
			
			var objectSelect:ObjectSelect = ObjectSelect.fromPool();
			objectSelect.setup();
			objectSelect.addObject(object);
			action.add(objectSelect);
			
			ValEditor.actionStack.add(action);
		}
		
		this._contextMenuPt.x = evt.stageX;
		this._contextMenuPt.y = evt.stageY;
		this._contextMenuPt = globalToLocal(this._contextMenuPt);
		this._contextMenuSprite.x = this._contextMenuPt.x;
		this._contextMenuSprite.y = this._contextMenuPt.y;
		
		if (this._popupAdapter.active)
		{
			closeContextMenu();
		}
		
		var singleObjectSelected:Bool = this._grid.selectedItems.length == 1;
		var objectSelected:Bool = this._grid.selectedItems.length != 0;
		
		this._openObjectMenuItem.enabled = object != null && Std.isOfType(object.object, IValEditorContainer);
		this._removeObjectMenuItem.enabled = objectSelected;
		this._renameObjectMenuItem.enabled = singleObjectSelected;
		this._contextMenuCollection.updateAll();
		
		this._contextMenu.selectedIndex = -1;
		
		this._popupAdapter.open(this._contextMenu, this._contextMenuSprite);
		this.stage.addEventListener(MouseEvent.MOUSE_DOWN, onContextMenuStageMouseDown);
		this.stage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onContextMenuStageMouseDown);
	}
	
	private function onContextMenuStageMouseDown(evt:MouseEvent):Void
	{
		if (this._contextMenu.parent.hitTestPoint(evt.stageX, evt.stageY))
		{
			return;
		}
		closeContextMenu();
	}
	
	private function onGridChange(evt:Event):Void
	{
		if (this._grid.selectedItems.length != 0)
		{
			this._objectRemoveButton.enabled = true;
			this._objectRenameButton.enabled = this._grid.selectedItems.length == 1;
			this._objectOpenButton.enabled = this._grid.selectedItems.length == 1 && Std.isOfType(cast(this._grid.selectedItem, ValEditorObject).object, IValEditorContainer);
		}
		else
		{
			this._objectRemoveButton.enabled = false;
			this._objectRenameButton.enabled = false;
			this._objectOpenButton.enabled = false;
		}
	}
	
	private function onGridFocusIn(evt:FocusEvent):Void
	{
		this._grid.showFocus(true);
	}
	
	private function onGridFocusOut(evt:FocusEvent):Void
	{
		this._grid.showFocus(false);
	}
	
	private function onGridKeyDown(evt:KeyboardEvent):Void
	{
		var result:Int = this._grid.selectedIndex;
		var selectionChanged:Bool = false;
		
		switch (evt.keyCode)
		{
			case Keyboard.A :
				if (evt.ctrlKey && evt.shiftKey)
				{
					// unselect all
					var objectUnselect:ObjectUnselect = ObjectUnselect.fromPool();
					for (object in this._grid.selectedItems)
					{
						objectUnselect.addObject(object);
					}
					
					if (objectUnselect.numObjects != 0)
					{
						ValEditor.actionStack.add(objectUnselect);
					}
					else
					{
						objectUnselect.pool();
					}
				}
				else if (evt.ctrlKey)
				{
					var objectSelect:ObjectSelect = ObjectSelect.fromPool();
					for (object in this._grid.dataProvider)
					{
						if (!ValEditor.selection.hasObject(object))
						{
							objectSelect.addObject(object);
						}
					}
					
					if (objectSelect.numObjects != 0)
					{
						ValEditor.actionStack.add(objectSelect);
					}
					else
					{
						objectSelect.pool();
					}
				}
			
			case Keyboard.DELETE, Keyboard.BACKSPACE :
				if (this._grid.selectedItems.length != 0)
				{
					onObjectRemoveButton(null);
				}
			
			case Keyboard.ENTER, Keyboard.NUMPAD_ENTER :
				if (this._grid.selectedItems.length == 1 && Std.isOfType(cast(this._grid.selectedItem, ValEditorObject).object, IValEditorContainer))
				{
					onObjectOpenButton(null);
				}
			
			case Keyboard.UP :
				result = result - 1;
				selectionChanged = true;
			
			case Keyboard.DOWN :
				result = result + 1;
				selectionChanged = true;
			
			case Keyboard.LEFT :
				result = result - 1;
				selectionChanged = true;
			
			case Keyboard.RIGHT :
				result = result + 1;
				selectionChanged = true;
			
			case Keyboard.PAGE_UP :
				result = result - 1;
				selectionChanged = true;
			
			case Keyboard.PAGE_DOWN :
				result = result + 1;
				selectionChanged = true;
			
			case Keyboard.HOME :
				result = 0;
				selectionChanged = true;
			
			case Keyboard.END :
				result = this._grid.dataProvider.length - 1;
				selectionChanged = true;
			
			default:
				// no keyboard navigation
		}
		
		if (selectionChanged)
		{
			if (result < 0)
			{
				result = 0;
			}
			else if (result >= this._grid.dataProvider.length)
			{
				result = this._grid.dataProvider.length - 1;
			}
			
			if (result != this._grid.selectedIndex)
			{
				var action:MultiAction = MultiAction.fromPool();
				
				var selectionClear:SelectionClear = SelectionClear.fromPool();
				selectionClear.setup(ValEditor.selection);
				action.add(selectionClear);
				
				var objectSelect:ObjectSelect = ObjectSelect.fromPool();
				objectSelect.setup();
				objectSelect.addObject(this._grid.dataProvider.get(result));
				action.add(objectSelect);
				
				ValEditor.actionStack.add(action);
			}
		}
		
		if (!evt.ctrlKey || (evt.keyCode != Keyboard.Z && evt.keyCode != Keyboard.Y))
		{
			evt.stopPropagation();
		}
		
		evt.preventDefault(); // prevent GridView from reacting
	}
	
	private function onGridKeyUp(evt:KeyboardEvent):Void
	{
		if (!evt.ctrlKey || (evt.keyCode != Keyboard.Z && evt.keyCode != Keyboard.Y))
		{
			evt.stopPropagation();
		}
	}
	
	private function onGridMouseClick(evt:MouseEvent):Void
	{
		var obj:DisplayObject = evt.target;
		var object:ValEditorObject = null;
		while (true)
		{
			if (obj == null) break;
			if (obj is ItemRenderer)
			{
				object = cast(obj, ItemRenderer).data;
				break;
			}
			obj = obj.parent;
		}
		if (object != null)
		{
			if (evt.ctrlKey || evt.shiftKey)
			{
				if (ValEditor.selection.hasObject(object))
				{
					var objectUnselect:ObjectUnselect = ObjectUnselect.fromPool();
					objectUnselect.setup();
					objectUnselect.addObject(object);
					ValEditor.actionStack.add(objectUnselect);
				}
				else
				{
					var action:MultiAction = MultiAction.fromPool();
					
					if (!Std.isOfType(ValEditor.selection.object, ValEditorObject) && !Std.isOfType(ValEditor.selection.object, ValEditorObjectGroup))
					{
						var selectionClear:SelectionClear = SelectionClear.fromPool();
						selectionClear.setup(ValEditor.selection);
						action.add(selectionClear);
					}
					
					var objectSelect:ObjectSelect = ObjectSelect.fromPool();
					objectSelect.setup();
					objectSelect.addObject(object);
					action.add(objectSelect);
					
					ValEditor.actionStack.add(action);
				}
			}
			else
			{
				if (ValEditor.selection.object != object)
				{
					var action:MultiAction = MultiAction.fromPool();
					
					var selectionClear:SelectionClear = SelectionClear.fromPool();
					selectionClear.setup(ValEditor.selection);
					action.add(selectionClear);
					
					var objectSelect:ObjectSelect = ObjectSelect.fromPool();
					objectSelect.setup();
					objectSelect.addObject(object);
					action.add(objectSelect);
					
					ValEditor.actionStack.add(action);
				}
			}
		}
	}
	
	private function onObjectAddButton(evt:TriggerEvent):Void
	{
		// TODO
	}
	
	private function onObjectOpenButton(evt:TriggerEvent):Void
	{
		var action:MultiAction;
		var selectionClear:SelectionClear;
		var container:ValEditorObject = cast cast(this._grid.selectedItem, ValEditorObject).template.object;
		
		if (cast(container.object, IValEditorContainer).isOpen)
		{
			if (ValEditor.currentContainer != container.object)
			{
				action = MultiAction.fromPool();
				
				selectionClear = SelectionClear.fromPool();
				selectionClear.setup(ValEditor.selection);
				action.add(selectionClear);
				
				var containerMakeCurrent:ContainerMakeCurrent = ContainerMakeCurrent.fromPool();
				containerMakeCurrent.setup(container);
				action.add(containerMakeCurrent);
				
				ValEditor.actionStack.add(action);
			}
		}
		else
		{
			action = MultiAction.fromPool();
			
			selectionClear = SelectionClear.fromPool();
			selectionClear.setup(ValEditor.selection);
			action.add(selectionClear);
			
			var containerOpen:ContainerOpen = ContainerOpen.fromPool();
			containerOpen.setup(container);
			action.add(containerOpen);
			
			ValEditor.actionStack.add(action);
		}
	}
	
	private function onObjectRemoveButton(evt:TriggerEvent):Void
	{
		var action:MultiAction = MultiAction.fromPool();
		
		var selectionClear:SelectionClear = SelectionClear.fromPool();
		selectionClear.setup(ValEditor.selection);
		
		if (Std.isOfType(ValEditor.currentContainer, IValEditorTimeLineContainer))
		{
			var objectRemoveKeyFrame:ObjectRemoveKeyFrame;
			
			if (this.isGlobal)
			{
				for (obj in this._grid.selectedItems)
				{
					for (keyFrame in cast(obj, ValEditorObject).keyFrames)
					{
						objectRemoveKeyFrame = ObjectRemoveKeyFrame.fromPool();
						objectRemoveKeyFrame.setup(obj, cast keyFrame);
						action.add(objectRemoveKeyFrame);
					}
				}
			}
			else
			{
				for (obj in this._grid.selectedItems)
				{
					objectRemoveKeyFrame = ObjectRemoveKeyFrame.fromPool();
					objectRemoveKeyFrame.setup(obj, cast obj.currentKeyFrame);
					action.add(objectRemoveKeyFrame);
				}
			}
		}
		else
		{
			var objectRemove:ObjectRemove;
			
			for (object in this._grid.selectedItems)
			{
				objectRemove = ObjectRemove.fromPool();
				objectRemove.setup(object);
				action.add(objectRemove);
			}
		}
		
		action.addPost(selectionClear);
		
		ValEditor.actionStack.add(action);
	}
	
	private function onObjectRenameButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showObjectRenameWindow(this._grid.selectedItem);
	}
	
	private function onSelectionChange(evt:SelectionEvent):Void
	{
		updateSelection(evt.object);
	}
	
	private function updateSelection(object:Dynamic):Void
	{
		if (object != null)
		{
			if (Std.isOfType(object, ValEditorObject))
			{
				this._grid.selectedIndex = this._grid.dataProvider.indexOf(object);
			}
			else if (Std.isOfType(object, ValEditorObjectGroup))
			{
				var group:ValEditorObjectGroup = cast object;
				var selectedIndices:Array<Int> = [];
				var index:Int;
				for (object in group)
				{
					index = this._grid.dataProvider.indexOf(object);
					if (index != -1)
					{
						selectedIndices.push(index);
					}
				}
				this._grid.selectedIndices = selectedIndices;
			}
			else
			{
				this._grid.selectedIndex = -1;
			}
		}
		else
		{
			this._grid.selectedIndex = -1;
		}
	}
	
}