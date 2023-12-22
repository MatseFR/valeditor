package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valeditor.editor.action.ValEditorAction;

/**
 * ...
 * @author Matse
 */
class ActionStackEvent extends Event 
{
	inline static public var CHANGED:String = "changed";
	
	#if !flash
	static private var _POOL:Array<ActionStackEvent> = new Array<ActionStackEvent>();
	
	static private function fromPool(type:String, action:ValEditorAction, bubbles:Bool, cancelable:Bool):ActionStackEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, action, bubbles, cancelable);
		return new ActionStackEvent(type, action, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, action:ValEditorAction = null,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ActionStackEvent(type, action, bubbles, cancelable));
		#else
		var event:ActionStackEvent = fromPool(type, action, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var action(default, null):ValEditorAction;
	
	public function new(type:String, action:ValEditorAction = null, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.action = action;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ActionStackEvent(this.type, this.action, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.action, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	private function pool():Void
	{
		this.action = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(type:String, action:ValEditorAction, bubbles:Bool, cancelable:Bool):ActionStackEvent
	{
		this.type = type;
		this.action = action;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}