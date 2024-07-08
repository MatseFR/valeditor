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
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.geom.Point;
import openfl.ui.Keyboard;
import valeditor.IValEditorContainer;
import valeditor.ValEditorObject;
import valeditor.ValEditorTemplate;
import valeditor.ValEditorTemplateGroup;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.container.ContainerMakeCurrent;
import valeditor.editor.action.container.ContainerOpen;
import valeditor.editor.action.container.ContainerTemplateOpen;
import valeditor.editor.action.selection.SelectionClear;
import valeditor.editor.action.template.TemplateRemove;
import valeditor.editor.action.template.TemplateSelect;
import valeditor.editor.action.template.TemplateUnselect;
import valeditor.editor.visibility.TemplateVisibilityCollection;
import valeditor.events.SelectionEvent;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
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
class TemplateLibrary extends LayoutGroup 
{
	private var _grid:GridView;
	private var _idColumn:GridViewColumn;
	private var _classColumn:GridViewColumn;
	private var _numInstancesColumn:GridViewColumn;
	private var _footer:LayoutGroup;
	
	private var _templateAddButton:Button;
	private var _templateRemoveButton:Button;
	private var _templateRenameButton:Button;
	private var _templateOpenButton:Button;
	
	private var _contextMenu:ListView;
	private var _contextMenuCollection:ArrayCollection<MenuItem>;
	private var _popupAdapter:CalloutPopUpAdapter = new CalloutPopUpAdapter();
	private var _contextMenuSprite:Sprite;
	private var _contextMenuPt:Point = new Point();
	
	private var _addTemplateMenuItem:MenuItem;
	private var _editTemplateVisibilityMenuItem:MenuItem;
	private var _openTemplateContainerMenuItem:MenuItem;
	private var _removeTemplateMenuItem:MenuItem;
	private var _renameTemplateMenuItem:MenuItem;
	
	private var _templateVisibility:TemplateVisibilityCollection;

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
		
		this._templateAddButton = new Button(null, onTemplateAddButton);
		this._templateAddButton.variant = ButtonVariant.ADD;
		this._templateAddButton.toolTip = "add new template";
		this._footer.addChild(this._templateAddButton);
		
		this._templateRemoveButton = new Button(null, onTemplateRemoveButton);
		this._templateRemoveButton.variant = ButtonVariant.REMOVE;
		this._templateRemoveButton.toolTip = "remove selected template(s)";
		this._templateRemoveButton.enabled = false;
		this._footer.addChild(this._templateRemoveButton);
		
		this._templateRenameButton = new Button(null, onTemplateRenameButton);
		this._templateRenameButton.variant = ButtonVariant.RENAME;
		this._templateRenameButton.toolTip = "rename selected template";
		this._templateRenameButton.enabled = false;
		this._footer.addChild(this._templateRenameButton);
		
		this._templateOpenButton = new Button(null, onTemplateOpenButton);
		this._templateOpenButton.variant = ButtonVariant.OPEN;
		this._templateOpenButton.toolTip = "open selected container template";
		this._templateOpenButton.enabled = false;
		this._footer.addChild(this._templateOpenButton);
		
		var recycler = DisplayObjectRecycler.withFunction(()->{
			var renderer:ItemRenderer = new ItemRenderer();
			renderer.variant = ItemRendererVariant.CRAMPED;
			renderer.icon = new Bitmap();
			return renderer;
		});
		recycler.update = (renderer:ItemRenderer, state:GridViewCellState) -> {
			cast(renderer.icon, Bitmap).bitmapData = state.data.clss.iconBitmapData;
			renderer.text = cast(state.data, ValEditorTemplate).id;
		};
		this._idColumn = new GridViewColumn("id");
		this._idColumn.cellRendererRecycler = recycler;
		
		recycler = DisplayObjectRecycler.withFunction(()->{
			var renderer:ItemRenderer = new ItemRenderer();
			renderer.variant = ItemRendererVariant.CRAMPED;
			return renderer;
		});
		recycler.update = (renderer:ItemRenderer, state:GridViewCellState) -> {
			renderer.text = state.data.clss.className;
		};
		this._classColumn = new GridViewColumn("class", null, 80.0);
		this._classColumn.cellRendererRecycler = recycler;
		
