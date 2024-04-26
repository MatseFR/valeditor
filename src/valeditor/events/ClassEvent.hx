package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valeditor.ValEditorClass;

/**
 * ...
 * @author Matse
 */
class ClassEvent extends Event 
{
	inline static public var INSTANCE_ADDED:String = "instance_added";
	inline static public var INSTANCE_REMOVED:String = "instance_removed";
	inline static public var INSTANCE_SUSPENDED:String = "instance_suspended";
	inline static public var INSTANCE_UNSUSPENDED:String = "instance_unsuspended";
	inline static public var TEMPLATE_ADDED:String = "template_added";
	inline static public var TEMPLATE_REMOVED:String = "template_removed";
	inline static public var TEMPLATE_SUSPENDED:String = "template_suspended";
	inline static public var TEMPLATE_UNSUSPENDED:String = "template_unsuspended";
	
	#if !flash
	static private var _POOL:Array<ClassEvent> = new Array<ClassEvent>();
	
	static private function fromPool(type:String, clss:ValEditorClass, bubbles:Bool, cancelable:Bool):ClassEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, clss, bubbles, cancelable);
		return new ClassEvent(type, clss, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, clss:ValEditorClass,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ClassEvent(type, clss, bubbles, cancelable));
		#else
		var event:ClassEvent = fromPool(type, clss, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var clss(default, null):ValEditorClass;
	
	public function new(type:String, clss:ValEditorClass, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.clss = clss;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ClassEvent(this.type, this.clss, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.clss, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	private function pool():Void
	{
		this.clss = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(type:String, clss:ValEditorClass, bubbles:Bool, cancelable:Bool):ClassEvent
	{
		this.type = type;
		this.clss = clss;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}