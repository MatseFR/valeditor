package valeditor.ui.feathers.controls;

import feathers.controls.Button;
import feathers.controls.LayoutGroup;
import feathers.layout.AnchorLayout;
import feathers.layout.AnchorLayoutData;
import openfl.display.Sprite;
import valedit.utils.RegularPropertyName;
import valeditor.ui.UIConfig;
import valeditor.utils.MathUtil;

/**
 * ...
 * @author Matse
 */
class TransformBox extends Sprite 
{
	static private var _POOL:Array<TransformBox> = new Array<TransformBox>();
	
	static public function fromPool():TransformBox
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new TransformBox();
	}
	
	static public function toPool(box:TransformBox):Void
	{
		_POOL.push(box);
	}
	
	public var pivotX(get, set):Float;
	private var _pivotX:Float = 0;
	private function get_pivotX():Float { return this._pivotX; }
	private function set_pivotX(value:Float):Float
	{
		this._mainGroup.x = -value;
		return this._pivotX = value;
	}
	
	public var pivotY(get, set):Float;
	private var _pivotY:Float = 0;
	private function get_pivotY():Float { return this._pivotY; }
	private function set_pivotY(value:Float):Float
	{
		this._mainGroup.y = -value;
		return this._pivotY = value;
	}
	
	public var realWidth(get, set):Float;
	private function get_realWidth():Float { return this._selectionGroup.width; }
	private function set_realWidth(value:Float):Float
	{
		this._selectionGroup.width = value;
		return value;
	}
	
	public var realHeight(get, set):Float;
	private function get_realHeight():Float { return this._selectionGroup.height; }
	private function set_realHeight(value:Float):Float
	{
		this._selectionGroup.height = value;
		return value;
	}
	
	private var _mainGroup:LayoutGroup;
	private var _selectionGroup:SelectionGroup;
	
	private var _scaleTopLeftButton:Button;
	private var _scaleTopButton:Button;
	private var _scaleTopRightButton:Button;
	
	private var _scaleLeftButton:Button;
	private var _scaleRightButton:Button;
	
	private var _scaleBottomLeftButton:Button;
	private var _scaleBottomButton:Button;
	private var _scaleBottomRightButton:Button;
	
	private var _rotateTopLeftButton:Button;
	private var _rotateTopRightButton:Button;
	private var _rotateBottomLeftButton:Button;
	private var _rotateBottomRightButton:Button;
	
	private var _interestMap:Map<String, Bool> = new Map<String, Bool>();

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
		
		this._mainGroup = new LayoutGroup();
		this._mainGroup.layout = new AnchorLayout();
		addChild(this._mainGroup);
		
		this._selectionGroup = new SelectionGroup();
		this._selectionGroup.layoutData = AnchorLayoutData.center();
		this._mainGroup.addChild(this._selectionGroup);
		
		this._scaleTopLeftButton = new Button();
		this._scaleTopLeftButton.layoutData = AnchorLayoutData.topLeft( -UIConfig.TRANSFORM_BUTTONS_SIZE / 2, -UIConfig.TRANSFORM_BUTTONS_SIZE / 2);
		this._mainGroup.addChild(this._scaleTopLeftButton);
		
		this._scaleTopButton = new Button();
		this._scaleTopButton.layoutData = AnchorLayoutData.topCenter();
		this._mainGroup.addChild(this._scaleTopButton);
		
		this._scaleTopRightButton = new Button();
		this._scaleTopRightButton.layoutData = AnchorLayoutData.topRight();
		this._mainGroup.addChild(this._scaleTopRightButton);
		
		this._scaleLeftButton = new Button();
		this._scaleLeftButton.layoutData = AnchorLayoutData.middleLeft();
		this._mainGroup.addChild(this._scaleLeftButton);
		
		this._scaleRightButton = new Button();
		this._scaleRightButton.layoutData = AnchorLayoutData.middleRight();
		this._mainGroup.addChild(this._scaleRightButton);
		
		this._scaleBottomLeftButton = new Button();
		this._scaleBottomLeftButton.layoutData = AnchorLayoutData.bottomLeft();
		this._mainGroup.addChild(this._scaleBottomLeftButton);
		
		this._scaleBottomButton = new Button();
		this._scaleBottomButton.layoutData = AnchorLayoutData.bottomCenter();
		this._mainGroup.addChild(this._scaleBottomButton);
		
		this._scaleBottomRightButton = new Button();
		this._scaleBottomRightButton.layoutData = AnchorLayoutData.bottomRight();
		
		
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
	
	public function pool():Void
	{
		toPool(this);
	}
	
}