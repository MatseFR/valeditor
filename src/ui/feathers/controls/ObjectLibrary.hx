package ui.feathers.controls;

import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.controls.ScrollContainer;
import feathers.controls.TreeView;
import feathers.events.TriggerEvent;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import feathers.layout.HorizontalAlign;
import feathers.layout.HorizontalLayout;
import feathers.layout.VerticalAlign;
import feathers.layout.VerticalLayout;
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
	private var _tree:TreeView;
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
		
		this._tree = new TreeView(ValEdit.objectCollection, onTreeChange);
		this._tree.layoutData = new AnchorLayoutData(0, 0, new Anchor(0, this._footer), 0);
		this._tree.itemToText = (item:Dynamic) -> item.data.name;
		addChild(this._tree);
	}
	
	private function onObjectAddButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showObjectCreationWindow();
	}
	
	private function onObjectRemoveButton(evt:TriggerEvent):Void
	{
		ValEdit.destroyObject(this._tree.selectedItem.data.object);
	}
	
	private function onTreeChange(evt:Event):Void
	{
		if (this._tree.selectedItem != null && this._tree.selectedItem.data.object != null)
		{
			ValEdit.edit(this._tree.selectedItem.data.object);
			this._objectRemoveButton.enabled = true;
		}
		else
		{
			this._objectRemoveButton.enabled = false;
		}
	}
	
}