		recycler = DisplayObjectRecycler.withFunction(()->{
			var renderer:ItemRenderer = new ItemRenderer();
			renderer.variant = ItemRendererVariant.CRAMPED;
			return renderer;
		});
		recycler.update = (renderer:ItemRenderer, state:GridViewCellState) -> {
			renderer.text = Std.string(cast(state.data, ValEditorTemplate).numInstances);
		};
		this._numInstancesColumn = new GridViewColumn("#", null, 28.0);
		this._numInstancesColumn.cellRendererRecycler = recycler;
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			this._idColumn,
			this._classColumn,
			this._numInstancesColumn
		]);
		
		this._grid = new GridView(ValEditor.templateCollection, columns, onGridChange);
		this._grid.customHeaderRendererVariant = SortOrderHeaderRendererVariant.CRAMPED;
		this._grid.addEventListener(KeyboardEvent.KEY_DOWN, onGridKeyDown, false, 500);
		this._grid.addEventListener(KeyboardEvent.KEY_UP, onGridKeyUp);
		this._grid.addEventListener(FocusEvent.FOCUS_IN, onGridFocusIn);
		this._grid.addEventListener(FocusEvent.FOCUS_OUT, onGridFocusOut);
		this._grid.variant = GridView.VARIANT_BORDERLESS;
		this._grid.allowMultipleSelection = true;
		this._grid.resizableColumns = true;
		this._grid.sortableColumns = true;
		this._grid.layoutData = new AnchorLayoutData(0, 0, new Anchor(0, this._footer), 0);
		addChild(this._grid);
		
		this._grid.addEventListener(MouseEvent.CLICK, onGridMouseClick);
		this._grid.addEventListener(MouseEvent.MOUSE_DOWN, onGridMouseDown);
		
		// context menu
		this._addTemplateMenuItem = new MenuItem("add", "Add template");
		this._openTemplateContainerMenuItem = new MenuItem("open", "Open container");
		this._removeTemplateMenuItem = new MenuItem("remove", "Remove selected template(s)", true, "Del");
		this._renameTemplateMenuItem = new MenuItem("rename", "Rename");
		this._editTemplateVisibilityMenuItem = new MenuItem("editVisibility", "Edit properties visibility", true);
		
		this._contextMenuCollection = new ArrayCollection<MenuItem>([
			this._addTemplateMenuItem,
			this._openTemplateContainerMenuItem,
			this._removeTemplateMenuItem,
			this._renameTemplateMenuItem,
			this._editTemplateVisibilityMenuItem
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
		//Lib.current.stage.addChild(this._contextMenuSprite);
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onSelectionChange);
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
		var template:ValEditorTemplate = this._grid.selectedItem;
		
		switch (this._contextMenu.selectedItem.id)
		{
			case "add" :
				FeathersWindows.showTemplateCreationWindow(onTemplateCreated);
			
			case "editVisibility" :
				var title:String = template.id + " properties visibility";
				if (template.visibilityCollectionFile != null)
				{
					FeathersWindows.showTemplateVisibilityWindow(template.visibilityCollectionFile, template.visibilityCollectionDefault, title, onTemplateVisibilityEditConfirm, onTemplateVisibilityEditCancel);
				}
				else
				{
					this._templateVisibility = TemplateVisibilityCollection.fromPool();
					template.visibilityCollectionDefault.clone(this._templateVisibility);
					FeathersWindows.showTemplateVisibilityWindow(this._templateVisibility, template.visibilityCollectionDefault, title, onTemplateVisibilityEditConfirm, onTemplateVisibilityEditCancel);
				}
			
			case "open" :
				var container:ValEditorObject = cast template.object;
				if (cast(container.object, IValEditorContainer).isOpen)
				{
					if (ValEditor.currentContainer != container.object)
					{
						var containerMakeCurrent:ContainerMakeCurrent = ContainerMakeCurrent.fromPool();
						containerMakeCurrent.setup(container);
						ValEditor.actionStack.add(containerMakeCurrent);
					}
				}
				else
				{
					var containerOpen:ContainerTemplateOpen = ContainerTemplateOpen.fromPool();
					containerOpen.setup(container);
					ValEditor.actionStack.add(containerOpen);
				}
			
			case "remove" :
				action = MultiAction.fromPool();
				var templateRemove:TemplateRemove;
				
				for (tpl in this._grid.selectedItems)
				{
					templateRemove = TemplateRemove.fromPool();
					templateRemove.setup(tpl);
					action.add(templateRemove);
				}
				ValEditor.actionStack.add(action);
			
			case "rename" :
				onTemplateRenameButton(null);
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
		var object:DisplayObject = evt.target;
		var template:ValEditorTemplate = null;
		while (true)
		{
			if (object == null) break;
			if (object is ItemRenderer)
			{
				template = cast(object, ItemRenderer).data;
				break;
			}
			object = object.parent;
		}
		
		if (template != null && this._grid.selectedItems.indexOf(template) == -1)
		{
			var action:MultiAction = MultiAction.fromPool();
			
			var selectionClear:SelectionClear = SelectionClear.fromPool();
			selectionClear.setup(ValEditor.selection);
			action.add(selectionClear);
			
			var templateSelect:TemplateSelect = TemplateSelect.fromPool();
			templateSelect.setup();
			templateSelect.addTemplate(template);
			action.add(templateSelect);
			
			ValEditor.actionStack.add(templateSelect);
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
		
		var singleTemplateSelected:Bool = this._grid.selectedItems.length == 1;
		var templateSelected:Bool = this._grid.selectedItems.length != 0;
		
		this._openTemplateContainerMenuItem.enabled = template != null && Std.isOfType(template.object.object, IValEditorContainer);
		this._removeTemplateMenuItem.enabled = templateSelected;
		this._renameTemplateMenuItem.enabled = singleTemplateSelected;
		this._editTemplateVisibilityMenuItem.enabled = singleTemplateSelected;
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
	
	private function onTemplateAddButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showTemplateCreationWindow(onTemplateCreated);
	}
	
	private function onTemplateCreated(template:ValEditorTemplate):Void
	{
		if (Std.isOfType(template.object.object, IValEditorContainer))
		{
			var containerOpen:ContainerTemplateOpen = ContainerTemplateOpen.fromPool();
			containerOpen.setup(cast template.object);
			ValEditor.actionStack.add(containerOpen);
		}
	}
	
	private function onTemplateOpenButton(evt:TriggerEvent):Void
	{
		var container:ValEditorObject = cast cast(this._grid.selectedItem, ValEditorTemplate).object;
		if (cast(container.object, IValEditorContainer).isOpen)
		{
			if (ValEditor.currentContainer != container.object)
			{
				var containerMakeCurrent:ContainerMakeCurrent = ContainerMakeCurrent.fromPool();
				containerMakeCurrent.setup(container);
				ValEditor.actionStack.add(containerMakeCurrent);
			}
		}
		else
		{
			var containerOpen:ContainerTemplateOpen = ContainerTemplateOpen.fromPool();
			containerOpen.setup(container);
			ValEditor.actionStack.add(containerOpen);
		}
	}
	
	private function onTemplateRemoveButton(evt:TriggerEvent):Void
	{
		var action:MultiAction = MultiAction.fromPool();
		var templateRemove:TemplateRemove;
		
		for (template in this._grid.selectedItems)
		{
			templateRemove = TemplateRemove.fromPool();
			templateRemove.setup(template);
			action.add(templateRemove);
		}
		ValEditor.actionStack.add(action);
	}
	
	private function onTemplateRenameButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showTemplateRenameWindow(this._grid.selectedItem);
	}
	
	private function onTemplateVisibilityEditCancel():Void
	{
		if (this._templateVisibility != null)
		{
			this._templateVisibility.pool();
			this._templateVisibility = null;
		}
	}
	
	private function onTemplateVisibilityEditConfirm():Void
	{
		var template:ValEditorTemplate = this._grid.selectedItem;
		if (this._templateVisibility != null)
		{
			if (this._templateVisibility.isDifferentFrom(template.visibilityCollectionDefault))
			{
				template.visibilityCollectionFile = this._templateVisibility;
			}
			else
			{
				this._templateVisibility.pool();
			}
			this._templateVisibility = null;
		}
		else
		{
			if (template.visibilityCollectionFile.isDifferentFrom(template.visibilityCollectionDefault))
			{
				// force update
				template.visibilityCollectionFile = template.visibilityCollectionFile;
			}
			else
			{
				template.visibilityCollectionFile.pool();
				template.visibilityCollectionFile = null;
			}
		}
	}
	
	private function onGridChange(evt:Event):Void
	{
		if (this._grid.selectedItems.length != 0)
		{
			this._templateRemoveButton.enabled = true;
			this._templateRenameButton.enabled = this._grid.selectedItems.length == 1;
			this._templateOpenButton.enabled = this._grid.selectedItems.length == 1 && Std.isOfType(cast(this._grid.selectedItem, ValEditorTemplate).object.object, IValEditorContainer);
		}
		else
		{
			this._templateRemoveButton.enabled = false;
			this._templateRenameButton.enabled = false;
			this._templateOpenButton.enabled = false;
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
					var templateUnselect:TemplateUnselect = TemplateUnselect.fromPool();
					for (template in this._grid.selectedItems)
					{
						templateUnselect.addTemplate(template);
					}
					
					if (templateUnselect.numTemplates != 0)
					{
						ValEditor.actionStack.add(templateUnselect);
					}
					else
					{
						templateUnselect.pool();
					}
				}
				else if (evt.ctrlKey)
				{
					var templateSelect:TemplateSelect = TemplateSelect.fromPool();
					for (template in this._grid.dataProvider)
					{
						if (!ValEditor.selection.hasTemplate(template))
						{
							templateSelect.addTemplate(template);
						}
					}
					
					if (templateSelect.numTemplates != 0)
					{
						ValEditor.actionStack.add(templateSelect);
					}
					else
					{
						templateSelect.pool();
					}
				}
			
			case Keyboard.DELETE, Keyboard.BACKSPACE :
				if (this._grid.selectedItems.length != 0)
				{
					var action:MultiAction = MultiAction.fromPool();
					var templateRemove:TemplateRemove;
					
					for (template in this._grid.selectedItems)
					{
						templateRemove = TemplateRemove.fromPool();
						templateRemove.setup(template);
						action.add(templateRemove);
					}
					
					ValEditor.actionStack.add(action);
				}
			
			case Keyboard.ENTER, Keyboard.NUMPAD_ENTER :
				if (this._grid.selectedItems.length == 1)
				{
					var containerOpen:ContainerTemplateOpen = ContainerTemplateOpen.fromPool();
					containerOpen.setup(cast cast(this._grid.selectedItem, ValEditorTemplate).object.object);
					ValEditor.actionStack.add(containerOpen);
				}
			
			case Keyboard.UP:
				result = result - 1;
				selectionChanged = true;
			
			case Keyboard.DOWN:
				result = result + 1;
				selectionChanged = true;
			
			case Keyboard.LEFT:
				result = result - 1;
				selectionChanged = true;
			
			case Keyboard.RIGHT:
				result = result + 1;
				selectionChanged = true;
			
			case Keyboard.PAGE_UP:
				result = result - 1;
				selectionChanged = true;
			
			case Keyboard.PAGE_DOWN:
				result = result + 1;
				selectionChanged = true;
			
			case Keyboard.HOME:
				result = 0;
				selectionChanged = true;
			
			case Keyboard.END:
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
				
				var templateSelect:TemplateSelect = TemplateSelect.fromPool();
				templateSelect.setup();
				templateSelect.addTemplate(this._grid.dataProvider.get(result));
				action.add(templateSelect);
				
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
		var object:DisplayObject = evt.target;
		var template:ValEditorTemplate = null;
		while (true)
		{
			if (object == null) break;
			if (object is ItemRenderer)
			{
				template = cast(object, ItemRenderer).data;
				break;
			}
			object = object.parent;
		}
		if (template != null)
		{
			if (evt.ctrlKey || evt.shiftKey)
			{
				if (ValEditor.selection.hasTemplate(template))
				{
					var templateUnselect:TemplateUnselect = TemplateUnselect.fromPool();
					templateUnselect.setup();
					templateUnselect.addTemplate(template);
					ValEditor.actionStack.add(templateUnselect);
				}
				else
				{
					var action:MultiAction = MultiAction.fromPool();
					
					if (!Std.isOfType(ValEditor.selection.object, ValEditorTemplate) && !Std.isOfType(ValEditor.selection.object, ValEditorTemplateGroup))
					{
						var selectionClear:SelectionClear = SelectionClear.fromPool();
						selectionClear.setup(ValEditor.selection);
						action.add(selectionClear);
					}
					
					var templateSelect:TemplateSelect = TemplateSelect.fromPool();
					templateSelect.setup();
					templateSelect.addTemplate(template);
					action.add(templateSelect);
					
					ValEditor.actionStack.add(action);
				}
			}
			else
			{
				if (ValEditor.selection.object != template)
				{
					var action:MultiAction = MultiAction.fromPool();
					
					var selectionClear:SelectionClear = SelectionClear.fromPool();
					selectionClear.setup(ValEditor.selection);
					action.add(selectionClear);
					
					var templateSelect:TemplateSelect = TemplateSelect.fromPool();
					templateSelect.setup();
					templateSelect.addTemplate(template);
					action.add(templateSelect);
					
					ValEditor.actionStack.add(action);
				}
			}
		}
	}
	
	private function onGridMouseDown(evt:MouseEvent):Void
	{
		var object:DisplayObject = evt.target;
		var template:ValEditorTemplate = null;
		while (true)
		{
			if (object == null) break;
			if (object is ItemRenderer)
			{
				template = cast(object, ItemRenderer).data;
				break;
			}
			object = object.parent;
		}
		if (template != null)
		{
			ValEditor.libraryDragManager.startDrag(template);
		}
	}
	
	private function onSelectionChange(evt:SelectionEvent):Void
	{
		if (evt.object != null)
		{
			if (Std.isOfType(evt.object, ValEditorTemplate))
			{
				this._grid.selectedIndex = this._grid.dataProvider.indexOf(evt.object);
			}
			else if (Std.isOfType(evt.object, ValEditorTemplateGroup))
			{
				var group:ValEditorTemplateGroup = cast evt.object;
				var selectedItems:Array<Dynamic> = [];
				for (template in group)
				{
					selectedItems.push(template);
				}
				this._grid.selectedItems = selectedItems;
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