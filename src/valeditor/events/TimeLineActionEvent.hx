package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valeditor.editor.action.MultiAction;

/**
 * ...
 * @author Matse
 */
class TimeLineActionEvent extends Event 
{
	inline static public var INSERT_FRAME:String = "insert_frame";
	inline static public var INSERT_KEYFRAME:String = "insert_keyframe";
	inline static public var REMOVE_FRAME:String = "remove_frame";
	inline static public var REMOVE_KEYFRAME:String = "remove_keyframe";
	
	#if !flash
	static private var _POOL:Array<TimeLineActionEvent> = new Array<TimeLineActionEvent>();
	
	static public function fromPool(type:String, action:MultiAction, bubbles:Bool, cancelable:Bool):TimeLineActionEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, action, bubbles, cancelable);
		return new TimeLineActionEvent(type, action, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, action:MultiAction,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new TimeLineActionEvent(type, action, bubbles, cancelable));
		#else
		var event:TimeLineActionEvent = fromPool(type, action, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var action(default, null):MultiAction;
	
	public function new(type:String, action:MultiAction, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.action = action;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new TimeLineActionEvent(this.type, this.action, this.bubbles, this.cancelable);
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
	
	private function setTo(type:String, action:MultiAction, bubbles:Bool, cancelable:Bool):TimeLineActionEvent
	{
		this.type = type;
		this.action = action;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}