package valeditor.editor.action;
import openfl.events.EventDispatcher;
import valeditor.events.ActionStackEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorActionStack extends EventDispatcher
{
	public var canRedo(get, never):Bool;
	public var canUndo(get, never):Bool;
	public var hasChanges(get, never):Bool;
	
	private function get_canRedo():Bool { return this._undoneActions.length != 0; }
	private function get_canUndo():Bool { return this._doneActions.length != 0; }
	private function get_hasChanges():Bool { return this._lastAction != this._lastSavedAction; }
	
	private var _doneActions:Array<ValEditorAction> = new Array<ValEditorAction>();
	private var _undoneActions:Array<ValEditorAction> = new Array<ValEditorAction>();
	
	private var _lastAction:ValEditorAction;
	private var _lastSavedAction:ValEditorAction;
	
	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		clearDoneActions();
		clearUndoneActions();
		
		this._lastAction = null;
		this._lastSavedAction = null;
	}
	
	private function clearDoneActions():Void
	{
		for (action in this._doneActions)
		{
			action.pool();
		}
		this._doneActions.resize(0);
	}
	
	private function clearUndoneActions():Void
	{
		for (action in this._undoneActions)
		{
			action.pool();
		}
		this._undoneActions.resize(0);
	}
	
	/**
	   applies specified action and adds it to the "done" stack
	   @param	action
	**/
	public function add(action:ValEditorAction):Void
	{
		action.apply();
		this._doneActions.unshift(action);
		clearUndoneActions();
		this._lastAction = action;
		ActionStackEvent.dispatch(this, ActionStackEvent.CHANGED);
	}
	
	public function redo():Void
	{
		if (this._undoneActions.length == 0) return;
		var action:ValEditorAction = this._undoneActions.shift();
		action.apply();
		this._doneActions.unshift(action);
		this._lastAction = action;
		ActionStackEvent.dispatch(this, ActionStackEvent.CHANGED);
	}
	
	public function undo():Void
	{
		if (this._doneActions.length == 0) return;
		var action:ValEditorAction = this._doneActions.shift();
		action.cancel();
		this._undoneActions.unshift(action);
		if (this._doneActions.length != 0)
		{
			this._lastAction = this._doneActions[0];
		}
		else
		{
			this._lastAction = null;
		}
		ActionStackEvent.dispatch(this, ActionStackEvent.CHANGED);
	}
	
	public function fileSaved():Void
	{
		this._lastSavedAction = this._lastAction;
	}
	
}