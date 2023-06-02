package valeditor.ui.feathers.theme.flatcolor.settings;
import feathers.text.TextFormat;
import openfl.text.TextFormatAlign;


/**
 * ...
 * @author Matse
 */
class TextSettings extends BaseSettings 
{
	public var fontName(get, set):String;
	public var fontSize(get, set):Int;
	public var alignDefault(get, set):TextFormatAlign;
	public var bold(get, set):Bool;
	public var italic(get, set):Bool;
	public var underline(get, set):Bool;
	public var color(get, set):Int;
	
	private var _fontName:String;
	private function get_fontName():String { return _fontName; }
	private function set_fontName(value:String):String
	{
		if (_fontName == value) return value;
		_fontName = value;
		dispatchChange();
		return _fontName;
	}
	
	private var _fontSize:Int;
	private function get_fontSize():Int { return _fontSize; }
	private function set_fontSize(value:Int):Int
	{
		if (_fontSize == value) return value;
		_fontSize = value;
		dispatchChange();
		return _fontSize;
	}
	
	private var _alignDefault:TextFormatAlign = TextFormatAlign.LEFT;
	private function get_alignDefault():TextFormatAlign { return _alignDefault; }
	private function set_alignDefault(value:TextFormatAlign):TextFormatAlign
	{
		if (_alignDefault == value) return value;
		_alignDefault = value;
		dispatchChange();
		return _alignDefault;
	}
	
	private var _bold:Bool;
	private function get_bold():Bool { return _bold; }
	private function set_bold(value:Bool):Bool
	{
		if (_bold == value) return value;
		_bold = value;
		dispatchChange();
		return _bold;
	}
	
	private var _italic:Bool;
	private function get_italic():Bool { return _italic; }
	private function set_italic(value:Bool):Bool
	{
		if (_italic == value) return value;
		_italic = value;
		dispatchChange();
		return _italic;
	}
	
	private var _underline:Bool;
	private function get_underline():Bool { return _underline; }
	private function set_underline(value:Bool):Bool
	{
		if (_underline == value) return value;
		_underline = value;
		dispatchChange();
		return _underline;
	}
	
	private var _color:Int;
	private function get_color():Int { return _color; }
	private function set_color(value:Int):Int
	{
		if (_color == value) return value;
		_color = value;
		dispatchChange();
		return _color;
	}
	
	public function new() 
	{
		super();
		
	}
	
	public function copy(settings:TextSettings):Void
	{
		_fontName = settings.fontName;
		_fontSize = settings.fontSize;
		_alignDefault = settings.alignDefault;
		_bold = settings.bold;
		_italic = settings.italic;
		_underline = settings.underline;
		_color = settings.color;
	}
	
	public function getTextFormat(?align:TextFormatAlign):TextFormat
	{
		if (align == null) align = _alignDefault;
		return new TextFormat(_fontName, _fontSize, _color, _bold, _italic, _underline, null, null, align);
	}
	
}