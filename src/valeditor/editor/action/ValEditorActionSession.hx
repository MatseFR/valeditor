package valeditor.editor.action;

import openfl.events.EventDispatcher;
import valeditor.events.ActionStackEvent;

/**
 * ...
 * @author Matse
 */
class ValEditorActionSession extends EventDispatcher 
{
	static private var _POOL:Array<ValEditorActionSession> = new Array<ValEditorActionSession>();
	
	static public function fromPool(?id:String):ValEditorActionSession
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(id);
		return new ValEditorActionSession(id);
	}
	
	static private var ID_INDEX:Int = 0;
	static public function makeID():String
	{
		return "ActionSession" + ID_INDEX++;
	}
	
	public var canRedo(get, never):Bool;
	public var canUndo(get, never):Bool;
	public var hasChanges(get, never):Bool;
	public var id(default, null):String;
	public var lastAction(get, never):ValEditorAction;
	/* Default is 300 */
	public var undoLevels(get, set):Int;
	
	private function get_canRedo():Bool { return this._undoneActions.length != 0; }
	private function get_canUndo():Bool { return this._doneActions.length != 0; }
	private function get_hasChanges():Bool { return this._lastAction != this._lastSavedAction; }
	
	private var _lastAction:ValEditorAction;
	private function get_lastAction():ValEditorAction { return this._lastAction; }
	
	private var _undoLevels:Int = 300;
	private function get_undoLevels():Int { return this._undoLevels; }
	private function set_undoLevels(value:Int):Int
	{
		if (this._undoLevels == value) return value;
		
		this._undoLevels = value;
		limitToUndoLevels();
		
		return this._undoLevels;
	}
	
	private var _doneActions:Array<ValEditorAction> = new Array<ValEditorAction>();
	private var _undoneActions:Array<ValEditorAction> = new Array<ValEditorAction>();
	
	private var _lastSavedAction:ValEditorAction;

	public function new(?id:String) 
	{
		super();
		if (id == null)
		{
			id = makeID();
		}
		this.id = id;
	}
	
	public function clear():Void
	{
		clearActions();
		this._undoLevels = 300;
	}
	
	public function clearActions():Void
	{
		clearDoneActions();
		clearUndoneActions();
		
		this._lastAction = null;
		this._lastSavedAction = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(id:String):ValEditorActionSession
	{
		if (id == null)
		{
			this.id = makeID();
		}
		else
		{
			this.id = id;
		}
		
		return this;
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
	
	private function limitToUndoLevels():Void
	{
		var count:Int = this._doneActions.length;
		if (count > this._undoLevels)
		{
			for (i in this._undoLevels...count)
			{
				this._doneActions[i].pool();
			}
			this._doneActions.resize(this._undoLevels);
		}
	}
	
	/**
	   applies specified action if its status is ValeditorActionStatus.UNDONE and adds it to the "done" stack
	   @param	action
	**/
	public function add(action:ValEditorAction):Void
	{
		if (action.status == ValEditorActionStatus.UNDONE)
		{
			action.apply();
		}
		
		this._doneActions.unshift(action);
		clearUndoneActions();
		limitToUndoLevels();
		this._lastAction = action;
		ActionStackEvent.dispatch(this, ActionStackEvent.CHANGED, this, action);
	}
	
	public function remove(action:ValEditorAction):Void
	{
		var removed:Bool = this._doneActions.remove(action);
		if (!removed) this._undoneActions.remove(action);
		if (this._lastAction == action)
		{
			if (this._doneActions.length != 0)
			{
				this._lastAction = this._doneActions[this._doneActions.length - 1];
			}
			else
			{
				this._lastAction = null;
			}
		}
		if (this._lastSavedAction == action)
		{
			this._lastSavedAction = null;
		}
	}
	
	public function redo():Void
	{
		if (this._undoneActions.length == 0) return;
		var action:ValEditorAction;
		while (true)
		{
			action = this._undoneActions.shift();
			action.apply();
			this._doneActions.unshift(action);
			this._lastAction = action;
			if (action.isStepAction) break;
			if (this._undoneActions.length == 0) break;
		}
		ActionStackEvent.dispatch(this, ActionStackEvent.CHANGED, this);
	}
	
	public function undo():Void
	{
		if (this._doneActions.length == 0) return;
		var action:ValEditorAction;
		while (true)
		{
			action = this._doneActions.shift();
			action.cancel();
			this._undoneActions.unshift(action);
			if (this._doneActions.length != 0)
			{
				this._lastAction = this._doneActions[0];
			}
			else
			{
				this._lastAction = null;
				break;
			}
			if (action.isStepAction) break;
		}
		ActionStackEvent.dispatch(this, ActionStackEvent.CHANGED, this);
	}
	
	public function changesSaved():Void
	{
		this._lastSavedAction = this._lastAction;
	}
	
}