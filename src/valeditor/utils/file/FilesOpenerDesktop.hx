package valeditor.utils.file;
import openfl.events.Event;
import openfl.events.FileListEvent;
import openfl.filesystem.File;
import openfl.net.FileFilter;

/**
 * ...
 * @author Matse
 */
class FilesOpenerDesktop 
{
	private var _file:File = new File();
	
	private var _completeCallback:Array<File>->Void;
	private var _cancelCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(completeCallback:Array<File>->Void, cancelCallback:Void->Void, filterList:Array<FileFilter> = null, path:String = null, dialogTitle:String = "Select file(s)"):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._file.addEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
		this._file.addEventListener(Event.CANCEL, onFilesCancelled);
		
		this._file.resolvePath(path);
		this._file.browseForOpenMultiple(dialogTitle, filterList);
	}
	
	private function onFilesSelected(evt:FileListEvent):Void
	{
		this._file.removeEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
		this._file.removeEventListener(Event.CANCEL, onFilesCancelled);
		
		this._completeCallback(evt.files);
	}
	
	private function onFilesCancelled(evt:Event):Void
	{
		this._file.removeEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
		this._file.removeEventListener(Event.CANCEL, onFilesCancelled);
		
		this._cancelCallback();
	}
	
}