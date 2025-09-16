package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;

/**
 * ...
 * @author Matse
 */
class ObjectSettingEvent extends Event 
{
	inline static public var DESTROY_ON_COMPLETION:String = "destroy_on_completion";
	inline static public var RESTORE_VALUES_ON_COMPLETION:String = "restore_values_on_completion";
	
	#if !flash
	static private var _POOL:Array<ObjectSettingEvent> = new Array<ObjectSettingEvent>();
	
	static private function fromPool(type:String, object:ValEditorObject, bubbles:Bool, cancelable:Bool):ObjectSettingEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, propertyNames, bubbles, cancelable);
		return new ObjectSettingEvent(type, object, propertyNames, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:ValEditorObject,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ObjectSettingEvent(type, object, bubbles, cancelable));
		#else
		var event:ObjectSettingEvent = fromPool(type, object, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var object(default, null):ValEditorObject;
	
	public function new(type:String, object:ValEditorObject, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ObjectSettingEvent(this.type, this.object, this.bubbles, this.cancelable);
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
	
	private function setTo(type:String, object:ValEditorObject, bubbles:Bool, cancelable:Bool):ObjectPropertyEvent
	{
		this.type = type;
		this.object = object;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}