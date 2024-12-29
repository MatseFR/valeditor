package valeditor.events;
import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class LoadEvent extends Event
{
	inline static public var COMPLETE:String = "complete";
	
	#if !flash
	static private var _POOL:Array<LoadEvent> = new Array<LoadEvent>();
	
	static private function fromPool(type:String, bubbles:Bool, cancelable:Bool):LoadEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, bubbles, cancelable);
		return new LoadEvent(type, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new LoadEvent(type, bubbles, cancelable));
		#else
		var event:LoadEvent = fromPool(type, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) 
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone():Event 
	{
		#if flash
		return new LoadEvent(this.type, this.bubbles, this.cancelable);
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
	
	private function setTo(type:String, bubbles:Bool, cancelable:Bool):LoadEvent
	{
		this.type = type;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}