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
	inline static public var LAYER_REMOVED:String = "layer_removed";
	inline static public var LAYER_SELECTED:String = "layer_selected";
	
	#if !flash
	static private var _POOL:Array<ContainerEvent> = new Array<ContainerEvent>();
	
	static private function fromPool(type:String, object:Dynamic, bubbles:Bool, cancelable:Bool):ContainerEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, bubbles, cancelable);
		return new ContainerEvent(type, object, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:Dynamic = null,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ContainerEvent(type, object, bubbles, cancelable));
		#else
		var event:ContainerEvent = fromPool(type, object, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var object(default, null):Dynamic;
	
	public function new(type:String, object:Dynamic, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ContainerEvent(this.type, this.object, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.object, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	public function pool():Void
	{
		this.object = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(type:String, object:Dynamic, bubbles:Bool = false, cancelable:Bool = false):ContainerEvent
	{
		this.type = type;
		this.object = object;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}