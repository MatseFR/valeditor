package valeditor.editor.settings;
import haxe.io.Path;

/**
 * ...
 * @author Matse
 */
class ExportSettings 
{
	static private var _POOL:Array<ExportSettings> = new Array<ExportSettings>();
	
	static public function fromPool():ExportSettings
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ExportSettings();
	}
	
	public var compress:Bool;
	public var exportAssets:Bool;
	public var fileName:String;
	public var filePath:String;
	public var fullPath(get, set):String;
	public var useSimpleJSON:Bool;
	public var useZip:Bool #if !desktop = true#end;
	
	private var _fullPath:String;
	private function get_fullPath():String { return this._fullPath; }
	private function set_fullPath(value:String):String
	{
		if (value == null)
		{
			this.fileName = null;
			this.filePath = null;
		}
		else
		{
			this.fileName = Path.withoutDirectory(value);
			this.filePath = Path.directory(value);
		}
		return this._fullPath = value;
	}

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.compress = false;
		this.exportAssets = false;
		this.fullPath = null;
		this.useSimpleJSON = false;
		#if desktop
		this.useZip = false;
		#end
	}
	
	public function pool():Void
	{
		clear();
		_POOL.push(this);
	}
	
	public function clone(toSettings:ExportSettings = null):ExportSettings
	{
		if (toSettings == null) toSettings = fromPool();
		
		toSettings.compress = this.compress;
		toSettings.exportAssets = this.exportAssets;
		toSettings.fileName = this.fileName;
		toSettings.filePath = this.filePath;
		toSettings.useSimpleJSON = this.useSimpleJSON;
		toSettings.useZip = this.useZip;
		
		return toSettings;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.compress = json.compress;
		this.exportAssets = json.exportAssets;
		this.fileName = json.fileName;
		this.filePath = json.filePath;
		this.useSimpleJSON = json.useSimpleJSON;
		this.useZip = json.useZip;
	}
	
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.compress = this.compress;
		json.exportAssets = this.exportAssets;
		json.fileName = this.fileName;
		json.filePath = this.filePath;
		json.useSimpleJSON = this.useSimpleJSON;
		json.useZip = this.useZip;
		
		return json;
	}
	
}