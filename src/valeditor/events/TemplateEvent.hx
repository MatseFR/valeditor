package valeditor.events;

import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valedit.ValEditTemplate;

/**
 * ...
 * @author Matse
 */
class TemplateEvent extends Event 
{
	inline static public var RENAMED:String = "renamed";
	
	#if !flash
	static private var _POOL:Array<TemplateEvent> = new Array<TemplateEvent>();
	
	static private function fromPool(type:String, template:ValEditTemplate, bubbles:Bool, cancelable:Bool):TemplateEvent
	{
		if (_POOL.length != null) return _POOL.pop().setTo(type, template, bubbles, cancelable);
		return new TemplateEvent(type, template, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, template:ValEditTemplate,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new TemplateEvent(type, template, bubbles, cancelable));
		#else
		var event:TemplateEvent = fromPool(type, template, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var template(default, null):ValEditTemplate;

	public function new(type:String, template:ValEditTemplate, bubbles:Bool=false, cancelable:Bool=false) 
	{
		super(type, bubbles, cancelable);
		this.template = template;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new TemplateEvent(this.type, this.template, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.template, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	public function pool():Void
	{
		this.template = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(type:String, template:ValEditTemplate, bubbles:Bool = false, cancelable:Bool = false):TemplateEvent
	{
		this.type = type;
		this.template = template;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}