package valeditor.ui.feathers.controls;

import valeditor.ValEditor;
import valeditor.events.SelectionEvent;
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
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;
import valedit.ValEdit;
import valedit.ValEditObject;
import valedit.ValEditObjectGroup;
import valedit.ValEditTemplate;

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
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			new GridViewColumn("id", (item)->item.id),
			new GridViewColumn("class", (item)->item.className)
		]);
		
		this._grid = new GridView(ValEdit.objectCollection, columns, onGridChange);
		this._grid.allowMultipleSelection = true;
		this._grid.resizableColumns = true;
		this._grid.sortableColumns = true;
		this._grid.layoutData = new AnchorLayoutData(0, 0, new Anchor(0, this._footer), 0);
		addChild(this._grid);
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
	}
	
	private function onObjectAddButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showObjectCreationWindow();
	}
	
	private function onObjectRemoveButton(evt:TriggerEvent):Void
	{
		ValEdit.destroyObject(this._grid.selectedItem);
	}
	
	private var _objectsToRemove:Array<ValEditObject> = new Array<ValEditObject>();
	private function onGridChange(evt:Event):Void
	{
		if (this._grid.selectedItems.length != 0)
		{
			ValEditor.selection.removeEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
			
			var selection:Dynamic = ValEditor.selection.object;
			if (Std.isOfType(selection, ValEditObject))
			{
				if (this._grid.selectedItems.indexOf(selection) == -1)
				{
					ValEditor.selection.removeObject(selection);
				}
			}
			else if (Std.isOfType(selection, ValEditObjectGroup))
			{
				var group:ValEditObjectGroup = cast selection;
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
			
			ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
		}
		else
		{
			if (!Std.isOfType(ValEditor.selection.object, ValEditTemplate))
			{
				ValEditor.selection.object = null;
			}
			this._objectRemoveButton.enabled = false;
		}
	}
	
	private function onObjectSelectionChange(evt:SelectionEvent):Void
	{
		if (evt.object != null)
		{
			if (Std.isOfType(evt.object, ValEditObject))
			{
				this._grid.selectedIndex = this._grid.dataProvider.indexOf(evt.object);
			}
			else if (Std.isOfType(evt.object, ValEditObjectGroup))
			{
				var group:ValEditObjectGroup = cast evt.object;
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