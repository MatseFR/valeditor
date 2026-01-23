package valeditor.editor.base;

import feathers.core.FocusManager;
import feathers.layout.AutoSizeMode;
import openfl.display.StageScaleMode;
import starling.core.Starling;
import starling.display.Sprite;
import starling.events.Event;
import starling.events.ResizeEvent;
import valeditor.data.Data;
import valeditor.ui.feathers.view.SimpleEditView;
import valeditor.ui.feathers.view.SimpleEditViewBase;

/**
 * ...
 * @author Matse
 */
class ValEditorSimpleStarling extends Sprite 
{
	public var editView(default, null):SimpleEditViewBase;
	
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
		
		FocusManager.addRoot(Starling.current.nativeStage);
		
		Starling.current.nativeStage.scaleMode = StageScaleMode.NO_SCALE;
		Starling.current.nativeStage.stageFocusRect = false;
		Starling.current.stage.addEventListener(ResizeEvent.RESIZE, onStageResize);
		
		if (this.editView == null)
		{
			this.editView = new SimpleEditView();
			this.editView.autoSizeMode = AutoSizeMode.STAGE;
		}
		
		this._starter.start(ready, exposeData, Starling.current.nativeStage, true);
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
		this.editView.displayAreaGroup.addEventListener(openfl.events.Event.RESIZE, onDisplayResize);
		//ValEditor.uiContainerDefault = this.editView.defaultEditContainer;
		Starling.current.nativeStage.addChild(this.editView);
	}
	
	private function onAddedToStage(evt:Event):Void
	{
		if (this._autoStart)
		{
			start();
		}
	}
	
	private function onDisplayResize(evt:openfl.events.Event):Void
	{
		
	}
	
	private function onStageResize(evt:ResizeEvent):Void
	{
		updateViewPort(evt.width, evt.height);
	}
	
	private function updateViewPort(width:Int, height:Int):Void
	{
		var current:Starling = Starling.current;
		var scale:Float = current.contentScaleFactor;
		
		stage.stageWidth = Std.int(width / scale);
		stage.stageHeight = Std.int(height / scale);
		
		current.viewPort.width = width;//stage.stageWidth * scale;
		current.viewPort.height = height;//stage.stageHeight * scale;
	}
	
}