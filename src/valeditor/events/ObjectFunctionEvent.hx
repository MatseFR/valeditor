package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valeditor.ValEditorObject;

/**
 * ...
 * @author Matse
 */
class ObjectFunctionEvent extends Event 
{
	inline static public var CALLED:String = "called";
	
	#if !flash
	static private var _POOL:Array<ObjectFunctionEvent> = new Array<ObjectFunctionEvent>();
	
	static private function fromPool(type:String, object:ValEditorObject, functionName:String, parameters:Array<Dynamic>, bubbles:Bool, cancelable:Bool):ObjectFunctionEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, object, functionName, parameters, bubbles, cancelable);
		return new ObjectFunctionEvent(type, object, functionName, parameters, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, object:ValEditorObject, functionName:String,
									parameters:Array<Dynamic> = null, bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new ObjectFunctionEvent(type, object, functionName, parameters, bubbles, cancelable));
		#else
		var event:ObjectFunctionEvent = fromPool(type, object, functionName, parameters, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var object(default, null):ValEditorObject;
	public var functionName(default, null):String;
	public var parameters(default, null):Array<Dynamic>;
	
	public function new(type:String, object:ValEditorObject, functionName:String, parameters:Array<Dynamic> = null,
						bubbles:Bool = false, cancelable:Bool = false) 
	{
		super(type, bubbles, cancelable);
		this.object = object;
		this.functionName = functionName;
		this.parameters = parameters;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new ObjectFunctionEvent(this.type, this.object, this.functionName, this.parameters, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.object, this.functionName, this.parameters, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	private function pool():Void
	{
		this.object = null;
		this.functionName = null;
		this.parameters = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(type:String, object:ValEditorObject, functionName:String, parameters:Array<Dynamic>, bubbles:Bool, cancelable:Bool):ObjectFunctionEvent
	{
		this.type = type;
		this.object = object;
		this.functionName = functionName;
		this.parameters = parameters;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
	}
	#end
	
}