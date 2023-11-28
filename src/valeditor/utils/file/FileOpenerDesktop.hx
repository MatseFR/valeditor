package valeditor.utils.file;
import openfl.events.Event;
import openfl.filesystem.File;
import openfl.net.FileFilter;

/**
 * ...
 * @author Matse
 */
class FileOpenerDesktop 
{
	public var isRunning(get, never):Bool;
	
	private function get_isRunning():Bool { return this._isRunning; }
	
	private var _file:File = new File();
	private var _isRunning:Bool = false;
	private var _completeCallback:File->Void;
	private var _cancelCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._completeCallback = null;
		this._cancelCallback = null;
	}
	
	public function start(completeCallback:File->Void, cancelCallback:Void->Void, filterList:Array<FileFilter> = null, path:String = null, dialogTitle:String = "Select file"):Void
	{
		if (this._isRunning)
		{
			trace("FileOpenerDesktop is already running");
			return;
		}
		this._isRunning = true;
		
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._file.addEventListener(Event.SELECT, onFileSelected);
		this._file.addEventListener(Event.CANCEL, onFileCancelled);
		
		if (path != null)
		{
			this._file.resolvePath(path);
		}
		this._file.browseForOpen(dialogTitle, filterList);
	}
	
	private function onFileSelected(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._isRunning = false;
		this._completeCallback(this._file);
	}
	
	private function onFileCancelled(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._isRunning = false;
		this._cancelCallback();
	}
	
}