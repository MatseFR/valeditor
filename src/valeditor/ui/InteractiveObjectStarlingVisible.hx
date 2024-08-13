package valeditor.ui;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.MathUtil;
import valedit.DisplayObjectType;
import valedit.utils.RegularPropertyName;
import valeditor.ValEditorObject;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectStarlingVisible extends Sprite implements IInteractiveObject
{
	static public var LINE_BMD:BitmapData;
	static public var LINE_TEX:Texture;
	
	static private var _IS_SETUP:Bool = false;
	static private var _POOL:Array<InteractiveObjectStarlingVisible> = new Array<InteractiveObjectStarlingVisible>();
	
	static public function setup():Void
	{
		if (_IS_SETUP) return;
		
		LINE_BMD = new BitmapData(4, 1, true, 0x00ffffff);
		LINE_BMD.setPixel32(0, 0, 0xff000000);
		LINE_BMD.setPixel32(1, 0, 0xff000000);
		LINE_BMD.setPixel32(2, 0, 0xffffffff);
		LINE_BMD.setPixel32(3, 0, 0xffffffff);
		
		LINE_TEX = Texture.fromBitmapData(LINE_BMD, false);
		
		_IS_SETUP = true;
	}
	
	static public function fromPool(?minWidth:Float, ?minHeight:Float):InteractiveObjectStarlingVisible
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(minWidth, minHeight);
		return new InteractiveObjectStarlingVisible(minWidth, minHeight);
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
			this._quad.alpha = this._debugAlpha;
			this._quad.color = this._debugColor;
		}
		else
		{
			this._quad.alpha = 0.0;
			this._quad.color = this._debugColor;
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
			this._quad.alpha = this._debugAlpha;
		}
		return this._debugAlpha;
	}
	
	private var _debugColor:Int = 0xff0000;
	private function get_debugColor():Int { return this._debugColor; }
	private function set_debugColor(value:Int):Int
	{
		if (this._debugColor == value) return value;
		this._debugColor = value;
		this._quad.color = this._debugColor;
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
		refresh(this.width, value);
		return value;
	}
	
	//@:setter(width)
	override function set_width(value:Float):Float 
	{
		refresh(value, this.height);
		return value;
	}
	
	private var _interestMap:Map<String, Bool>;
	private var _object:ValEditorObject;
	private var _leftImg:Image;
	private var _rightImg:Image;
	private var _topImg:Image;
	private var _bottomImg:Image;
	private var _quad:Quad;
	
	private var _baseSize:Float;
	
	public function new(?minWidth:Float, ?minHeight:Float) 
	{
		super();
		
		this.touchGroup = true;
		
		if (!_IS_SETUP) setup();
		
		this._baseSize = LINE_BMD.width;
		
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
		
		this._leftImg = new Image(LINE_TEX);
		this._leftImg.tileGrid = new Rectangle();
		this._leftImg.rotation = MathUtil.deg2rad(90);
		addChild(this._leftImg);
		
		this._rightImg = new Image(LINE_TEX);
		this._rightImg.tileGrid = new Rectangle();
		this._rightImg.rotation = MathUtil.deg2rad(90);
		addChild(this._rightImg);
		
		this._topImg = new Image(LINE_TEX);
		this._topImg.tileGrid = new Rectangle();
		//this._topImg.rotation = MathUtil.deg2rad(90);
		addChild(this._topImg);
		
		this._bottomImg = new Image(LINE_TEX);
		this._bottomImg.tileGrid = new Rectangle();
		//this._bottomImg.rotation = MathUtil.deg2rad(90);
		addChild(this._bottomImg);
		
		this._quad = new Quad(10, 10, this._debugColor);
		this._quad.alpha = 0.0;
		addChild(this._quad);
		
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
	
	private function setTo(?minWidth:Float, ?minHeight:Float):InteractiveObjectStarlingVisible
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
			
			if (width < this._minWidth) width = this._minWidth;
			if (height < this._minHeight) height = this._minHeight;
			
			refresh(width, height);
			
			if (this._object.getProperty(RegularPropertyName.ROTATION))
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
			
			var rotation:Float = 0;
			if (this._object.hasProperty(RegularPropertyName.ROTATION))
			{
				rotation = this._object.getProperty(RegularPropertyName.ROTATION);
				object.setProperty(RegularPropertyName.ROTATION, 0.0, true, false);
			}
			this.rotation = 0;
			
			var width:Float = this._object.getProperty(RegularPropertyName.WIDTH);
			if (width < this._minWidth) width = this._minWidth;
			var height:Float = this._object.getProperty(RegularPropertyName.HEIGHT);
			if (height < this._minHeight) height = this._minHeight;
			
			refresh(width, height);
			
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
	
	private function refresh(width:Float, height:Float):Void
	{
		this._quad.width = width;
		this._quad.height = height;
		
		var widthScale:Float = width / this._baseSize;
		var heightScale:Float = height / this._baseSize;
		
		this._leftImg.scaleX = heightScale;
		this._rightImg.scaleX = heightScale;
		this._topImg.scaleX = widthScale;
		this._bottomImg.scaleX = widthScale;
		
		this._rightImg.x = width;
		this._bottomImg.y = height;
	}
	
}