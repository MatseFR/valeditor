package ui;

import starling.display.Quad;
import utils.MathUtil;
import valedit.ValEditObject;
import valedit.util.RegularPropertyName;

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
	
	//public var propertyMap:PropertyMap;
	
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
	
	public function new() 
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
	}
	
	public function hasInterestIn(regularPropertyName:String):Bool
	{
		return this._interestMap.exists(regularPropertyName);
	}
	
	public function objectUpdate(object:ValEditObject):Void
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
		
		var rotation:Float = object.getProperty(RegularPropertyName.ROTATION);
		object.setProperty(RegularPropertyName.ROTATION, 0.0, true, false);
		this.rotation = 0;
		
		readjustSize(object.getProperty(RegularPropertyName.WIDTH), object.getProperty(RegularPropertyName.HEIGHT));
		
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