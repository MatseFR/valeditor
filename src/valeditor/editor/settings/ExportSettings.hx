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
	
}