package valeditor.ui;

import starling.display.Canvas;
import valedit.util.RegularPropertyName;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectStarlingVisible extends Canvas implements IInteractiveObject
{
	static private var _POOL:Array<InteractiveObjectStarlingVisible> = new Array<InteractiveObjectStarlingVisible>();
	
	static public function fromPool():InteractiveObjectStarlingVisible
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new InteractiveObjectStarlingVisible();
	}
	
	static public function toPool(object:InteractiveObjectStarlingVisible):Void
	{
		_POOL.push(object);
	}
	
	//@:setter(width)
	override function set_width(value:Float):Float 
	{
		refresh(value, this.height);
		return value;
	}
	
	//@:setter(height)
	override function set_height(value:Float):Float 
	{
		refresh(this.width, value);
		return value;
	}
	
	private var _interestMap:Map<String, Bool>;
	
	public function new() 
	{
		super();
		
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
			this.pivotX = object.getProperty(RegularPropertyName.PIVOT_X);
			this.pivotY = object.getProperty(RegularPropertyName.PIVOT_Y);
		}
		else
		{
			this.pivotX = 0;
			this.pivotY = 0;
		}
		
		var rotation:Float = object.getProperty(RegularPropertyName.ROTATION);
		object.setProperty(RegularPropertyName.ROTATION, 0.0, true, false);
		this.rotation = 0;
		
		refresh(object.getProperty(RegularPropertyName.WIDTH), object.getProperty(RegularPropertyName.HEIGHT));
		
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
	
	private function refresh(width:Float, height:Float):Void
	{
		this.clear();
		this.beginFill(0xffffff, 0);
		this.drawRectangle(0, 0, width, height);
		
		this.beginFill(0xffffff, 1);
		this.drawRectangle(0, 0, width, 1);
		this.drawRectangle(width, 0, 1, height);
		this.drawRectangle(0, height, width, 1);
		this.drawRectangle(0, 0, 1, height);
		
		this.beginFill(0x000000, 1);
		this.drawRectangle(1, 1, width - 2, 1);
		this.drawRectangle(width - 1, 1, 1, height - 2);
		this.drawRectangle(1, height - 1, width - 2, 1);
		this.drawRectangle(1, 1, 1, height - 2);
	}
	
}