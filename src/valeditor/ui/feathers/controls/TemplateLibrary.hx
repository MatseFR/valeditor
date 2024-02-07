package valeditor.ui.feathers.controls;

import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.LayoutGroup;
import feathers.controls.dataRenderers.ItemRenderer;
import feathers.data.ArrayCollection;
import feathers.data.GridViewCellState;
import feathers.events.GridViewEvent;
import feathers.events.ListViewEvent;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.utils.DisplayObjectRecycler;
import openfl.display.Bitmap;
import openfl.display.DisplayObject;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
import valeditor.ValEditorTemplate;
import valeditor.ValEditorTemplateGroup;
import valeditor.editor.action.MultiAction;
import valeditor.editor.action.selection.SelectionClear;
import valeditor.editor.action.template.TemplateRemove;
import valeditor.editor.action.template.TemplateSelect;
import valeditor.editor.action.template.TemplateUnselect;
import valeditor.events.SelectionEvent;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valeditor.ui.feathers.variant.ButtonVariant;
import valeditor.ui.feathers.variant.ItemRendererVariant;
import valeditor.ui.feathers.variant.LayoutGroupVariant;
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
			//renderer.text = Std.string(state.data.numInstances);
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
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onSelectionChange);
	}
	
	private function onTemplateAddButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showTemplateCreationWindow();
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
	
	private var _templatesToRemove:Array<ValEditorTemplate> = new Array<ValEditorTemplate>();
	private function onGridChange(evt:Event):Void
	{
		if (this._grid.selectedItems.length != 0)
		{
			//ValEditor.selection.removeEventListener(SelectionEvent.CHANGE, onSelectionChange);
			
			//var selection:Dynamic = ValEditor.selection.object;
			//if (Std.isOfType(selection, ValEditorTemplate))
			//{
				//if (this._grid.selectedItems.indexOf(selection) == -1)
				//{
					//ValEditor.selection.removeTemplate(selection);
				//}
			//}
			//else if (Std.isOfType(selection, ValEditorTemplateGroup))
			//{
				//var group:ValEditorTemplateGroup = cast selection;
				//for (template in group)
				//{
					//if (this._grid.selectedItems.indexOf(template) == -1)
					//{
						//this._templatesToRemove.push(template);
					//}
				//}
				//
				//if (this._templatesToRemove.length != 0)
				//{
					//ValEditor.selection.removeTemplates(this._templatesToRemove);
					//this._templatesToRemove.resize(0);
				//}
			//}
			//
			//for (template in this._grid.selectedItems)
			//{
				//if (!ValEditor.selection.hasTemplate(template))
				//{
					//ValEditor.selection.addTemplate(template);
				//}
			//}
			this._templateRemoveButton.enabled = true;
			this._templateRenameButton.enabled = this._grid.selectedItems.length == 1;
			
			//ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onSelectionChange);
		}
		else
		{
			//if (Std.isOfType(ValEditor.selection.object, ValEditorTemplate) || Std.isOfType(ValEditor.selection.object, ValEditorTemplateGroup))
			//{
				//ValEditor.selection.object = null;
			//}
			this._templateRemoveButton.enabled = false;
			this._templateRenameButton.enabled = false;
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
					this._grid.selectedIndex = -1;
				}
				else if (evt.ctrlKey)
				{
					var selectedIndices:Array<Int> = [];
					var count:Int = this._grid.dataProvider.length;
					for (i in 0...count)
					{
						selectedIndices[i] = i;
					}
					this._grid.selectedIndices = selectedIndices;
				}
			
			case Keyboard.DELETE, Keyboard.BACKSPACE :
				//var templatesToRemove:Array<Dynamic> = this._grid.selectedItems.copy();
				//for (template in templatesToRemove)
				//{
					//ValEditor.destroyTemplate(template);
				//}
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