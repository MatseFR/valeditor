package valeditor.editor.action;
import openfl.errors.Error;
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
	public var currentSession(default, null):ValEditorActionSession;
	public var hasChanges(get, never):Bool;
	public var lastAction(get, never):ValEditorAction;
	public var numSessions(get, never):Int;
	/* -1 means don't affect sessions undoLevels */
	public var undoLevels(get, set):Int;
	
	private function get_canRedo():Bool { return this.currentSession != null ? this.currentSession.canRedo : false; }
	private function get_canUndo():Bool { return this.currentSession != null ? this.currentSession.canUndo : false; }
	private function get_hasChanges():Bool
	{
		for (session in this._sessions)
		{
			if (session.hasChanges) return true;
		}
		return false;
	}
	
	private function get_lastAction():ValEditorAction { return this.currentSession != null ? this.currentSession.lastAction : null; }
	private function get_numSessions():Int { return this._sessions.length; }
	
	private var _undoLevels:Int = -1;
	private function get_undoLevels():Int { return this._undoLevels; }
	private function set_undoLevels(value:Int):Int
	{
		if (this._undoLevels == value) return value;
		
		if (value != -1)
		{
			for (session in this._sessions)
			{
				session.undoLevels = value;
			}
		}
		
		return this._undoLevels = value;
	}
	
	private var _sessions:Array<ValEditorActionSession> = new Array<ValEditorActionSession>();
	private var _sessionsMap:Map<String, ValEditorActionSession> = new Map<String, ValEditorActionSession>();
	
	public function new() 
	{
		super();
	}
	
	public function clear():Void
	{
		clearSessions();
		this._undoLevels = -1;
	}
	
	public function clearSessions():Void
	{
		for (session in this._sessions)
		{
			session.removeEventListener(ActionStackEvent.CHANGED, onSessionEvent);
			session.pool();
		}
		this._sessions.resize(0);
		this._sessionsMap.clear();
		this.currentSession = null;
	}
	
	public function addSession(session:ValEditorActionSession, makeCurrent:Bool = true):Void
	{
		registerSession(session);
		if (makeCurrent || this.currentSession == null)
		{
			this.currentSession = session;
			ActionStackEvent.dispatch(this, ActionStackEvent.SESSION_CHANGED, this.currentSession);
		}
	}
	
	public function removeSession(session:ValEditorActionSession, pool:Bool = true):Void
	{
		if (this._sessionsMap.exists(session.id))
		{
			unregisterSession(session);
			if (this.currentSession == session)
			{
				this.currentSession = getCurrentSession();
				ActionStackEvent.dispatch(this, ActionStackEvent.SESSION_CHANGED, this.currentSession);
			}
			if (pool)
			{
				session.pool();
			}
		}
	}
	
	public function removeSessionByID(id:String, pool:Bool = true):Void
	{
		if (this._sessionsMap.exists(id))
		{
			var session:ValEditorActionSession = this._sessionsMap.get(id);
			this._sessions.remove(session);
			this._sessionsMap.remove(id);
			if (this.currentSession == session)
			{
				this.currentSession = getCurrentSession();
				ActionStackEvent.dispatch(this, ActionStackEvent.SESSION_CHANGED, this.currentSession);
			}
			if (pool)
			{
				session.pool();
			}
		}
	}
	
	public function pushSession(?session:ValEditorActionSession, makeCurrent:Bool = true):ValEditorActionSession
	{
		if (session == null) session = ValEditorActionSession.fromPool();
		registerSession(session);
		if (makeCurrent)
		{
			this.currentSession = session;
		}
		return session;
	}
	
	public function popSession(pool:Bool = true):Void
	{
		var session:ValEditorActionSession = this._sessions.pop();
		unregisterSession(session);
		if (this.currentSession == session)
		{
			this.currentSession = getCurrentSession();
			ActionStackEvent.dispatch(this, ActionStackEvent.SESSION_CHANGED, this.currentSession);
		}
		if (pool)
		{
			session.pool();
		}
	}
	
	private function getCurrentSession(createIfNoneAvailable:Bool = false):ValEditorActionSession
	{
		if (this._sessions.length != 0)
		{
			return this._sessions[this._sessions.length - 1];
		}
		else if (createIfNoneAvailable)
		{
			return pushSession();
		}
		return null;
	}
	
	/**
	   applies specified action if its status is ValeditorActionStatus.UNDONE and adds it to the "done" stack of the current session (if there is no session one is created automatically)
	   @param	action
	**/
	public function add(action:ValEditorAction):Void
	{
		if (this.currentSession == null)
		{
			this.currentSession = getCurrentSession(true);
		}
		this.currentSession.add(action);
	}
	
	public function remove(action:ValEditorAction):Void
	{
		if (this.currentSession != null)
		{
			this.currentSession.remove(action);
		}
	}
	
	public function redo():Void
	{
		if (this.currentSession != null)
		{
			this.currentSession.redo();
		}
	}
	
	public function undo():Void
	{
		if (this.currentSession != null)
		{
			this.currentSession.undo();
		}
	}
	
	public function changesSaved():Void
	{
		for (session in this._sessions)
		{
			session.changesSaved();
		}
	}
	
	private function registerSession(session:ValEditorActionSession):Void
	{
		this._sessions[this._sessions.length] = session;
		this._sessionsMap.set(session.id, session);
		if (this._undoLevels != -1)
		{
			session.undoLevels = this._undoLevels;
		}
		session.addEventListener(ActionStackEvent.CHANGED, onSessionEvent);
	}
	
	private function unregisterSession(session:ValEditorActionSession):Void
	{
		this._sessions.remove(session);
		this._sessionsMap.remove(session.id);
		session.removeEventListener(ActionStackEvent.CHANGED, onSessionEvent);
	}
	
	private function onSessionEvent(evt:ActionStackEvent):Void
	{
		dispatchEvent(evt);
	}
	
}