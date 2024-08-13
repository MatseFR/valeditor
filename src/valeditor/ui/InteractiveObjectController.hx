package valeditor.ui;

/**
 * ...
 * @author Matse
 */
class InteractiveObjectController 
{
	public var debug(get, set):Bool;
	public var debugAlpha(get, set):Float;
	public var debugColor(get, set):Int;
	
	private var _debug:Bool = false;
	private function get_debug():Bool { return this._debug; }
	private function set_debug(value:Bool):Bool
	{
		if (this._debug == value) return value;
		
		for (object in this._objects)
		{
			object.debug = value;
		}
		return this._debug = value;
	}
	
	private var _debugAlpha:Float = 0.25;
	private function get_debugAlpha():Float { return this._debugAlpha; }
	private function set_debugAlpha(value:Float):Float
	{
		if (this._debugAlpha == value) return value;
		
		for (object in this._objects)
		{
			object.debugAlpha = value;
		}
		return this._debugAlpha = value;
	}
	
	private var _debugColor:Int = 0xff0000;
	private function get_debugColor():Int { return this._debugColor; }
	private function set_debugColor(value:Int):Int
	{
		if (this._debugColor == value) return value;
		
		for (object in this._objects)
		{
			object.debugColor = value;
		}
		return this._debugColor = value;
	}
	
	private var _objects:Array<IInteractiveObject> = new Array<IInteractiveObject>();

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._objects.resize(0);
	}
	
	public function register(object:IInteractiveObject):Void
	{
		object.debug = this.debug;
		object.debugAlpha = this.debugAlpha;
		object.debugColor = this.debugColor;
		this._objects[this._objects.length] = object;
	}
	
	public function unregister(object:IInteractiveObject):Void
	{
		this._objects.remove(object);
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.debug = json.debug;
		this.debugAlpha = json.debugAlpha;
		this.debugColor = json.debugColor;
	}
	
	public function toJSON(?json:Dynamic):Dynamic
	{
		if (json == null) json = {};
		
		json.debug = this.debug;
		json.debugAlpha = this.debugAlpha;
		json.debugColor = this.debugColor;
		
		return json;
	}
	
}