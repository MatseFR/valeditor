package valeditor;
import haxe.io.Path;
import valeditor.editor.settings.ExportSettings;

/**
 * ...
 * @author Matse
 */
class ValEditorFile 
{
	static private var _POOL:Array<ValEditorFile> = new Array<ValEditorFile>();
	
	static public function fromPool():ValEditorFile
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new ValEditorFile();
	}
	
	public var exportSettings(default, null):ExportSettings;
	public var fileName:String;
	public var filePath:String;
	public var fullPath(get, set):String;
	
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
		this.exportSettings.clear();
		this.fullPath = null;
	}
	
	public function pool():Void
	{
		clear();
		_POOL.push(this);
	}
	
}