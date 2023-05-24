package ui;

import openfl.display.Shape;
import openfl.display.Sprite;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectDefault extends Sprite 
{
	static private var _POOL:Array<InteractiveObjectDefault> = new Array<InteractiveObjectDefault>();
	
	static public function fromPool():InteractiveObjectDefault
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new InteractiveObjectDefault();
	}
	
	static public function toPool(object:InteractiveObjectDefault):Void
	{
		_POOL.push(object);
	}
	
	public var pivotX(get, set):Float;
	private var _pivotX:Float = 0;
	private function get_pivotX():Float { return this._pivotX; }
	private function set_pivotX(value:Float):Float
	{
		this._shape.x = -value;
		return this._pivotX;
	}
	
	public var pivotY(get, set):Float;
	private var _pivotY:Float = 0;
	private function get_pivotY():Float { return this._pivotY; }
	private function set_pivotY(value:Float):Float
	{
		this._shape.y = -value;
		return this._pivotY;
	}
	
	private var _shape:Shape;
	
	public function new() 
	{
		super();
		
		this.mouseChildren = false;
		
		this._shape = new Shape();
		this._shape.graphics.beginFill(0xff0000, 1);
		this._shape.graphics.drawRect(0, 0, 1, 1);
		this._shape.graphics.endFill();
		addChild(this._shape);
	}
	
}