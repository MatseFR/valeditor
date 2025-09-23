package valeditor.editor.settings;
#if starling
import starling.core.Starling;

/**
 * ...
 * @author Matse
 */
class StarlingSettings 
{
	/** 0-16 **/
	public var antiAliasing(get, set):Int;
	/** 0-Pi **/
	public var fieldOfView(get, set):Float;
	
	private var _antiAliasing:Int = 0;
	private function get_antiAliasing():Int { return this._antiAliasing; }
	private function set_antiAliasing(value:Int):Int
	{
		return this._antiAliasing = value;
	}
	
	private var _fieldOfView:Float = 1.0;
	private function get_fieldOfView():Float { return this._fieldOfView; }
	private function set_fieldOfView(value:Float):Float
	{
		return this._fieldOfView = value;
	}
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.antiAliasing = 0;
		this.fieldOfView = 1.0;
	}
	
	public function apply():Void
	{
		Starling.current.antiAliasing = this.antiAliasing;
		Starling.current.stage.fieldOfView = this.fieldOfView;
	}
	
	public function clone(toSettings:StarlingSettings):Void
	{
		toSettings.antiAliasing = this.antiAliasing;
		toSettings.fieldOfView = this.fieldOfView;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.antiAliasing = json.antiAliasing;
		this.fieldOfView = json.fieldOfView;
	}
	
	public function toJSON(?json:Dynamic):Dynamic
	{
		if (json == null) json = {};
		
		json.antiAliasing = this.antiAliasing;
		json.fieldOfView = this.fieldOfView;
		
		return json;
	}
	
}
#end