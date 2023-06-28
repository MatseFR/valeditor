package valeditor.utils.file;
#if desktop
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.filesystem.File;

/**
 * ...
 * @author Matse
 */
class FileSelectorDesktop
{
	private var _file:File = new File();
	
	private var _completeCallback:String->Void;
	private var _cancelCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(completeCallback:String->Void, cancelCallback:Void->Void, fileMustExist:Bool, ?filterList:Array<FileFilter>, dialogTitle:String = "select file"):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._file.addEventListener(Event.SELECT, onFileSelected);
		this._file.addEventListener(Event.CANCEL, onFileCancelled);
		
		if (fileMustExist)
		{
			this._file.browseForOpen(dialogTitle, filterList);
		}
		else
		{
			this._file.browseForSave(dialogTitle);
		}
	}
	
	private function onFileSelected(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._completeCallback(this._file.nativePath);
	}
	
	private function onFileCancelled(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._cancelCallback();
	}
	
}
#end