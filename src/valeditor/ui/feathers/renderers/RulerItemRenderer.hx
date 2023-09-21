package valeditor.ui.feathers.renderers;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.PixelSnapping;
import openfl.display.Sprite;
import openfl.geom.Rectangle;

/**
 * ...
 * @author Matse
 */
class RulerItemRenderer extends Sprite 
{
	static private var _POOL:Array<RulerItemRenderer> = new Array<RulerItemRenderer>();
	
	static public function fromPool(bitmapData:BitmapData, defaultRect:Rectangle, selectedRect:Rectangle):RulerItemRenderer
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new RulerItemRenderer(bitmapData, defaultRect, selectedRect);
	}
	
	public var selected(get, set):Bool;
	
	private var _selected:Bool;
	private function get_selected():Bool { return this._selected; }
	private function set_selected(value:Bool):Bool
	{
		if (value)
		{
			this._bitmap.scrollRect = this._selectedRect;
		}
		else
		{
			this._bitmap.scrollRect = this._defaultRect;
		}
		return this._selected = value;
	}
	
	private var _defaultRect:Rectangle;
	private var _selectedRect:Rectangle;
	
	private var _scrollHeight:Float = 0;
	#if (flash && haxe_ver < 4.3) @:getter(height) #else override #end private function get_height():Float
	{
		return this._scrollHeight;
	}
	
	#if (flash && haxe_ver < 4.3) @:setter(height) #else override #end private function set_height(value:Float):#if (!flash || haxe_ver >= 4.3) Float #else Void #end
	{
		#if (!flash || haxe_ver >= 4.3)
		return this._scrollHeight;
		#end
	}
	
	private var _scrollWidth:Float = 0;
	#if (flash && haxe_ver < 4.3) @:getter(width) #else override #end private function get_width():Float
	{
		return this._scrollWidth;
	}
	
	#if (flash && haxe_ver < 4.3) @:setter(width) #else override #end private function set_width(value:Float):#if (!flash || haxe_ver >= 4.3) Float #else Void #end
	{
		#if (!flash || haxe_ver >= 4.3)
		return this._scrollWidth;
		#end
	}
	
	private var _bitmap:Bitmap;
	
	public function new(bitmapData:BitmapData, defaultRect:Rectangle, selectedRect:Rectangle)
	{
		super();
		this._bitmap = new Bitmap(bitmapData, PixelSnapping.AUTO);
		addChild(this._bitmap);
		this._defaultRect = defaultRect;
		this._selectedRect = selectedRect;
		
		this._scrollHeight = defaultRect.height;
		this._scrollWidth = defaultRect.width;
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
}