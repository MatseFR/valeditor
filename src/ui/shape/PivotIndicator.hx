package ui.shape;

import openfl.display.Shape;

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
	
	public function new() 
	{
		super();
		this.graphics.beginFill(0xffffff, 0);
		this.graphics.lineStyle(3, 0xffffff);
		this.graphics.moveTo( -7, 0.5);
		this.graphics.lineTo(7, 0.5);
		this.graphics.moveTo(0.5, -7);
		this.graphics.lineTo(0.5, 7);
		
		this.graphics.lineStyle(1, 0x000000);
		this.graphics.moveTo(0.5, -8);
		this.graphics.lineTo(0.5, 8);
		this.graphics.moveTo( -8, 0.5);
		this.graphics.lineTo(8, 0.5);
		this.graphics.endFill();
	}
	
}