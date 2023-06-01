package events;

import openfl.events.Event;
import openfl.events.EventType;
#if !flash
#if (openfl >= "9.1.0")
import openfl.utils.ObjectPool;
#else
import openfl._internal.utils.ObjectPool;
#end
#end
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class SelectionEvent extends Event 
{
	inline static public var CHANGE:EventType<SelectionEvent> = "change";
	
	#if !flash
	static private var _pool:ObjectPool<SelectionEvent> = new ObjectPool<SelectionEvent>(() -> return new SelectionEvent(null, null, false, false), (event) -> {
		event.target = null;
		event.currentTarget = null;
		event.object = null;
		event.__preventDefault = false;
		event.__isCanceled = false;
		event.__isCanceledNow = false;
	});
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:Dynamic, bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		var event:SelectionEvent = new SelectionEvent(type, object, bubbles, cancelable);
		return dispatcher.dispatchEvent(event);
		#else
		var event:SelectionEvent = _pool.get();
		event.type = type;
		event.object = object;
		event.bubbles = bubbles;
		event.cancelable = cancelable;
		var result:Bool = dispatcher.dispatchEvent(event);
		_pool.release(event);
		return result;
		#end
	}
	
	public var object:Dynamic;
	
	public function new(type:String, object:Dynamic, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
	}
	
	override public function clone():Event 
	{
		return new SelectionEvent(this.type, this.object, this.bubbles, this.cancelable);
	}
	
}