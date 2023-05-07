package utils.file;
import openfl.events.Event;
import openfl.filesystem.File;
import openfl.net.FileFilter;

/**
 * ...
 * @author Matse
 */
class FileOpenerDesktop 
{
	private var _file:File = new File();
	
	private var _completeCallback:File->Void;
	private var _cancelCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function start(completeCallback:File->Void, cancelCallback:Void->Void, filterList:Array<FileFilter> = null, path:String = null, dialogTitle:String = "Select file"):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._file.addEventListener(Event.SELECT, onFileSelected);
		this._file.addEventListener(Event.CANCEL, onFileCancelled);
		
		this._file.resolvePath(path);
		this._file.browseForOpen(dialogTitle, filterList);
	}
	
	private function onFileSelected(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._completeCallback(this._file);
	}
	
	private function onFileCancelled(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._cancelCallback();
	}
	
}