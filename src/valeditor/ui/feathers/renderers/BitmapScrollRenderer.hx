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
class BitmapScrollRenderer extends Sprite 
{
	static private var _POOL:Array<BitmapScrollRenderer> = new Array<BitmapScrollRenderer>();
	
	static public function fromPool(bitmapData:BitmapData, rectMap:Map<FrameItemState, Rectangle>):BitmapScrollRenderer
	{
		if (_POOL.length != 0) return _POOL.pop().reset();
		return new BitmapScrollRenderer(bitmapData, rectMap);
	}
	
	public var rectMap:Map<FrameItemState, Rectangle>;
	public var state(get, set):#if flash Dynamic #else FrameItemState #end;
	
	private var _state:FrameItemState;
	private function get_state():#if flash Dynamic #else FrameItemState #end { return this._state; }
	private function set_state(value:#if flash Dynamic #else FrameItemState #end):#if flash Dynamic #else FrameItemState #end
	{
		if (this._state == value) return value;
		this.scrollRect = this.rectMap.get(value);
		if (this.scrollRect != null)
		{
			this._scrollHeight = this.scrollRect.height;
			this._scrollWidth = this.scrollRect.width;
		}
		return this._state = value;
	}
	
	private var _scrollHeight:Float = 0;
	#if (flash && haxe_ver < 4.3) @:getter(height) #else override #end private function get_height():Float
	{
		return this._scrollHeight;
	}
	
	private var _scrollWidth:Float = 0;
	#if (flash && haxe_ver < 4.3) @:getter(width) #else override #end private function get_width():Float
	{
		return this._scrollWidth;
	}
	
	private var _bitmap:Bitmap;
	
	public function new(bitmapData:BitmapData, rectMap:Map<FrameItemState, Rectangle>) 
	{
		super();
		this._bitmap = new Bitmap(bitmapData, PixelSnapping.AUTO);
		addChild(this._bitmap);
		this.rectMap = rectMap;
		this.state = FrameItemState.FRAME(false);
	}
	
	public function pool():Void
	{
		// TODO : pooling disabled for now, need to investigate scrollRect glitches (at least on flash target)
		//this.scrollRect = null;
		//this._state = null;
		//_POOL[_POOL.length] = this;
	}
	
	private function reset():BitmapScrollRenderer
	{
		this.state = FrameItemState.FRAME(false);
		return this;
	}
	
}