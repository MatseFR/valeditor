package valeditor.ui;

import openfl.display.BitmapData;
import openfl.display.Shape;
import openfl.display.Sprite;
import openfl.geom.Matrix;
import openfl.geom.Rectangle;
import valedit.DisplayObjectType;
import valedit.utils.RegularPropertyName;
import valeditor.ValEditorObject;
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
		
		LINE_BMD = new BitmapData(4, 1);
		LINE_BMD.setPixel(0, 0, 0x000000);
		LINE_BMD.setPixel(1, 0, 0x000000);
		LINE_BMD.setPixel(2, 0, 0xffffff);
		LINE_BMD.setPixel(3, 0, 0xffffff);
		
		_LINE_MATRIX = new Matrix();
		_LINE_MATRIX.rotate(0.5 * Math.PI);
		
		_IS_SETUP = true;
	}
	
	static public function fromPool(?minWidth:Float, ?minHeight:Float):InteractiveObjectVisible
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(minWidth, minHeight);
		return new InteractiveObjectVisible(minWidth, minHeight);
	}
	
	public var debug(get, set):Bool;
	public var debugAlpha(get, set):Float;
	public var debugColor(get, set):Int;
	public var minHeight(get, set):Float;
	public var minWidth(get, set):Float;
	public var pivotX(get, set):Float;
	public var pivotY(get, set):Float;
	public var realHeight(get, set):Float;
	public var realWidth(get, set):Float;
	public var visibilityLocked:Bool;
	
	private var _debug:Bool = false;
	private function get_debug():Bool { return this._debug; }
	private function set_debug(value:Bool):Bool
	{
		if (this._debug == value) return value;
		this._debug = value;
		if (this._object != null)
		{
			objectUpdate(this._object);
		}
		return this._debug;
	}
	
	private var _debugAlpha:Float = 0.25;
	private function get_debugAlpha():Float { return this._debugAlpha; }
	private function set_debugAlpha(value:Float):Float
	{
		if (this._debugAlpha == value) return value;
		this._debugAlpha = value;
		if (this._object != null)
		{
			objectUpdate(this._object);
		}
		return this._debugAlpha;
	}
	
	private var _debugColor:Int = 0xff0000;
	private function get_debugColor():Int { return this._debugColor; }
	private function set_debugColor(value:Int):Int
	{
		if (this._debugColor == value) return value;
		this._debugColor = value;
		if (this._object != null)
		{
			objectUpdate(this._object);
		}
		return this._debugColor;
	}
	
	private var _minHeight:Float;
	private function get_minHeight():Float { return this._minHeight; }
	private function set_minHeight(value:Float):Float
	{
		if (this._minHeight == value) return value;
		this._minHeight = value;
		if (this.realHeight < this._minHeight)
		{
			this.realHeight = this._minHeight;
		}
		return this._minHeight;
	}
	
	private var _minWidth:Float;
	private function get_minWidth():Float { return this._minWidth; }
	private function set_minWidth(value:Float):Float
	{
		if (this._minWidth == value) return value;
		this._minWidth = value;
		if (this.realWidth < this._minWidth)
		{
			this.realWidth = this._minWidth;
		}
		return this._minWidth;
	}
	
	private var _pivotX:Float = 0;
	private function get_pivotX():Float { return this._pivotX; }
	private function set_pivotX(value:Float):Float
	{
		this._shape.x = -value;
		return this._pivotX = value;
	}
	
	private var _pivotY:Float = 0;
	private function get_pivotY():Float { return this._pivotY; }
	private function set_pivotY(value:Float):Float
	{
		this._shape.y = -value;
		return this._pivotY;
	}
	
	private function get_realHeight():Float { return this._shape.height; }
	private function set_realHeight(value:Float):Float
	{
		refreshShape(this._shape.width, value);
		return value;
	}
	
	private function get_realWidth():Float { return this._shape.width; }
	private function set_realWidth(value:Float):Float
	{
		refreshShape(value, this._shape.height);
		return value;
	}
	
	private var _interestMap:Map<String, Bool>;
	private var _object:ValEditorObject;
	private var _shape:Shape;
	
	public function new(?minWidth:Float, ?minHeight:Float) 
	{
		super();
		
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
		this._interestMap.set(RegularPropertyName.VISIBLE, true);
		
		this._shape = new Shape();
		addChild(this._shape);
		
		setTo(minWidth, minHeight);
	}
	
	private function clear():Void
	{
		this._object = null;
		this.visible = true;
		this.visibilityLocked = false;
	}
	
	public function pool():Void
	{
		if (this.parent != null) this.parent.removeChild(this);
		clear();
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(?minWidth:Float, ?minHeight:Float):InteractiveObjectVisible
	{
		if (minWidth == null) minWidth = UIConfig.INTERACTIVE_OBJECT_MIN_WIDTH;
		if (minHeight == null) minHeight = UIConfig.INTERACTIVE_OBJECT_MIN_HEIGHT;
		
		this._minWidth = minWidth;
		this._minHeight = minHeight;
		
		return this;
	}
	
	public function hasInterestIn(regularPropertyName:String):Bool
	{
		return this._interestMap.exists(regularPropertyName);
	}
	
	public function objectUpdate(object:ValEditorObject):Void
	{
		this._object = object;
		if (this._object.useBounds)
		{
			var scaleX:Float = 1.0;
			var scaleY:Float = 1.0;
			var width:Float;
			var height:Float;
			var bounds:Rectangle = this._object.getBounds(this._object.object);
			
			if (this._object.hasScaleProperties)
			{
				scaleX = this._object.getProperty(RegularPropertyName.SCALE_X);
				scaleY = this._object.getProperty(RegularPropertyName.SCALE_Y);
				
				width = bounds.width * Math.abs(scaleX);
				height = bounds.height * Math.abs(scaleY);
				
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
				width = bounds.width;
				height = bounds.height;
			}
			
			if (this._object.hasPivotProperties)
			{
				if (this._object.isDisplayObject && this._object.displayObjectType == DisplayObjectType.STARLING)
				{
					if (this._object.usePivotScaling)
					{
						this.pivotX = this._object.getProperty(RegularPropertyName.PIVOT_X) * Math.abs(scaleX);
						this.pivotY = this._object.getProperty(RegularPropertyName.PIVOT_Y) * Math.abs(scaleY);
					}
					else
					{
						this.pivotX = this._object.getProperty(RegularPropertyName.PIVOT_X);
						this.pivotY = this._object.getProperty(RegularPropertyName.PIVOT_Y);
					}
					
					this.x = this._object.getProperty(RegularPropertyName.X) + bounds.x;
					this.y = this._object.getProperty(RegularPropertyName.Y) + bounds.y;
				}
				else
				{
					this.pivotX = -bounds.x * Math.abs(scaleX);
					this.pivotY = -bounds.y * Math.abs(scaleY);
					
					this.x = this._object.getProperty(RegularPropertyName.X);
					this.y = this._object.getProperty(RegularPropertyName.Y);
				}
			}
			else
			{
				this.pivotX = -bounds.x * Math.abs(scaleX);
				this.pivotY = -bounds.y * Math.abs(scaleY);
				
				this.x = this._object.getProperty(RegularPropertyName.X);
				this.y = this._object.getProperty(RegularPropertyName.Y);
			}
			
			if (width < this._minWidth) width = this._minWidth;
			if (height < this._minHeight) height = this._minHeight;
			
			refreshShape(width, height);
			
			if (this._object.hasProperty(RegularPropertyName.ROTATION))
			{
				var rotation:Float = this._object.getProperty(RegularPropertyName.ROTATION);
				if (this._object.hasRadianRotation)
				{
					this.rotation = MathUtil.rad2deg(rotation);
				}
				else
				{
					this.rotation = rotation;
				}
			}
		}
		else
		{
			this.x = this._object.getProperty(RegularPropertyName.X);
			this.y = this._object.getProperty(RegularPropertyName.Y);
			if (this._object.hasPivotProperties)
			{
				if (this._object.usePivotScaling)
				{
					this.pivotX = this._object.getProperty(RegularPropertyName.PIVOT_X) * Math.abs(this._object.getProperty(RegularPropertyName.SCALE_X));
					this.pivotY = this._object.getProperty(RegularPropertyName.PIVOT_Y) * Math.abs(this._object.getProperty(RegularPropertyName.SCALE_Y));
				}
				else
				{
					this.pivotX = this._object.getProperty(RegularPropertyName.PIVOT_X);
					this.pivotY = this._object.getProperty(RegularPropertyName.PIVOT_Y);
				}
			}
			else
			{
				this.pivotX = 0;
				this.pivotY = 0;
			}
			
			if (this._object.hasScaleProperties)
			{
				var scaleX:Float = this._object.getProperty(RegularPropertyName.SCALE_X);
				var scaleY:Float = this._object.getProperty(RegularPropertyName.SCALE_Y);
				
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
			
			var rotation:Float = 0;
			if (this._object.hasProperty(RegularPropertyName.ROTATION))
			{
				rotation = this._object.getProperty(RegularPropertyName.ROTATION);
				this._object.setProperty(RegularPropertyName.ROTATION, 0.0, true, false);
			}
			this.rotation = 0;
			
			var width:Float = this._object.getProperty(RegularPropertyName.WIDTH);
			if (width < this._minWidth) width = this._minWidth;
			var height:Float = this._object.getProperty(RegularPropertyName.HEIGHT);
			if (height < this._minHeight) height = this._minHeight;
			
			refreshShape(width, height);
			
			if (this._object.hasProperty(RegularPropertyName.ROTATION))
			{
				this._object.setProperty(RegularPropertyName.ROTATION, rotation, true, false);
				if (this._object.hasRadianRotation)
				{
					this.rotation = MathUtil.rad2deg(rotation);
				}
				else
				{
					this.rotation = rotation;
				}
			}
		}
		
		if (!this.visibilityLocked && this._object.hasVisibleProperty)
		{
			this.visible = this._object.getProperty(RegularPropertyName.VISIBLE);
		}
	}
	
	private function refreshShape(width:Float, height:Float):Void
	{
		this._shape.graphics.clear();
		this._shape.graphics.beginFill(0xff0000, 0);
		this._shape.graphics.drawRect(0, 0, width, height);
		this._shape.graphics.endFill();
		
		this._shape.graphics.beginBitmapFill(LINE_BMD);
		this._shape.graphics.drawRect(0, 0, width, 1);
		this._shape.graphics.drawRect(0, height - 1, width, 1);
		this._shape.graphics.endFill();
		
		this._shape.graphics.beginBitmapFill(LINE_BMD, _LINE_MATRIX);
		this._shape.graphics.drawRect(0, 1, 1, height-2);
		this._shape.graphics.drawRect(width -1, 1, 1, height-2);
		this._shape.graphics.endFill();
	}
	
}