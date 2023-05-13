package editor.base;
import feathers.controls.navigators.StackItem;
import ui.feathers.view.EditorView;
import valedit.ValEdit;

/**
 * ...
 * @author Matse
 */
class ValEditorFull extends ValEditorBaseFeathers 
{
	public var editView(default, null):EditorView;

	public function new() 
	{
		super();
	}
	
	override function ready():Void 
	{
		var item:StackItem;
		
		super.ready();
		
		this.editView = new EditorView();
		this.editView.initializeNow();
		ValEdit.uiContainerDefault = this.editView.editContainer;
		
		item = StackItem.withDisplayObject(EditorView.ID, this.editView);
		this.screenNavigator.addItem(item);
		
		this.screenNavigator.rootItemID = EditorView.ID;
	}
	
}