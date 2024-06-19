package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class EditorEvent extends Event 
{
	inline static public var CONTAINER_CLOSE:String = "container_close";
	inline static public var CONTAINER_CURRENT:String = "container_current";
	inline static public var CONTAINER_OPEN:String = "container_open";
	
	#if !flash
	static private var _POOL:Array<EditorEvent> = new Array<EditorEvent>();
	
	static private function fromPool(type:String, object:Dynamic, bubbles:Bool, cancelable:Bool):EditorEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, bubbles, cancelable);
		return new EditorEvent(type, object, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:Dynamic,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new EditorEvent(type, object, bubbles, cancelable));
		#else
		var event:EditorEvent = fromPool(type, object, bubbles, cancelable);
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
		return new EditorEvent(this.type, this.object, this.bubbles, this.cancelable);
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
	
	private function setTo(type:String, object:Dynamic, bubbles:Bool, cancelable:Bool):EditorEvent
	{
		this.type = type;
		this.object = object;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}