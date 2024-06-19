package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class ContainerEvent extends Event 
{
	inline static public var CLOSE:String = "close";
	inline static public var OPEN:String = "open";
	
	inline static public var LAYER_ADDED:String = "layer_added";
	inline static public var LAYER_INDEX_DOWN:String = "layer_index_down";
	inline static public var LAYER_INDEX_UP:String = "layer_index_up";
	inline static public var LAYER_LOCK_CHANGE:String = "layer_lock_change";
	inline static public var LAYER_REMOVED:String = "layer_removed";
	inline static public var LAYER_RENAMED:String = "layer_renamed";
	inline static public var LAYER_SELECTED:String = "layer_selected";
	inline static public var LAYER_VISIBILITY_CHANGE:String = "layer_visibility_change";
	
	inline static public var OBJECT_ADDED:String = "object_added";
	inline static public var OBJECT_REMOVED:String = "object_removed";
	inline static public var OBJECT_ACTIVATED:String = "object_activated";
	inline static public var OBJECT_DEACTIVATED:String = "object_deactivated";
	inline static public var OBJECT_FUNCTION_CALLED:String = "object_function_called";
	inline static public var OBJECT_PROPERTY_CHANGE:String = "object_property_change";
	
	#if !flash
	static private var _POOL:Array<ContainerEvent> = new Array<ContainerEvent>();
	
	static private function fromPool(type:String, object:Dynamic, subEvent:Event, bubbles:Bool, cancelable:Bool):ContainerEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, subEvent, bubbles, cancelable);
		return new ContainerEvent(type, object, subEvent, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:Dynamic = null, subEvent:Event = null,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ContainerEvent(type, object, subEvent, bubbles, cancelable));
		#else
		var event:ContainerEvent = fromPool(type, object, subEvent, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var object(default, null):Dynamic;
	/* Only useful for OBJECT_FUNCTION_CALLED and OBJECT_PROPERTY_CHANGE */
	public var subEvent(default, null):Event;
	
	public function new(type:String, object:Dynamic, subEvent:Event, bubbles:Bool, cancelable:Bool) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
		this.subEvent = subEvent;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ContainerEvent(this.type, this.object, this.subEvent, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.object, this.subEvent, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	private function pool():Void
	{
		this.object = null;
		this.subEvent = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(type:String, object:Dynamic, subEvent:Event, bubbles:Bool, cancelable:Bool):ContainerEvent
	{
		this.type = type;
		this.object = object;
		this.subEvent = subEvent;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}