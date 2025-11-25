package valeditor.editor.base;

import feathers.layout.AutoSizeMode;
import openfl.display.Sprite;
import valeditor.data.Data;
import valeditor.ui.feathers.view.SimpleEditView;

/**
 * ...
 * @author Matse
 */
class ValEditorSimple extends Sprite 
{
	public var editView(default, null):SimpleEditView;
	
	private var _starter:ValEditorStarter;

	public function new(starter:ValEditorStarter = null) 
	{
		super();
		
		this._starter = starter;
		if (this._starter == null)
		{
			this._starter = new ValEditorStarter();
		}
	}
	
	public function start():Void
	{
		if (this.editView == null)
		{
			this.editView = new SimpleEditView();
			this.editView.autoSizeMode = AutoSizeMode.STAGE;
		}
		
		this._starter.start(ready, exposeData, this.editView, true);
	}
	
	/**
	   Calls valeditor.data.Data.exposeAll()
	   override if needed
	**/
	private function exposeData():Void
	{
		Data.exposeAll();
	}
	
	private function ready():Void 
	{
		this.editView.initializeNow();
		ValEditor.uiContainerDefault = this.editView.editContainer;
		addChild(this.editView);
	}
	
}