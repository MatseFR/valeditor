package valeditor.editor.settings;
import haxe.io.Path;

/**
 * ...
 * @author Matse
 */
class ExportSettings 
{
	public var exportAssets:Bool;
	public var fileName:String;
	public var fullPath(get, set):String;
	public var path:String;
	public var useSimpleJSON:Bool;
	public var useZip:Bool #if !desktop = true#end;
	
	private var _fullPath:String;
	private function get_fullPath():String { return this._fullPath; }
	private function set_fullPath(value:String):String
	{
		if (value == null)
		{
			this.fileName = null;
			this.path = null;
		}
		else
		{
			this.fileName = Path.withoutDirectory(value);
			this.path = Path.directory(value);
		}
		return this._fullPath = value;
	}

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.exportAssets = false;
		this.fullPath = null;
		this.useSimpleJSON = false;
		#if desktop
		this.useZip = false;
		#end
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.exportAssets = json.exportAssets;
		this.fileName = json.fileName;
		this.path = json.path;
		this.useSimpleJSON = json.useSimpleJSON;
		this.useZip = json.useZip;
	}
	
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.exportAssets = this.exportAssets;
		json.fileName = this.fileName;
		json.path = this.path;
		json.useSimpleJSON = this.useSimpleJSON;
		json.useZip = this.useZip;
		
		return json;
	}
	
}