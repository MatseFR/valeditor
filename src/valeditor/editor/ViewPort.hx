package valeditor.editor;

import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IEventDispatcher;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Matse
 */
class ViewPort extends EventDispatcher 
{
	public var x(get, set):Float;
	private function get_x():Float { return this._rect.x; }
	private function set_x(value:Float):Float
	{
		if (this._rect.x == value) return value;
		dispatchEvent(new Event(Event.CHANGE));
		return this._rect.x = value;
	}
	
	public var y(get, set):Float;
	private function get_y():Float { return this._rect.y; }
	private function set_y(value:Float):Float
	{
		if (this._rect.y == value) return value;
		dispatchEvent(new Event(Event.CHANGE));
		return this._rect.y = value;
	}
	
	public var width(get, set):Float;
	private function get_width():Float { return this._rect.width; }
	private function set_width(value:Float):Float
	{
		if (this._rect.width == value) return value;
		dispatchEvent(new Event(Event.CHANGE));
		return this._rect.width = value;
	}
	
	public var height(get, set):Float;
	
	public var rect(get, set):Rectangle;
	private var _rect:Rectangle = new Rectangle();
	private function get_rect():Rectangle { return this._rect; }
	private function set_rect(value:Rectangle):Rectangle
	{
		dispatchEvent(new Event(Event.CHANGE));
		return this._rect = value;
	}

	public function new(target:IEventDispatcher=null) 
	{
		super(target);
	}
	
	public function update(x:Float, y:Float, width:Float, height:Float):Void
	{
		var change:Bool = x != this._rect.x || y != this._rect.y || width != this._rect.width || height != this._rect.height;
		if (!change) return;
		this._rect.setTo(x, y, width, height);
		dispatchEvent(new Event(Event.CHANGE));
	}
	
}