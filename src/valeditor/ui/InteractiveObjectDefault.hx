package valeditor.ui;

import openfl.display.Shape;
import openfl.display.Sprite;
import valedit.utils.RegularPropertyName;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectDefault extends Sprite implements IInteractiveObject
{
	static private var _POOL:Array<InteractiveObjectDefault> = new Array<InteractiveObjectDefault>();
	
	static public function fromPool(?minWidth:Float, ?minHeight:Float):InteractiveObjectDefault
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(minWidth, minHeight);
		return new InteractiveObjectDefault(minWidth, minHeight);
	}
	
	public var minHeight(get, set):Float;
	public var minWidth(get, set):Float;
	public var pivotX(get, set):Float;
	public var pivotY(get, set):Float;
	public var realHeight(get, set):Float;
	public var realWidth(get, set):Float;
	public var visibilityLocked:Bool;
	
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
		return this._pivotX;
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
		refreshShape(this.realWidth, value);
		return value;
	}
	
	private function get_realWidth():Float { return this._shape.width; }
	private function set_realWidth(value:Float):Float
	{
		refreshShape(value, this.realHeight);
		return value;
	}
	
	private var _interestMap:Map<String, Bool>;
	private var _shape:Shape;
	
	public function new(?minWidth:Float, ?minHeight:Float) 
	{
		super();
		
		this.mouseChildren = false;
		
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
	
	public function pool():Void
	{
		if (this.parent != null) this.parent.removeChild(this);
		this.visibilityLocked = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(?minWidth:Float, ?minHeight:Float):InteractiveObjectDefault
	{
		if (minWidth == null) minWidth = UIConfig.INTERACTIVE_OBJECT_MIN_WIDTH;
		if (minHeight == null) minHeight = UIConfig.INTERACTIVE_OBJECT_MIN_HEIGHT;
		
		this.minWidth = minWidth;
		this.minHeight = minHeight;
		
		return this;
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
			this.pivotX = object.getProperty(RegularPropertyName.PIVOT_X) * object.getProperty(RegularPropertyName.SCALE_X);
			this.pivotY = object.getProperty(RegularPropertyName.PIVOT_Y) * object.getProperty(RegularPropertyName.SCALE_Y);
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
		
		if (!this.visibilityLocked && object.hasVisibleProperty)
		{
			this.visible = object.getProperty(RegularPropertyName.VISIBLE);
		}
	}
	
	private function refreshShape(width:Float, height:Float):Void
	{
		if (width < this._minWidth) width = this._minWidth;
		if (height < this._minHeight) height = this._minHeight;
		this._shape.graphics.clear();
		this._shape.graphics.beginFill(0xff0000, 0);
		this._shape.graphics.drawRect(0, 0, width, height);
		this._shape.graphics.endFill();
	}
	
}