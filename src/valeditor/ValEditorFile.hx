package valeditor;
import haxe.io.Path;
import juggler.animation.Transitions;
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
	
	public var exportSettings(default, null):ExportSettings = new ExportSettings();
	public var fileName:String;
	public var filePath:String;
	public var fullPath(get, set):String;
	public var numFramesAutoIncrease:Bool = true;
	public var numFramesDefault:Int = 120;
	public var tweenTransitionDefault:String = Transitions.LINEAR;
	
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
	
	public function fromJSON(json:Dynamic):Void
	{
		this.exportSettings.fromJSON(json.exportSettings);
		this.numFramesAutoIncrease = json.numFramesAutoIncrease;
		this.numFramesDefault = json.numFramesDefault;
		this.tweenTransitionDefault = json.tweenTransitionDefault;
	}
	
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.exportSettings = this.exportSettings.toJSON();
		json.numFramesAutoIncrease = this.numFramesAutoIncrease;
		json.numFramesDefault = this.numFramesDefault;
		json.tweenTransitionDefault = this.tweenTransitionDefault;
		
		return json;
	}
	
}