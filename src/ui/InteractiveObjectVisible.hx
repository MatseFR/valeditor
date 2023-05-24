package ui;

import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Matrix;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectVisible extends Sprite 
{
	static public var LINE_BMD:BitmapData;
	
	static private var _IS_SETUP:Bool = false;
	static private var _LINE_MATRIX:Matrix;
	static private var _POOL:Array<InteractiveObjectVisible> = new Array<InteractiveObjectVisible>();
	
	static public function setup():Void
	{
		if (_IS_SETUP) return;
		
		LINE_BMD = new BitmapData(4, 1, true, 0x00ffffff);
		LINE_BMD.setPixel32(0, 0, 0xff000000);
		LINE_BMD.setPixel32(1, 0, 0xff000000);
		LINE_BMD.setPixel32(2, 0, 0xffffffff);
		LINE_BMD.setPixel32(3, 0, 0xffffffff);
		
		_LINE_MATRIX = new Matrix();
		_LINE_MATRIX.rotate(0.5 * Math.PI);
		
		_IS_SETUP = true;
	}
	
	static public function fromPool():InteractiveObjectVisible
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new InteractiveObjectVisible();
	}
	
	static public function toPool(object:InteractiveObjectVisible):Void
	{
		_POOL.push(object);
	}
	
	public var pivotX(get, set):Float;
	private var _pivotX:Float = 0;
	private function get_pivotX():Float { return this._pivotX; }
	private function set_pivotX(value:Float):Float
	{
		this._shape.x = -value;
		return this._pivotX = value;
	}
	
	public var pivotY(get, set):Float;
	private var _pivotY:Float = 0;
	private function get_pivotY():Float { return this._pivotY; }
	private function set_pivotY(value:Float):Float
	{
		this._shape.y = -value;
		return this._pivotY;
	}
	
	public var realWidth(get, set):Float;
	private function get_realWidth():Float { return this._shape.width; }
	private function set_realWidth(value:Float):Float
	{
		refreshShape(value, this._shape.height);
		return value;
	}
	
	public var realHeight(get, set):Float;
	private function get_realHeight():Float { return this._shape.height; }
	private function set_realHeight(value:Float):Float
	{
		refreshShape(this._shape.width, value);
		return value;
	}
	
	private var _shape:Shape;
	
	public function new() 
	{
		super();
		
		this.mouseChildren = false;
		
		if (!_IS_SETUP) setup();
		
		this._shape = new Shape();
		addChild(this._shape);
	}
	
	private function refreshShape(width:Float, height:Float):Void
	{
		this._shape.graphics.clear();
		this._shape.graphics.beginFill(0xff0000, 0);
		this._shape.graphics.lineStyle(1);
		this._shape.graphics.lineBitmapStyle(LINE_BMD);
		this._shape.graphics.moveTo(0, 0);
		this._shape.graphics.lineTo(width, 0);
		this._shape.graphics.moveTo(0, height);
		this._shape.graphics.lineTo(width, height);
		this._shape.graphics.lineBitmapStyle(LINE_BMD, _LINE_MATRIX);
		this._shape.graphics.moveTo(width, 0);
		this._shape.graphics.lineTo(width, height);
		this._shape.graphics.moveTo(0, 0);
		this._shape.graphics.lineTo(0, height);
		this._shape.graphics.endFill();
	}
	
}