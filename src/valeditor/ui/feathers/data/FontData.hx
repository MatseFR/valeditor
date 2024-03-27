package valeditor.ui.feathers.data;
import openfl.text.FontType;

/**
 * ...
 * @author Matse
 */
class FontData 
{
	static private var _POOL:Array<FontData> = new Array<FontData>();
	
	static public function fromPool(displayName:String, fontName:String, fontType:FontType):FontData
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(displayName, fontName, fontType);
		return new FontData(displayName, fontName, fontType);
	}
	
	static public function poolArray(datas:Array<FontData>):Void
	{
		for (data in datas)
		{
			data.pool();
		}
	}
	
	public var displayName(default, null):String;
	public var fontName(default, null):String;
	public var fontType(default, null):FontType;
	
	public function new(displayName:String, fontName:String, fontType:FontType) 
	{
		this.displayName = displayName;
		this.fontName = fontName;
		this.fontType = fontType;
	}
	
	public function pool():Void
	{
		_POOL[_POOL.length] = this;
	}
	
	private function setTo(displayName:String, fontName:String, fontType:FontType):FontData
	{
		this.displayName = displayName;
		this.fontName = fontName;
		this.fontType = fontType;
		return this;
	}
	
}