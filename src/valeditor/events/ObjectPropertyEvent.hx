package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valeditor.ValEditorObject;

/**
 * ...
 * @author Matse
 */
class ObjectPropertyEvent extends Event 
{
	inline static public var CHANGE:String = "change";
	
	#if !flash
	static private var _POOL:Array<ObjectPropertyEvent> = new Array<ObjectPropertyEvent>();
	
	static private function fromPool(type:String, object:ValEditorObject, propertyNames:Array<String>, bubbles:Bool, cancelable:Bool):ObjectPropertyEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, propertyNames, bubbles, cancelable);
		return new ObjectPropertyEvent(type, object, propertyNames, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:ValEditorObject,
									propertyNames:Array<String>, bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ObjectPropertyEvent(type, object, propertyNames, bubbles, cancelable));
		#else
		var event:ObjectPropertyEvent = fromPool(type, object, propertyNames, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var object(default, null):ValEditorObject;
	public var propertyNames(default, null):Array<String>;
	
	public function new(type:String, object:ValEditorObject, propertyNames:Array<String>, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
		this.propertyNames = propertyNames;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ObjectPropertyEvent(this.type, this.object, this.propertyNames, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.object, this.propertyNames, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	private function pool():Void
	{
		this.object = null;
		this.propertyNames = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(type:String, object:ValEditorObject, propertyNames:Array<String>, bubbles:Bool, cancelable:Bool):ObjectPropertyEvent
	{
		this.type = type;
		this.object = object;
		this.propertyNames = propertyNames;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}