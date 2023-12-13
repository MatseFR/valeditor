package valeditor.events;
import openfl.events.Event;
import openfl.events.IEventDispatcher;
import valedit.ValEditLayer;
import valedit.ValEditObject;

/**
 * ...
 * @author Matse
 */
class LayerEvent extends Event
{
	inline static public var OBJECT_ADDED:String = "object_added";
	inline static public var OBJECT_REMOVED:String = "object_removed";
	
	#if !flash
	static private var _POOL:Array<LayerEvent> = new Array<LayerEvent>();
	
	static private function fromPool(type:String, layer:ValEditLayer, object:ValEditObject, bubbles:Bool, cancelable:Bool):LayerEvent
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(type, layer, object, bubbles, cancelable);
		return new LayerEvent(type, layer, object, bubbles, cancelable);
	}
	#end
	
	static public function dispatch(dispatcher:IEventDispatcher, type:String, layer:ValEditLayer, object:ValEditObject = null,
									bubbles:Bool = false, cancelable:Bool = false):Bool
	{
		#if flash
		return dispatcher.dispatchEvent(new LayerEvent(type, layer, object, bubbles, cancelable));
		#else
		var event:LayerEvent = fromPool(type, layer, object, bubbles, cancelable);
		var result:Bool = dispatcher.dispatchEvent(event);
		event.pool();
		return result;
		#end
	}
	
	public var layer(default, null):ValEditLayer;
	public var object(default, null):ValEditObject;

	public function new(type:String, layer:ValEditLayer, object:ValEditObject = null, bubbles:Bool = false, cancelable:Bool = false) 
	{
		super(type, bubbles, cancelable);
		this.layer = layer;
		this.object = object;
	}
	
	override public function clone():Event 
	{
		#if flash
		return new LayerEvent(this.type, this.layer, this.object, this.bubbles, this.cancelable);
		#else
		return fromPool(this.type, this.layer, this.object, this.bubbles, this.cancelable);
		#end
	}
	
	#if !flash
	public function pool():Void
	{
		this.layer = null;
		this.object = null;
		this.target = null;
		this.currentTarget = null;
		this.__preventDefault = false;
		this.__isCanceled = false;
		this.__isCanceledNow = false;
		_POOL[_POOL.length] = this;
	}
	
	public function setTo(type:String, layer:ValEditLayer, object:ValEditObject, bubbles:Bool = false, cancelable:Bool = false):LayerEvent
	{
		this.type = type;
		this.layer = layer;
		this.object = object;
		this.bubbles = bubbles;
		this.cancelable = cancelable;
		return this;
	}
	#end
	
}