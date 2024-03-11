package valeditor.ui.feathers.controls;

import openfl.display.Sprite;
import openfl.geom.Rectangle;
import valedit.utils.RegularPropertyName;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class SelectionBox extends Sprite 
{
	static private var _POOL:Array<SelectionBox> = new Array<SelectionBox>();
	
	static public function fromPool():SelectionBox
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new SelectionBox();
	}
	
	public var pivotX(get, set):Float;
	private var _pivotX:Float = 0;
	private function get_pivotX():Float { return this._pivotX; }
	private function set_pivotX(value:Float):Float
	{
		this._group.x = -value;
		return this._pivotX = value;
	}
	
	public var pivotY(get, set):Float;
	private var _pivotY:Float = 0;
	private function get_pivotY():Float { return this._pivotY; }
	private function set_pivotY(value:Float):Float
	{
		this._group.y = -value;
		return this._pivotY = value;
	}
	
	public var realWidth(get, set):Float;
	private function get_realWidth():Float { return this._group.width; }
	private function set_realWidth(value:Float):Float
	{
		this._group.width = value;
		return value;
	}
	
	public var realHeight(get, set):Float;
	private function get_realHeight():Float { return this._group.height; }
	private function set_realHeight(value:Float):Float
	{
		this._group.height = value;
		return value;
	}
	
	private var _group:SelectionGroup;
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
		
		this._group = new SelectionGroup();
		addChild(this._group);
	}
	
	public function pool():Void
	{
		if (this.parent != null) this.parent.removeChild(this);
		_POOL[_POOL.length] = this;
	}
	
	public function hasInterestIn(regularPropertyName:String):Bool
	{
		return this._interestMap.exists(regularPropertyName);
	}
	
	public function objectUpdate(object:ValEditorObject):Void
	{
		if (object.useBounds)
		{
			var bounds:Rectangle = object.getBounds(object.object.parent);
			this.x = bounds.x;
			this.y = bounds.y;
			
			//var rotation:Float = object.getProperty(RegularPropertyName.ROTATION);
			//object.setProperty(RegularPropertyName.ROTATION, 0.0, true, false);
			//this.rotation = 0;
			
			//refreshShape(bounds.width, bounds.height);
			this.realWidth = bounds.width;
			this.realHeight = bounds.height;
			
			//object.setProperty(RegularPropertyName.ROTATION, rotation, true, false);
			//if (object.hasRadianRotation)
			//{
				//this.rotation = MathUtil.rad2deg(rotation);
			//}
			//else
			//{
				//this.rotation = rotation;
			//}
			
			//this.transform.matrix = object.object.transform.matrix;
		}
		else
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
			
			if (object.hasPivotProperties)
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
			
			var rotation:Float = object.getProperty(RegularPropertyName.ROTATION);
			object.setProperty(RegularPropertyName.ROTATION, 0.0, true, false);
			this.rotation = 0;
			this.realWidth = object.getProperty(RegularPropertyName.WIDTH);
			this.realHeight = object.getProperty(RegularPropertyName.HEIGHT);
			
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
	}
	
}