package valeditor.ui;

import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import valedit.util.RegularPropertyName;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectVisible extends Sprite implements IInteractiveObject
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
	
	public var minWidth(get, set):Float;
	private var _minWidth:Float;
	private function get_minWidth():Float { return this._minWidth; }
	private function set_minWidth(value:Float):Float
	{
		this._minWidth = value;
		if (this.realWidth < this._minWidth)
		{
			this.realWidth = this._minWidth;
		}
		return this._minWidth;
	}
	
	public var minHeight(get, set):Float;
	private var _minHeight:Float;
	private function get_minHeight():Float { return this._minHeight; }
	private function set_minHeight(value:Float):Float
	{
		this._minHeight = value;
		if (this.realHeight < this._minHeight)
		{
			this.realHeight = this._minHeight;
		}
		return this._minHeight;
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
	
	private var _interestMap:Map<String, Bool>;
	private var _shape:Shape;
	
	public function new(?minWidth:Float, ?minHeight:Float) 
	{
		super();
		
		if (minWidth == null) minWidth = UIConfig.INTERACTIVE_OBJECT_MIN_WIDTH;
		if (minHeight == null) minHeight = UIConfig.INTERACTIVE_OBJECT_MIN_HEIGHT;
		
		this._minWidth = minWidth;
		this._minHeight = minHeight;
		
		this.mouseChildren = false;
		
		if (!_IS_SETUP) setup();
		
		this._interestMap = new Map<String, Bool>();
		this._interestMap.set(RegularPropertyName.X, true);
		this._interestMap.set(RegularPropertyName.Y, true);
		this._interestMap.set(RegularPropertyName.PIVOT_X, true);
		this._interestMap.set(RegularPropertyName.PIVOT_Y, true);
		this._interestMap.set(RegularPropertyName.ROTATION, true);
		this._interestMap.set(RegularPropertyName.SCALE_X, true);
		this._interestMap.set(RegularPropertyName.SCALE_Y, true);
		this._interestMap.set(RegularPropertyName.WIDTH, true);
		this._interestMap.set(RegularPropertyName.HEIGHT, true);
		
		this._shape = new Shape();
		addChild(this._shape);
	}
	
	public function hasInterestIn(regularPropertyName:String):Bool
	{
		return this._interestMap.exists(regularPropertyName);
	}
	
	public function objectUpdate(object:ValEditorObject):Void
	{
		this.x = object.getProperty(RegularPropertyName.X);
		this.y = object.getProperty(RegularPropertyName.Y);
		if (object.hasPivotProperties)
		{
			this.pivotX = object.getProperty(RegularPropertyName.PIVOT_X);
			this.pivotY = object.getProperty(RegularPropertyName.PIVOT_Y);
		}
		else
		{
			this.pivotX = 0;
			this.pivotY = 0;
		}
		
		if (object.hasScaleProperties)
		{
			var scaleX:Float = object.getProperty(RegularPropertyName.SCALE_X);
			var scaleY:Float = object.getProperty(RegularPropertyName.SCALE_Y);
			
			if (scaleX < 0)
			{
				this.scaleX = -1;
			}
			else
			{
				this.scaleX = 1;
			}
			
			if (scaleY < 0)
			{
				this.scaleY = -1;
			}
			else
			{
				this.scaleY = 1;
			}
		}
		else
		{
			this.scaleX = 1;
			this.scaleY = 1;
		}
		
		var rotation:Float = object.getProperty(RegularPropertyName.ROTATION);
		object.setProperty(RegularPropertyName.ROTATION, 0.0, true, false);
		this.rotation = 0;
		
		refreshShape(object.getProperty(RegularPropertyName.WIDTH), object.getProperty(RegularPropertyName.HEIGHT));
		
		object.setProperty(RegularPropertyName.ROTATION, rotation, true, false);
		if (object.hasRadianRotation)
		{
			this.rotation = MathUtil.rad2deg(rotation);
		}
		else
		{
			this.rotation = rotation;
		}
	}
	
	public function pool():Void
	{
		toPool(this);
	}
	
	private function refreshShape(width:Float, height:Float):Void
	{
		this._shape.graphics.clear();
		this._shape.graphics.beginFill(0xff0000, 0);
		this._shape.graphics.drawRect(0, 0, width, height);
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