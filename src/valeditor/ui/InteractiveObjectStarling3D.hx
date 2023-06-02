package valeditor.ui;

import starling.display.Quad;
import starling.display.Sprite3D;
import valeditor.utils.MathUtil;
import valedit.ValEditObject;
import valedit.util.RegularPropertyName;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectStarling3D extends Sprite3D implements IInteractiveObject
{
	static private var _POOL:Array<InteractiveObjectStarling3D> = new Array<InteractiveObjectStarling3D>();
	
	static public function fromPool():InteractiveObjectStarling3D
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new InteractiveObjectStarling3D();
	}
	
	static public function toPool(object:InteractiveObjectStarling3D):Void
	{
		_POOL.push(object);
	}
	
	//@:setter(width)
	override function set_width(value:Float):Float 
	{
		this._quad.readjustSize(value, this._quad.height);
		return value;
	}
	
	//@:setter(height)
	override function set_height(value:Float):Float 
	{
		this._quad.readjustSize(this._quad.width, value);
		return value;
	}
	
	private var _interestMap:Map<String, Bool>;
	private var _quad:Quad;
	
	public function new() 
	{
		super();
		
		this._quad = new Quad(1, 1, 0xff0000);
		this._quad.alpha = 0.25;
		addChild(this._quad);
		
		this._interestMap = new Map<String, Bool>();
		this._interestMap.set(RegularPropertyName.X, true);
		this._interestMap.set(RegularPropertyName.Y, true);
		this._interestMap.set(RegularPropertyName.Z, true);
		this._interestMap.set(RegularPropertyName.PIVOT_X, true);
		this._interestMap.set(RegularPropertyName.PIVOT_Y, true);
		this._interestMap.set(RegularPropertyName.PIVOT_Z, true);
		this._interestMap.set(RegularPropertyName.ROTATION, true);
		this._interestMap.set(RegularPropertyName.ROTATION_X, true);
		this._interestMap.set(RegularPropertyName.ROTATION_Y, true);
		this._interestMap.set(RegularPropertyName.ROTATION_Z, true);
		this._interestMap.set(RegularPropertyName.SCALE_X, true);
		this._interestMap.set(RegularPropertyName.SCALE_Y, true);
		this._interestMap.set(RegularPropertyName.SCALE_Z, true);
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
		this.z = object.getProperty(RegularPropertyName.Z);
		if (object.hasPivotProperties)
		{
			this.pivotX = object.getProperty(RegularPropertyName.PIVOT_X) * object.getProperty(RegularPropertyName.SCALE_X);
			this.pivotY = object.getProperty(RegularPropertyName.PIVOT_Y) * object.getProperty(RegularPropertyName.SCALE_Y);
			this.pivotZ = object.getProperty(RegularPropertyName.PIVOT_Z);// * object.getProperty(RegularPropertyName.SCALE_Z);
		}
		else
		{
			this.pivotX = 0;
			this.pivotY = 0;
			this.pivotZ = 0;
		}
		
		var rotationX:Float = object.getProperty(RegularPropertyName.ROTATION_X);
		var rotationY:Float = object.getProperty(RegularPropertyName.ROTATION_Y);
		var rotationZ:Float = object.getProperty(RegularPropertyName.ROTATION_Z);
		
		object.setProperty(RegularPropertyName.ROTATION_X, 0.0, true, false);
		object.setProperty(RegularPropertyName.ROTATION_Y, 0.0, true, false);
		object.setProperty(RegularPropertyName.ROTATION_Z, 0.0, true, false);
		
		this.rotationX = 0;
		this.rotationY = 0;
		this.rotationZ = 0;
		
		this._quad.readjustSize(object.getProperty(RegularPropertyName.WIDTH), object.getProperty(RegularPropertyName.HEIGHT));
		
		object.setProperty(RegularPropertyName.ROTATION_X, rotationX, true, false);
		object.setProperty(RegularPropertyName.ROTATION_Y, rotationY, true, false);
		object.setProperty(RegularPropertyName.ROTATION_Z, rotationZ, true, false);
		
		if (object.hasRadianRotation)
		{
			this.rotationX = rotationX;
			this.rotationY = rotationY;
			this.rotationZ = rotationZ;
		}
		else
		{
			this.rotationX = MathUtil.deg2rad(rotationX);
			this.rotationY = MathUtil.deg2rad(rotationY);
			this.rotationZ = MathUtil.deg2rad(rotationZ);
		}
		
		this.scaleZ = object.getProperty(RegularPropertyName.SCALE_Z);
	}
	
	public function pool():Void
	{
		toPool(this);
	}
	
}