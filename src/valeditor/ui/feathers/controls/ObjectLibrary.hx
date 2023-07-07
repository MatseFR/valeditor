package valeditor.ui.feathers.controls;

import feathers.controls.Button;
import feathers.controls.GridView;
import feathers.controls.GridViewColumn;
import feathers.controls.LayoutGroup;
import feathers.data.ArrayCollection;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import openfl.events.Event;
import openfl.events.FocusEvent;
import openfl.events.KeyboardEvent;
import openfl.ui.Keyboard;
import valeditor.ValEditor;
import valeditor.events.EditorEvent;
import valeditor.events.SelectionEvent;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;

/**
 * ...
 * @author Matse
 */
class ObjectLibrary extends LayoutGroup 
{
	private var _grid:GridView;
	private var _footer:LayoutGroup;
	
	private var _objectAddButton:Button;
	private var _objectRemoveButton:Button;
	private var _objectRenameButton:Button;

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
		this._footer.variant = LayoutGroup.VARIANT_TOOL_BAR;
		this._footer.layoutData = new AnchorLayoutData(null, 0, 0, 0);
		hLayout = new HorizontalLayout();
		hLayout.horizontalAlign = HorizontalAlign.LEFT;
		hLayout.verticalAlign = VerticalAlign.MIDDLE;
		hLayout.setPadding(Padding.DEFAULT);
		hLayout.gap = Spacing.HORIZONTAL_GAP;
		this._footer.layout = hLayout;
		addChild(this._footer);
		
		this._objectAddButton = new Button("+", onObjectAddButton);
		this._footer.addChild(this._objectAddButton);
		
		this._objectRemoveButton = new Button("-", onObjectRemoveButton);
		this._objectRemoveButton.enabled = false;
		this._footer.addChild(this._objectRemoveButton);
		
		this._objectRenameButton = new Button("A", onObjectRenameButton);
		this._objectRenameButton.enabled = false;
		this._footer.addChild(this._objectRenameButton);
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			new GridViewColumn("id", (item)->cast(item, ValEditorObject).id),
			new GridViewColumn("class", (item)->item.className)
		]);
		
		this._grid = new GridView(null, columns, onGridChange);
		this._grid.addEventListener(KeyboardEvent.KEY_DOWN, onGridKeyDown);
		this._grid.addEventListener(KeyboardEvent.KEY_UP, onGridKeyUp);
		this._grid.addEventListener(FocusEvent.FOCUS_IN, onGridFocusIn);
		this._grid.addEventListener(FocusEvent.FOCUS_OUT, onGridFocusOut);
		this._grid.variant = GridView.VARIANT_BORDERLESS;
		this._grid.allowMultipleSelection = true;
		this._grid.resizableColumns = true;
		this._grid.sortableColumns = true;
		this._grid.layoutData = new AnchorLayoutData(0, 0, new Anchor(0, this._footer), 0);
		addChild(this._grid);
		
		if (ValEditor.currentContainer != null)
		{
			this._grid.dataProvider = ValEditor.currentContainer.objectCollection;
		}
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
		ValEditor.addEventListener(EditorEvent.CONTAINER_OPEN, onEditorContainerOpen);
	}
	
	private function onEditorContainerOpen(evt:EditorEvent):Void
	{
		this._grid.dataProvider = evt.object.objectCollection;
	}
	
	private function onObjectAddButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showObjectCreationWindow();
	}
	
	private function onObjectRemoveButton(evt:TriggerEvent):Void
	{
		var objectsToRemove:Array<Dynamic> = this._grid.selectedItems.copy();
		for (object in objectsToRemove)
		{
			ValEditor.destroyObject(object);
		}
	}
	
	private function onObjectRenameButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showObjectRenameWindow(this._grid.selectedItem);
	}
	
	private var _objectsToRemove:Array<ValEditorObject> = new Array<ValEditorObject>();
	private function onGridChange(evt:Event):Void
	{
		if (this._grid.selectedItems.length != 0)
		{
			ValEditor.selection.removeEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
			
			var selection:Dynamic = ValEditor.selection.object;
			if (Std.isOfType(selection, ValEditorObject))
			{
				if (this._grid.selectedItems.indexOf(selection) == -1)
				{
					ValEditor.selection.removeObject(selection);
				}
			}
			else if (Std.isOfType(selection, ValEditorObjectGroup))
			{
				var group:ValEditorObjectGroup = cast selection;
				for (object in group)
				{
					if (this._grid.selectedItems.indexOf(object) == -1)
					{
						this._objectsToRemove.push(object);
					}
				}
				
				if (this._objectsToRemove.length != 0)
				{
					ValEditor.selection.removeObjects(this._objectsToRemove);
					this._objectsToRemove.resize(0);
				}
			}
			
			for (object in this._grid.selectedItems)
			{
				if (!ValEditor.selection.hasObject(object))
				{
					ValEditor.selection.addObject(object);
				}
			}
			this._objectRemoveButton.enabled = true;
			this._objectRenameButton.enabled = this._grid.selectedItems.length == 1;
			
			ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
		}
		else
		{
			if (Std.isOfType(ValEditor.selection.object, ValEditorObject) || Std.isOfType(ValEditor.selection.object, ValEditorObjectGroup))
			{
				ValEditor.selection.object = null;
			}
			this._objectRemoveButton.enabled = false;
			this._objectRenameButton.enabled = false;
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
					// select all
					var selectedIndices:Array<Int> = [];
					var count:Int = this._grid.dataProvider.length;
					for (i in 0...count)
					{
						selectedIndices[i] = i;
					}
					this._grid.selectedIndices = selectedIndices;
				}
			
			case Keyboard.DELETE, Keyboard.BACKSPACE :
				var objectsToRemove:Array<Dynamic> = this._grid.selectedItems.copy();
				for (object in objectsToRemove)
				{
					ValEditor.destroyObject(object);
				}
		}
		
		evt.stopPropagation();
	}
	
	private function onGridKeyUp(evt:KeyboardEvent):Void
	{
		evt.stopPropagation();
	}
	
	private function onObjectSelectionChange(evt:SelectionEvent):Void
	{
		if (evt.object != null)
		{
			if (Std.isOfType(evt.object, ValEditorObject))
			{
				this._grid.selectedIndex = this._grid.dataProvider.indexOf(evt.object);
			}
			else if (Std.isOfType(evt.object, ValEditorObjectGroup))
			{
				var group:ValEditorObjectGroup = cast evt.object;
				var selectedItems:Array<Dynamic> = [];
				for (object in group)
				{
					selectedItems.push(object);
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