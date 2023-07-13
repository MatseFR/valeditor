package valeditor.ui;

import starling.display.Quad;
import starling.display.Sprite3D;
import valedit.util.RegularPropertyName;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectStarling3D extends Sprite3D implements IInteractiveObject
{
	static private var _POOL:Array<InteractiveObjectStarling3D> = new Array<InteractiveObjectStarling3D>();
	
	static public function fromPool(?minWidth:Float, ?minHeight:Float):InteractiveObjectStarling3D
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(minWidth, minHeight);
		return new InteractiveObjectStarling3D(minWidth, minHeight);
	}
	
	public var minWidth(get, set):Float;
	private var _minWidth:Float;
	private function get_minWidth():Float { return this._minWidth; }
	private function set_minWidth(value:Float):Float
	{
		if (this._minWidth == value) return value;
		this._minWidth = value;
		if (this._quad.width < this._minWidth)
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
		if (this._minHeight == value) return value;
		this._minHeight = value;
		if (this._quad.height < this._minHeight)
		{
			this.height = this._minHeight;
		}
		return this._minHeight;
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
	
	public function new(?minWidth:Float, ?minHeight:Float) 
	{
		super();
		
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
		this._interestMap.set(RegularPropertyName.VISIBLE, true);
		
		this._quad = new Quad(1, 1, 0xff0000);
		this._quad.alpha = 0.25;
		addChild(this._quad);
		
		setTo(minWidth, minHeight);
	}
	
	public function pool():Void
	{
		this.removeFromParent();
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(?minWidth:Float, ?minHeight:Float):InteractiveObjectStarling3D
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
		
		if (object.hasScaleProperties)
		{
			var scaleX:Float = object.getProperty(RegularPropertyName.SCALE_X);
			var scaleY:Float = object.getProperty(RegularPropertyName.SCALE_Y);
			var scaleZ:Float = object.getProperty(RegularPropertyName.SCALE_Z);
			
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
			
			if (scaleZ < 0)
			{
				this.scaleZ = -1;
			}
			else
			{
				this.scaleZ = 1;
			}
		}
		else
		{
			this.scale = 1;
			this.scaleZ = 1;
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
		
		var width:Float = object.getProperty(RegularPropertyName.WIDTH);
		if (width < this._minWidth) width = this._minWidth;
		var height:Float = object.getProperty(RegularPropertyName.HEIGHT);
		if (height < this._minHeight) height = this._minHeight;
		
		this._quad.readjustSize(width, height);
		
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
		
		if (object.hasVisibleProperty)
		{
			this.visible = object.getProperty(RegularPropertyName.VISIBLE);
		}
	}
	
}