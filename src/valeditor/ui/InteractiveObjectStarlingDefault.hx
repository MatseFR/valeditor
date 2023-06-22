package valeditor.ui;

import starling.display.Quad;
import valedit.util.RegularPropertyName;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectStarlingDefault extends Quad implements IInteractiveObject
{
	static private var _POOL:Array<InteractiveObjectStarlingDefault> = new Array<InteractiveObjectStarlingDefault>();
	
	static public function fromPool():InteractiveObjectStarlingDefault
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new InteractiveObjectStarlingDefault();
	}
	
	static public function toPool(object:InteractiveObjectStarlingDefault):Void
	{
		_POOL.push(object);
	}
	
	public var minWidth(get, set):Float;
	private var _minWidth:Float;
	private function get_minWidth():Float { return this._minWidth; }
	private function set_minWidth(value:Float):Float
	{
		this._minWidth = value;
		if (this.width < this._minWidth)
		{
			this.width = this._minWidth;
		}
		return this._minWidth;
	}
	
	public var minHeight(get, set):Float;
	private var _minHeight:Float;
	private function get_minHeight():Float { return this._minHeight; }
	private function set_minHeight(value:Float):Float
	{
		this._minHeight = value;
		if (this.height < this._minHeight)
		{
			this.height = this._minHeight;
		}
		return this._minHeight;
	}
	
	//@:setter(width)
	override function set_width(value:Float):Float 
	{
		readjustSize(value, this.height);
		return value;
	}
	
	//@:setter(height)
	override function set_height(value:Float):Float 
	{
		readjustSize(this.width, value);
		return value;
	}
	
	private var _interestMap:Map<String, Bool>;
	
	public function new(?minWidth:Float, ?minHeight:Float) 
	{
		if (minWidth == null) minWidth = UIConfig.INTERACTIVE_OBJECT_MIN_WIDTH;
		if (minHeight == null) minHeight = UIConfig.INTERACTIVE_OBJECT_MIN_HEIGHT;
		
		this._minWidth = minWidth;
		this._minHeight = minHeight;
		
		super(minWidth, minHeight, 0xff0000);
		this.alpha = 0;
		
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
	
	public function pool():Void
	{
		toPool(this);
	}
	
}