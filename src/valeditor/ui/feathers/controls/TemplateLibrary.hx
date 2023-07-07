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
import valeditor.ValEditorTemplate;
import valeditor.ValEditorTemplateGroup;
import valeditor.events.SelectionEvent;
import valeditor.ui.feathers.FeathersWindows;
import valeditor.ui.feathers.Padding;
import valeditor.ui.feathers.Spacing;

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
		
		this._templateRenameButton = new Button("A", onTemplateRenameButton);
		this._templateRenameButton.enabled = false;
		this._footer.addChild(this._templateRenameButton);
		
		var columns:ArrayCollection<GridViewColumn> = new ArrayCollection<GridViewColumn>([
			new GridViewColumn("id", (item)->cast(item, ValEditorTemplate).id),
			new GridViewColumn("class", (item)->item.className),
			new GridViewColumn("#", (item)->Std.string(item.numInstances))
		]);
		
		this._grid = new GridView(ValEditor.templateCollection, columns, onGridChange);
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
		
		ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
	}
	
	private function onTemplateAddButton(evt:TriggerEvent):Void
	{
		FeathersWindows.showTemplateCreationWindow();
	}
	
	private function onTemplateRemoveButton(evt:TriggerEvent):Void
	{
		ValEditor.destroyTemplate(this._grid.selectedItem);
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
			ValEditor.selection.removeEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
			
			var selection:Dynamic = ValEditor.selection.object;
			if (Std.isOfType(selection, ValEditorTemplate))
			{
				if (this._grid.selectedItems.indexOf(selection) == -1)
				{
					ValEditor.selection.removeTemplate(selection);
				}
			}
			else if (Std.isOfType(selection, ValEditorTemplateGroup))
			{
				var group:ValEditorTemplateGroup = cast selection;
				for (template in group)
				{
					if (this._grid.selectedItems.indexOf(template) == -1)
					{
						this._templatesToRemove.push(template);
					}
				}
				
				if (this._templatesToRemove.length != 0)
				{
					ValEditor.selection.removeTemplates(this._templatesToRemove);
					this._templatesToRemove.resize(0);
				}
			}
			
			for (template in this._grid.selectedItems)
			{
				if (!ValEditor.selection.hasTemplate(template))
				{
					ValEditor.selection.addTemplate(template);
				}
			}
			this._templateRemoveButton.enabled = true;
			this._templateRenameButton.enabled = this._grid.selectedItems.length == 1;
			
			ValEditor.selection.addEventListener(SelectionEvent.CHANGE, onObjectSelectionChange);
		}
		else
		{
			if (Std.isOfType(ValEditor.selection.object, ValEditorTemplate) || Std.isOfType(ValEditor.selection.object, ValEditorTemplateGroup))
			{
				ValEditor.selection.object = null;
			}
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
				var templatesToRemove:Array<Dynamic> = this._grid.selectedItems.copy();
				for (template in templatesToRemove)
				{
					ValEditor.destroyTemplate(template);
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