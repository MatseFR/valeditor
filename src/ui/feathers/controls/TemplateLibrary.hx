package ui.feathers.controls;

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
import ui.feathers.Spacing;
import valedit.ValEdit;

/**
 * ...
 * @author Matse
 */
class TemplateLibrary extends LayoutGroup 
{
	public var _grid:GridView;
	private var _footer:LayoutGroup;
	
	private var _templateAddButton:Button;
	private var _templateRemoveButton:Button;

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
		
		this._templateAddButton = new Button("+", onTemplateAddButton);
		this._footer.addChild(this._templateAddButton);
		
		this._templateRemoveButton = new Button("-", onTemplateRemoveButton);
		this._templateRemoveButton.enabled = false;
		this._footer.addChild(this._templateRemoveButton);
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			new GridViewColumn("name", (item)->item.name),
			new GridViewColumn("class", (item)->item.className),
			new GridViewColumn("instances", (item)->Std.string(item.numInstances))
		]);
		
		this._grid = new GridView(ValEdit.templateCollection, columns, onGridChange);
		this._grid.resizableColumns = true;
		this._grid.sortableColumns = true;
		this._grid.layoutData = new AnchorLayoutData(0, 0, new Anchor(0, this._footer), 0);
		addChild(this._grid);
	}
	
	private function onTemplateAddButton(evt:TriggerEvent):Void
	{
		
	}
	
	private function onTemplateRemoveButton(evt:TriggerEvent):Void
	{
		
	}
	
	private function onGridChange(evt:Event):Void
	{
		if (this._grid.selectedItem != null)
		{
			
			this._templateRemoveButton.enabled = true;
		}
		else
		{
			this._templateRemoveButton.enabled = false;
		}
	}
	
}