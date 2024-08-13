package valeditor.ui.feathers.renderers;

import feathers.controls.Label;
import openfl.display.Sprite;
import valeditor.ui.feathers.theme.variant.LabelVariant;

/**
 * ...
 * @author Matse
 */
class SpriteTextRenderer extends Sprite 
{
	static private var _POOL:Array<SpriteTextRenderer> = new Array<SpriteTextRenderer>();
	
	static public function fromPool(width:Float, height:Float):SpriteTextRenderer
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(width, height);
		return new SpriteTextRenderer(width, height);
	}
	
	public var text(get, set):String;
	
	private var _height:Float;
	#if (flash && haxe_ver < 4.3) @:getter(height) #else override #end private function get_height():Float // copied this from Feathers MeasureSprite class - thanks Josh
	{
		return this._height;
	}
	
	#if (flash && haxe_ver < 4.3) @:setter(height) #else override #end private function set_height(value:Float):#if (!flash || haxe_ver >= 4.3) Float #else Void #end // copied this from Feathers MeasureSprite class - thanks Josh
	{
		#if (!flash || haxe_ver >= 4.3)
		return this._height;
		#end
	}
	
	private var _width:Float;
	#if (flash && haxe_ver < 4.3) @:getter(width) #else override #end private function get_width():Float
	{
		return this._width;
	}
	
	#if (flash && haxe_ver < 4.3) @:setter(width) #else override #end private function set_width(value:Float):#if (!flash || haxe_ver >= 4.3) Float #else Void #end
	{
		#if (!flash || haxe_ver >= 4.3)
		return this._width;
		#end
	}
	
	private var _text:String = "";
	private function get_text():String { return this._text; }
	private function set_text(value:String):String
	{
		if (this._text == value) return value;
		
		this._label.text = value;
		if (value != "")
		{
			this._label.validateNow();
			this._label.x = (this._width - this._label.width) / 2;
		}
		
		return this._text = value;
	}
	
	private var _label:Label;
	
	public function new(width:Float, height:Float) 
	{
		super();
		this._width = width;
		this._height = height;
		this._label = new Label();
		this._label.variant = LabelVariant.TIMELINE;
		this._label.mouseEnabled = false;
		this._label.y = -2;
		addChild(this._label);
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(width:Float, height:Float):SpriteTextRenderer
	{
		this._width = width;
		this._height = height;
		return this;
	}
	
}