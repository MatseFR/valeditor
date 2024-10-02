package valeditor.ui;

#if starling
import openfl.geom.Rectangle;
import starling.display.Quad;
import valedit.utils.RegularPropertyName;
import valeditor.ValEditorObject;
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
	
	public var debug(get, set):Bool;
	public var debugAlpha(get, set):Float;
	public var debugColor(get, set):Int;
	public var minHeight(get, set):Float;
	public var minWidth(get, set):Float;
	public var visibilityLocked:Bool;
	
	private var _debug:Bool = false;
	private function get_debug():Bool { return this._debug; }
	private function set_debug(value:Bool):Bool
	{
		if (this._debug == value) return value;
		this._debug = value;
		if (this._debug)
		{
			this.alpha = this._debugAlpha;
			this.color = this._debugColor;
		}
		else
		{
			this.alpha = 0.0;
			this.color = this._debugColor;
		}
		return this._debug;
	}
	
	private var _debugAlpha:Float = 0.25;
	private function get_debugAlpha():Float { return this._debugAlpha; }
	private function set_debugAlpha(value:Float):Float
	{
		if (this._debugAlpha == value) return value;
		this._debugAlpha = value;
		if (this._debug)
		{
			this.alpha = this._debugAlpha;
		}
		return this._debugAlpha;
	}
	
	private var _debugColor:Int = 0xff0000;
	private function get_debugColor():Int { return this._debugColor; }
	private function set_debugColor(value:Int):Int
	{
		if (this._debugColor == value) return value;
		this._debugColor = value;
		this.color = this._debugColor;
		return this._debugColor;
	}
	
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
	private var _object:ValEditorObject;
	
	public function new(?minWidth:Float, ?minHeight:Float) 
	{
		super(1, 1, this._debugColor);
		this.alpha = 0.0;
		
		this._interestMap = new Map<String, Bool>();
		this._interestMap.set(RegularPropertyName.X, true);
		this._interestMap.set(RegularPropertyName.Y, true);
		this._interestMap.set(RegularPropertyName.PIVOT_X, true);
		this._interestMap.set(RegularPropertyName.PIVOT_Y, true);
		this._interestMap.set(RegularPropertyName.ROTATION, true);
		this._interestMap.set(RegularPropertyName.SCALE_X, true);
		this._interestMap.set(RegularPropertyName.SCALE_Y, true);
		this._interestMap.set(RegularPropertyName.SKEW_X, true);
		this._interestMap.set(RegularPropertyName.SKEW_Y, true);
		this._interestMap.set(RegularPropertyName.WIDTH, true);
		this._interestMap.set(RegularPropertyName.HEIGHT, true);
		this._interestMap.set(RegularPropertyName.VISIBLE, true);
		
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
		this.removeFromParent();
		clear();
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
				#if starling
				if (this._object.isDisplayObject && this._object.isDisplayObjectStarling)
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
				#end
					this.pivotX = -bounds.x * Math.abs(scaleX);
					this.pivotY = -bounds.y * Math.abs(scaleY);
					
					this.x = this._object.getProperty(RegularPropertyName.X);
					this.y = this._object.getProperty(RegularPropertyName.Y);
				#if starling
				}
				#end
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
			
			readjustSize(width, height);
			
			if (this._object.hasProperty(RegularPropertyName.SKEW_X))
			{
				this.skewX = this._object.getProperty(RegularPropertyName.SKEW_X);
				this.skewY = this._object.getProperty(RegularPropertyName.SKEW_Y);
			}
			else
			{
				this.skewX = 0;
				this.skewY = 0;
			}
			
			if (this._object.hasProperty(RegularPropertyName.ROTATION))
			{
				var rotation:Float = this._object.getProperty(RegularPropertyName.ROTATION);
				if (this._object.hasRadianRotation)
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
				this.rotation = 0;
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
				this.scale = 1;
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
			
			readjustSize(width, height);
			
			if (this._object.hasProperty(RegularPropertyName.SKEW_X))
			{
				this.skewX = this._object.getProperty(RegularPropertyName.SKEW_X);
				this.skewY = this._object.getProperty(RegularPropertyName.SKEW_Y);
			}
			else
			{
				this.skewX = 0;
				this.skewY = 0;
			}
			
			if (this._object.hasProperty(RegularPropertyName.ROTATION))
			{
				this._object.setProperty(RegularPropertyName.ROTATION, rotation, true, false);
				if (this._object.hasRadianRotation)
				{
					this.rotation = rotation;
				}
				else
				{
					this.rotation = MathUtil.deg2rad(rotation);
				}
			}
		}
		
		if (!this.visibilityLocked && this._object.hasVisibleProperty)
		{
			this.visible = this._object.getProperty(RegularPropertyName.VISIBLE);
		}
	}
	
}
#end