package valeditor.editor.settings;
import haxe.io.Path;
import juggler.animation.Transitions;
import valeditor.editor.visibility.ClassVisibilitiesCollection;
import valeditor.editor.visibility.ClassVisibilityCollection;

/**
 * ...
 * @author Matse
 */
class FileSettings 
{
	static private var _POOL:Array<FileSettings> = new Array<FileSettings>();
	
	static public function fromPool():FileSettings
	{
		if (_POOL.length != 0) return _POOL.pop();
		return new FileSettings();
	}
	
	public var compress:Bool = false;
	public var customClassVisibilities:ClassVisibilitiesCollection = new ClassVisibilitiesCollection();
	public var fileName:String;
	public var filePath:String;
	public var frameRateDefault:Float = 60;
	public var fullPath(get, set):String;
	public var numFramesAutoIncrease:Bool = true;
	public var numFramesDefault:Int = 120;
	public var tweenTransitionDefault:String = Transitions.LINEAR;
	#if starling
	public var starlingSettings:StarlingSettings = new StarlingSettings();
	#end
	
	private function get_fullPath():String 
	{
		if (this.filePath == null)
		{
			return this.fileName;
		}
		return Path.join([this.filePath, this.fileName]);
	}
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
		return value;
	}

	public function new() 
	{
		this.fileName = "untitled." + ValEditor.fileExtension;
	}
	
	public function clear():Void
	{
		this.compress = false;
		this.customClassVisibilities.clear();
		this.fileName = "untitled." + ValEditor.fileExtension;
		this.filePath = null;
		this.frameRateDefault = 60;
		this.numFramesAutoIncrease = true;
		this.numFramesDefault = 120;
		this.tweenTransitionDefault = Transitions.LINEAR;
		#if starling
		this.starlingSettings.clear();
		#end
	}
	
	public function reset():Void
	{
		this.fileName = "untitled." + ValEditor.fileExtension;
		this.customClassVisibilities.clear();
	}
	
	public function pool():Void
	{
		clear();
		_POOL.push(this);
	}
	
	public function apply():Void
	{
		var collection:ClassVisibilityCollection;
		for (clss in ValEditor.classCollection)
		{
			collection = this.customClassVisibilities.get(clss.className);
			clss.visibilityCollectionFile = collection;
		}
		
		this.starlingSettings.apply();
	}
	
	public function clone(toSettings:FileSettings = null):FileSettings
	{
		if (toSettings == null) toSettings = fromPool();
		
		toSettings.compress = this.compress;
		
		this.customClassVisibilities.clone(toSettings.customClassVisibilities);
		
		toSettings.fileName = this.fileName;
		toSettings.filePath = this.filePath;
		toSettings.frameRateDefault = this.frameRateDefault;
		toSettings.numFramesAutoIncrease = this.numFramesAutoIncrease;
		toSettings.numFramesDefault = this.numFramesDefault;
		toSettings.tweenTransitionDefault = this.tweenTransitionDefault;
		
		#if starling
		this.starlingSettings.clone(toSettings.starlingSettings);
		#end
		
		return toSettings;
	}
	
	public function fromJSON(json:Dynamic):Void
	{
		this.compress = json.compress;
		
		if (json.customClassVisibilities != null)
		{
			this.customClassVisibilities.fromJSON(json.customClassVisibilities);
		}
		
		this.frameRateDefault = json.frameRateDefault;
		this.numFramesAutoIncrease = json.numFramesAutoIncrease;
		this.numFramesDefault = json.numFramesDefault;
		this.tweenTransitionDefault = json.tweenTransitionDefault;
		
		#if starling
		if (json.starlingSettings != null)
		{
			this.starlingSettings.fromJSON(json.starlingSettings);
		}
		#end
	}
	
	public function toJSON(json:Dynamic = null):Dynamic
	{
		if (json == null) json = {};
		
		json.compress = this.compress;
		
		if (this.customClassVisibilities.numClasses != 0)
		{
			json.customClassVisibilities = this.customClassVisibilities.toJSON();
		}
		
		json.frameRateDefault = this.frameRateDefault;
		json.numFramesAutoIncrease = this.numFramesAutoIncrease;
		json.numFramesDefault = this.numFramesDefault;
		json.tweenTransitionDefault = this.tweenTransitionDefault;
		
		#if starling
		json.starlingSettings = this.starlingSettings.toJSON();
		#end
		
		return json;
	}
	
}