package valeditor.ui.feathers.renderers;

import feathers.controls.Label;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;

/**
 * ...
 * @author Matse
 */
class BitmapRenderer extends Bitmap 
{
	static private var _POOL:Array<BitmapRenderer> = new Array<BitmapRenderer>();
	
	static public function fromPool(bmd:BitmapData):BitmapRenderer
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(bmd);
		return new BitmapRenderer(bmd);
	}
	
	public function new(bmd:BitmapData) 
	{
		super(bmd);
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(bmd:BitmapData):BitmapRenderer
	{
		this.bitmapData = bmd;
		return this;
	}
	
}