package ui.shape;

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
	
	static public function fromPool():PivotIndicator
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new PivotIndicator();
	}
	
	static public function toPool(pivot:PivotIndicator):Void
	{
		_POOL.push(pivot);
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
		
		var left:Float = -4;
		var right:Float = 5;
		var top:Float = -4;
		var bottom:Float = 5;
		
		this.graphics.beginFill(0xffffff, 0);
		// white lines
		this.graphics.lineStyle(1, 0xffffff);
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
		this.graphics.lineStyle(1, 0x000000);
		this.graphics.moveTo(left, 0.5);
		this.graphics.lineTo(right, 0.5);
		this.graphics.moveTo(0.5, top);
		this.graphics.lineTo(0.5, bottom);
		this.graphics.endFill();
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
	
	public function pool():Void
	{
		toPool(this);
	}
	
}