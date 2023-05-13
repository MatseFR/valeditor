package editor.base;
import feathers.controls.navigators.StackItem;
import ui.feathers.view.EditView;
import valedit.ValEdit;

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
		ValEdit.uiContainerDefault = this.editView.valEditContainer;
		
		item = StackItem.withDisplayObject(EditView.ID, this.editView);
		this.screenNavigator.addItem(item);
		
		this.screenNavigator.rootItemID = EditView.ID;
	}
	
}