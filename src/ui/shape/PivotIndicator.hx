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
		this.graphics.moveTo( -5, 0.5);
		this.graphics.lineTo(5, 0.5);
		this.graphics.moveTo(0.5, -5);
		this.graphics.lineTo(0.5, 5);
		
		this.graphics.lineStyle(1, 0x000000);
		this.graphics.moveTo(0.5, -6);
		this.graphics.lineTo(0.5, 6);
		this.graphics.moveTo( -6, 0.5);
		this.graphics.lineTo(6, 0.5);
		this.graphics.endFill();
	}
	
}