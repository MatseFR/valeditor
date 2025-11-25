package valeditor.editor.base;

import feathers.layout.AutoSizeMode;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import valeditor.data.Data;
import valeditor.ui.feathers.view.SimpleEditView;

/**
 * ...
 * @author Matse
 */
class ValEditorSimpleStarling extends Sprite 
{
	public var editView(default, null):SimpleEditView;
	
	private var _autoStart:Bool;
	private var _isStarted:Bool = false;
	private var _starter:ValEditorStarter;
	
	public function new(starter:ValEditorStarter = null, autoStart:Bool = true) 
	{
		super();
		
		this._starter = starter;
		if (this._starter == null)
		{
			this._starter = new ValEditorStarter();
		}
		
		this._autoStart = autoStart;
		if (this._autoStart)
		{
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
	}
	
	public function start():Void
	{
		if (this._isStarted) return;
		this._isStarted = true;
		
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
		Starling.current.nativeStage.addChild(this.editView);
	}
	
	private function onAddedToStage(evt:Event):Void
	{
		if (this._autoStart)
		{
			start();
		}
	}
	
}