package valeditor.events.unused;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valedit.ValEditObject;

/**
 * ...
 * @author Matse
 */
class ObjectEvent extends Event 
{
	inline static public var RENAMED:String = "renamed";
	
	#if !flash
	static private var _POOL:Array<ObjectEvent> = new Array<ObjectEvent>();
	
	static private function fromPool(type:String, object:ValEditObject, bubbles:Bool, cancelable:Bool):ObjectEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, bubbles, cancelable);
		return new ObjectEvent(type, object, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:ValEditObject, parameters:Array<Dynamic> = null,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ObjectEvent(type, object, bubbles, cancelable));
		#else
		var event:ObjectEvent = fromPool(type, object, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var object(default, null):ValEditObject;

	public function new(type:String, object:ValEditObject, bubbles:Bool = false, cancelable:Bool = false) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ObjectEvent(this.type, this.object, this.bubbles, this.cancelable);
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
	
	private function setTo(type:String, object:ValEditObject, bubbles:Bool, cancelable:Bool):ObjectEvent
	{
		this.type = type;
		this.object = object;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}