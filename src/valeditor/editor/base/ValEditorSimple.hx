package valeditor.editor.base;

import feathers.controls.navigators.StackItem;
import valeditor.ui.feathers.view.EditView;

/**
 * ...
 * @author Matse
 */
class ValEditorSimple extends ValEditorBaseFeathers 
{
	public var editView(default, null):EditView;

	public function new() 
	{
		super();
	}
	
	override function ready():Void 
	{
		var item:StackItem;
		
		super.ready();
		
		this.editView = new EditView();
		this.editView.initializeNow();
		ValEditor.uiContainerDefault = this.editView.valEditContainer;
		
		item = StackItem.withDisplayObject(EditView.ID, this.editView);
		this.screenNavigator.addItem(item);
		
		this.screenNavigator.rootItemID = EditView.ID;
	}
	
}