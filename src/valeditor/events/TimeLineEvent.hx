package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class TimeLineEvent extends Event 
{
	inline static public var FRAME_INDEX_CHANGE:String = "frame_index_change";
	inline static public var NUM_FRAMES_CHANGE:String = "num_frames_change";
	inline static public var SELECTED_FRAME_INDEX_CHANGE:String = "selected_frame_index_change";
	
	#if !flash
	static private var _POOL:Array<TimeLineEvent> = new Array<TimeLineEvent>();
	
	static private function fromPool(type:String, bubbles:Bool, cancelable:Bool):TimeLineEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, bubbles, cancelable);
		return new TimeLineEvent(type, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new TimeLineEvent(type, bubbles, cancelable));
		#else
		var event:TimeLineEvent = fromPool(type, bubbles, cancelable);
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
		return new TimeLineEvent(this.type, this.bubbles, this.cancelable);
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
	
	private function setTo(type:String, bubbles:Bool, cancelable:Bool):TimeLineEvent
	{
		this.type = type;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}