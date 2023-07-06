package valeditor.ui.shape;

import openfl.display.Shape;
import valedit.ValEditObject;
import valedit.util.RegularPropertyName;

/**
 * ...
 * @author Matse
 */
class PivotIndicator extends Shape 
{
	static private var _POOL:Array<PivotIndicator> = new Array<PivotIndicator>();
	
	static public function fromPool(size:Float = 5, color:Int = 0x000000, alpha:Float = 1, outlineColor:Int = 0xffffff, outlineAlpha:Float = 1):PivotIndicator
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(size, color, alpha, outlineColor, outlineAlpha);
		return new PivotIndicator(size, color, alpha, outlineColor, outlineAlpha);
	}
	
	private var _interestMap:Map<String, Bool>;
	
	public function new(size:Float = 5, color:Int = 0x000000, alpha:Float = 1, outlineColor:Int = 0xffffff, outlineAlpha:Float = 1) 
	{
		super();
		
		this._interestMap = new Map<String, Bool>();
		this._interestMap.set(RegularPropertyName.X, true);
		this._interestMap.set(RegularPropertyName.Y, true);
		this._interestMap.set(RegularPropertyName.PIVOT_X, true);
		this._interestMap.set(RegularPropertyName.PIVOT_Y, true);
		
		this.setTo(size, color, alpha, outlineColor, outlineAlpha);
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(size:Float, color:Int, alpha:Float, outlineColor:Int, outlineAlpha:Float):PivotIndicator
	{
		var left:Float = -(size-1);
		var right:Float = size;
		var top:Float = -(size-1);
		var bottom:Float = size;
		
		this.graphics.beginFill(0xffffff, 0);
		// white lines
		this.graphics.lineStyle(1, outlineColor, outlineAlpha);
		this.graphics.moveTo( left, -0.5);
		this.graphics.lineTo( -0.5, -0.5);
		this.graphics.moveTo( -0.5, -0.5);
		this.graphics.lineTo( -0.5, top);
		this.graphics.moveTo( left, 1.5);
		this.graphics.lineTo( -0.5, 1.5);
		this.graphics.moveTo( -0.5, 1.5);
		this.graphics.lineTo( -0.5, bottom);
		this.graphics.moveTo( right, -0.5);
		this.graphics.lineTo(1.5, -0.5);
		this.graphics.moveTo(1.5, -0.5);
		this.graphics.lineTo(1.5, top);
		this.graphics.moveTo( right, 1.5);
		this.graphics.lineTo(1.5, 1.5);
		this.graphics.moveTo(1.5, 1.5);
		this.graphics.lineTo(1.5, bottom);
		this.graphics.moveTo(1.5, bottom);
		// black lines
		this.graphics.lineStyle(1, color, alpha);
		this.graphics.moveTo(left, 0.5);
		this.graphics.lineTo(right, 0.5);
		this.graphics.moveTo(0.5, top);
		this.graphics.lineTo(0.5, bottom);
		this.graphics.endFill();
		
		return this;
	}
	
	public function hasInterestIn(regularPropertyName:String):Bool
	{
		return this._interestMap.exists(regularPropertyName);
	}
	
	public function objectUpdate(object:ValEditObject):Void
	{
		this.x = object.getProperty(RegularPropertyName.X);
		this.y = object.getProperty(RegularPropertyName.Y);
	}
	
}