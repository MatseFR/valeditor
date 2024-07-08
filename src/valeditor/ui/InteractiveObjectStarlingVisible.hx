package valeditor.ui;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import starling.display.Image;
import starling.display.Quad;
import starling.display.Sprite;
import starling.textures.Texture;
import starling.utils.MathUtil;
import valedit.utils.RegularPropertyName;

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
		
		this._quad = new Quad(10, 10, 0xff0000);
		this._quad.alpha = 0.0;
		addChild(this._quad);
		
		setTo(minWidth, minHeight);
	}
	
	public function pool():Void
	{
		this.removeFromParent();
		this.visibilityLocked = false;
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
			
			refresh(width, height);
			
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
			
			refresh(width, height);
			
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