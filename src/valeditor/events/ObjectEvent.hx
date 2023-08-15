package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valedit.ValEditObject;

/**
 * ...
 * @author Matse
 */
class ObjectEvent extends Event 
{
	inline static public var PROPERTY_CHANGE:String = "property_change";
	inline static public var RENAMED:String = "renamed";
	
	#if !flash
	static private var _POOL:Array<ObjectEvent> = new Array<ObjectEvent>();
	
	static private function fromPool(type:String, object:ValEditObject, propertyName:String, bubbles:Bool, cancelable:Bool):ObjectEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, propertyName, bubbles, cancelable);
		return new ObjectEvent(type, object, propertyName, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:ValEditObject, propertyName:String = null,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ObjectEvent(type, object, propertyName, bubbles, cancelable));
		#else
		var event:ObjectEvent = fromPool(type, object, propertyName, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var object(default, null):ValEditObject;
	public var propertyName(default, null):String;

	public function new(type:String, object:ValEditObject, propertyName:String=null, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
		this.propertyName = propertyName;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ObjectEvent(this.type, this.object, this.propertyName, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.object, this.propertyName, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	public function pool():Void
	{
		this.object = null;
		this.propertyName = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(type:String, object:ValEditObject, propertyName:String = null, bubbles:Bool = false, cancelable:Bool = false):ObjectEvent
	{
		this.type = type;
		this.object = object;
		this.propertyName = propertyName;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}