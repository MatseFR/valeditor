package valeditor.utils.file;
#if (desktop || air)
import openfl.events.Event;
import openfl.filesystem.File;

/**
 * ...
 * @author Matse
 */
class FolderOpenerDesktop 
{
	private var _file:File = new File();
	private var _extensionList:Array<String>;
	
	private var _completeCallback:Array<File>->Void;
	private var _cancelCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(completeCallback:Array<File>->Void, cancelCallback:Void->Void, extensions:Array<String> = null, dialogTitle:String = "Select folder"):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		this._extensionList = extensions;
		
		this._file.addEventListener(Event.SELECT, onFolderSelect);
		this._file.addEventListener(Event.CANCEL, onFolderCancel);
		
		this._file.browseForDirectory("select folder");
	}
	
	private function onFolderSelect(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFolderSelect);
		this._file.removeEventListener(Event.CANCEL, onFolderCancel);
		
		_completeCallback(FileUtil.getFilesFromDirectory(this._file, this._extensionList));
	}
	
	private function onFolderCancel(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFolderSelect);
		this._file.removeEventListener(Event.CANCEL, onFolderCancel);
		
		_cancelCallback();
	}
	
}
#end