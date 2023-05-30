package ui.feathers.controls;

import events.SelectionEvent;
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
import ui.feathers.FeathersWindows;
import ui.feathers.Padding;
import ui.feathers.Spacing;
import valedit.ValEdit;

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
		this._grid.resizableColumns = true;
		this._grid.sortableColumns = true;
		this._grid.layoutData = new AnchorLayoutData(0, 0, new Anchor(0, this._footer), 0);
		addChild(this._grid);
		
		ValEdit.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
	}
	
	private function onObjectAddButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showObjectCreationWindow();
	}
	
	private function onObjectRemoveButton(evt:TriggerEvent):Void
	{
		ValEdit.destroyObject(this._grid.selectedItem);
	}
	
	private function onGridChange(evt:Event):Void
	{
		if (this._grid.selectedItem != null)
		{
			ValEdit.edit(this._grid.selectedItem);
			ValEdit.selection.object = this._grid.selectedItem;
			this._objectRemoveButton.enabled = true;
		}
		else
		{
			this._objectRemoveButton.enabled = false;
		}
	}
	
	private function onObjectSelectionChange(evt:SelectionEvent):Void
	{
		if (evt.object != null)
		{
			this._grid.selectedIndex = this._grid.dataProvider.indexOf(evt.object);
		}
		else
		{
			this._grid.selectedIndex = -1;
		}
	}
	
}