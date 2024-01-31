package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class ValueUIEvent extends Event 
{
	inline static public var CHANGE_BEGIN:String = "change_begin";
	inline static public var CHANGE_END:String = "change_end";
	
	#if !flash
	static private var _POOL:Array<ValueUIEvent> = new Array<ValueUIEvent>();
	
	static private function fromPool(type:String, bubbles:Bool, cancelable:Bool):ValueUIEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, bubbles, cancelable);
		return new ValueUIEvent(type, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ValueUIEvent(type, bubbles, cancelable));
		#else
		var event:ValueUIEvent = fromPool(type, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public function new(type:String, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ValueUIEvent(this.type, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	private function pool():Void
	{
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(type:String, bubbles:Bool, cancelable:Bool):ValueUIEvent
	{
		this.type = type;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}