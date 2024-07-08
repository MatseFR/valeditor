package valeditor.ui;

import openfl.geom.Rectangle;
import starling.display.Quad;
import valedit.utils.RegularPropertyName;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectStarlingDefault extends Quad implements IInteractiveObject
{
	static private var _POOL:Array<InteractiveObjectStarlingDefault> = new Array<InteractiveObjectStarlingDefault>();
	
	static public function fromPool(?minWidth:Float, ?minHeight:Float):InteractiveObjectStarlingDefault
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(minWidth, minHeight);
		return new InteractiveObjectStarlingDefault(minWidth, minHeight);
	}
	
	public var minHeight(get, set):Float;
	public var minWidth(get, set):Float;
	public var visibilityLocked:Bool;
	
	private var _minHeight:Float;
	private function get_minHeight():Float { return this._minHeight; }
	private function set_minHeight(value:Float):Float
	{
		if (this._minHeight == value) return value;
		this._minHeight = value;
		if (this.height < this._minHeight)
		{
			this.height = this._minHeight;
		}
		return this._minHeight;
	}
	
	private var _minWidth:Float;
	private function get_minWidth():Float { return this._minWidth; }
	private function set_minWidth(value:Float):Float
	{
		if (this._minWidth == value) return value;
		this._minWidth = value;
		if (this.width < this._minWidth)
		{
			this.width = this._minWidth;
		}
		return this._minWidth;
	}
	
	//@:setter(height)
	override function set_height(value:Float):Float 
	{
		readjustSize(this.width, value);
		return value;
	}
	
	//@:setter(width)
	override function set_width(value:Float):Float 
	{
		readjustSize(value, this.height);
		return value;
	}
	
	private var _interestMap:Map<String, Bool>;
	
	public function new(?minWidth:Float, ?minHeight:Float) 
	{
		super(1, 1, 0xff0000);
		this.alpha = 0.25;
		
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
		
		setTo(minWidth, minHeight);
	}
	
	public function pool():Void
	{
		this.removeFromParent();
		this.visibilityLocked = false;
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(?minWidth:Float, ?minHeight:Float):InteractiveObjectStarlingDefault
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
		if (object.useBounds)
		{
			var scaleX:Float = 1.0;
			var scaleY:Float = 1.0;
			var width:Float;
			var height:Float;
			var bounds:Rectangle = object.getBounds(object.object);
			
			if (object.hasScaleProperties)
			{
				scaleX = object.getProperty(RegularPropertyName.SCALE_X);
				scaleY = object.getProperty(RegularPropertyName.SCALE_Y);
				
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
			
			if (object.hasPivotProperties)
			{
				if (object.usePivotScaling)
				{
					this.pivotX = object.getProperty(RegularPropertyName.PIVOT_X) * Math.abs(scaleX);
					this.pivotY = object.getProperty(RegularPropertyName.PIVOT_Y) * Math.abs(scaleY);
				}
				else
				{
					this.pivotX = object.getProperty(RegularPropertyName.PIVOT_X);
					this.pivotY = object.getProperty(RegularPropertyName.PIVOT_Y);
				}
				
				this.x = object.getProperty(RegularPropertyName.X) + bounds.x;
				this.y = object.getProperty(RegularPropertyName.Y) + bounds.y;
			}
			else
			{
				this.pivotX = -bounds.x * Math.abs(scaleX);
				this.pivotY = -bounds.y * Math.abs(scaleY);
				
				this.x = object.getProperty(RegularPropertyName.X);
				this.y = object.getProperty(RegularPropertyName.Y);
			}
			
			if (width < this._minWidth) width = this._minWidth;
			if (height < this._minHeight) height = this._minHeight;
			
			readjustSize(width, height);
			
			var rotation:Float = object.getProperty(RegularPropertyName.ROTATION);
			if (object.hasRadianRotation)
			{
				this.rotation = rotation;
			}
			else
			{
				this.rotation = MathUtil.deg2rad(rotation);
			}
		}
		else
		{
			this.x = object.getProperty(RegularPropertyName.X);
			this.y = object.getProperty(RegularPropertyName.Y);
			if (object.hasPivotProperties)
			{
				if (object.usePivotScaling)
				{
					this.pivotX = object.getProperty(RegularPropertyName.PIVOT_X) * Math.abs(object.getProperty(RegularPropertyName.SCALE_X));
					this.pivotY = object.getProperty(RegularPropertyName.PIVOT_Y) * Math.abs(object.getProperty(RegularPropertyName.SCALE_Y));
				}
				else
				{
					this.pivotX = object.getProperty(RegularPropertyName.PIVOT_X);
					this.pivotY = object.getProperty(RegularPropertyName.PIVOT_Y);
				}
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
				this.scale = 1;
			}
			
			var rotation:Float = object.getProperty(RegularPropertyName.ROTATION);
			object.setProperty(RegularPropertyName.ROTATION, 0.0, true, false);
			this.rotation = 0;
			
			var width:Float = object.getProperty(RegularPropertyName.WIDTH);
			if (width < this._minWidth) width = this._minWidth;
			var height:Float = object.getProperty(RegularPropertyName.HEIGHT);
			if (height < this._minHeight) height = this._minHeight;
			
			readjustSize(width, height);
			
			object.setProperty(RegularPropertyName.ROTATION, rotation, true, false);
			if (object.hasRadianRotation)
			{
				this.rotation = rotation;
			}
			else
			{
				this.rotation = MathUtil.deg2rad(rotation);
			}
		}
		
		if (!this.visibilityLocked && object.hasVisibleProperty)
		{
			this.visible = object.getProperty(RegularPropertyName.VISIBLE);
		}
	}
	
}