package valeditor.ui.shape;

import openfl.display.Shape;
import valedit.ValEditObject;
import valedit.utils.RegularPropertyName;

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
		
		setTo(size, color, alpha, outlineColor, outlineAlpha);
	}
	
	public function pool():Void
	{
		if (this.parent != null) this.parent.removeChild(this);
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(size:Float, color:Int, alpha:Float, outlineColor:Int, outlineAlpha:Float):PivotIndicator
	{
		var left:Float = -(size-1);
		var top:Float = -(size-1);
		
		this.graphics.beginFill(color, alpha);
		this.graphics.drawRect(left, 0, size * 2 - 1, 1);
		this.graphics.drawRect(0, top, 1, size - 1);
		this.graphics.drawRect(0, 1, 1, size - 1);
		
		this.graphics.beginFill(outlineColor, outlineAlpha);
		this.graphics.drawRect(left, -1, size - 1, 1);
		this.graphics.drawRect(left, 1, size -1, 1);
		this.graphics.drawRect(1, -1, size - 1, 1);
		this.graphics.drawRect(1, 1, size - 1, 1);
		this.graphics.drawRect(-1, top, 1, size - 1);
		this.graphics.drawRect(1, top, 1, size - 1);
		this.graphics.drawRect(-1, 1, 1, size - 1);
		this.graphics.drawRect(1, 1, 1, size - 1);
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