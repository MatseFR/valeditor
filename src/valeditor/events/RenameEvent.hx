package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class RenameEvent extends Event 
{
	inline static public var RENAMED:String = "renamed";
	
	#if !flash
	static private var _POOL:Array<RenameEvent> = new Array<RenameEvent>();
	
	static private function fromPool(type:String, previousNameOrID:String, bubbles:Bool, cancelable:Bool):RenameEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, previousNameOrID, bubbles, cancelable);
		return new RenameEvent(type, previousNameOrID, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, previouseNameOrID:String,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ContainerEvent(type, previouseNameOrID, bubbles, cancelable));
		#else
		var event:RenameEvent = fromPool(type, previouseNameOrID, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var previousNameOrID(default, null):String;

	public function new(type:String, previousNameOrID:String, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.previousNameOrID = previousNameOrID;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new RenameEvent(this.type, this.previousNameOrID, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.previousNameOrID, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	public function pool():Void
	{
		this.previousNameOrID = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(type:String, previousNameOrID:String, bubbles:Bool = false, cancelable:Bool = false):RenameEvent
	{
		this.type = type;
		this.previousNameOrID = previousNameOrID;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}