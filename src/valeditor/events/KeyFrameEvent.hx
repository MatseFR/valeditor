package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valedit.ValEditObject;

/**
 * ...
 * @author Matse
 */
class KeyFrameEvent extends Event 
{
	inline static public var OBJECT_ADDED:String = "object_added";
	inline static public var OBJECT_REMOVED:String = "object_removed";
	#if valeditor
	inline static public var TRANSITION_CHANGE:String = "transition_change";
	inline static public var TWEEN_CHANGE:String = "tween_change";
	inline static public var STATE_CHANGE:String = "state_change";
	#end
	
	#if !flash
	static private var _POOL:Array<KeyFrameEvent> = new Array<KeyFrameEvent>();
	
	static private function fromPool(type:String, object:ValEditObject, bubbles:Bool, cancelable:Bool):KeyFrameEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, bubbles, cancelable);
		return new KeyFrameEvent(type, object, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:ValEditObject = null,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new KeyFrameEvent(type, object, bubbles, cancelable));
		#else
		var event:KeyFrameEvent = fromPool(type, object, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var object(default, null):ValEditObject;
	
	public function new(type:String, object:ValEditObject, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new KeyFrameEvent(this.type, this.object, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.object, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	private function pool():Void
	{
		this.object = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(type:String, object:ValEditObject, bubbles:Bool, cancelable:Bool):KeyFrameEvent
	{
		this.type = type;
		this.object = object;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}