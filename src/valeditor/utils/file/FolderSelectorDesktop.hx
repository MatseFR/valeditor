package valeditor.utils.file;
#if (desktop || air)
import openfl.events.Event;
import openfl.filesystem.File;

/**
 * ...
 * @author Matse
 */
class FolderSelectorDesktop 
{
	private var _file:File = new File();
	
	private var _completeCallback:String->Void;
	private var _cancelCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(completeCallback:String->Void, cancelCallback:Void->Void, path:String = null, dialogTitle:String = "select folder"):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._file.addEventListener(Event.SELECT, onFolderSelected);
		this._file.addEventListener(Event.CANCEL, onFolderCancelled);
		
		if (path != null)
		{
			this._file.resolvePath(path);
		}
		
		this._file.browseForDirectory(dialogTitle);
	}
	
	private function onFolderSelected(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFolderSelected);
		this._file.removeEventListener(Event.CANCEL, onFolderSelected);
		
		this._completeCallback(this._file.nativePath);
	}
	
	private function onFolderCancelled(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFolderSelected);
		this._file.removeEventListener(Event.CANCEL, onFolderCancelled);
		
		this._cancelCallback();
	}
	
}
#end