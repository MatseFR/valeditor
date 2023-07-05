package valeditor.ui.feathers.data;

/**
 * ...
 * @author Matse
 */
class StringData 
{
	static private var _POOL:Array<StringData> = new Array<StringData>();
	
	static public function fromPool(value:String):StringData
	{
		if (_POOL.length != 0) return _POOL.pop().setTo(value);
		return new StringData(value);
	}
	
	static public function poolArray(datas:Array<StringData>):Void
	{
		for (data in datas)
		{
			data.pool();
		}
	}
	
	public var value:String;

	public function new(value:String) 
	{
		this.value = value;
	}
	
	public function setTo(value:String):StringData
	{
		this.value = value;
		return this;
	}
	
	public function pool():Void
	{
		this.value = null;
		_POOL[_POOL.length] = this;
	}
	
}