package utils.file;
import openfl.events.Event;
import openfl.events.FileListEvent;
import openfl.filesystem.File;
import openfl.filesystem.FileStream;
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
	
	public function start(completeCallback:Array<File>->Void, cancelCallback:Void->Void, filterList:Array<FileFilter> = null, dialogTitle:String = "Select file(s)"):Void
	{
		_completeCallback = completeCallback;
		_cancelCallback = cancelCallback;
		
		_file.addEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
		_file.addEventListener(Event.CANCEL, onFilesCancelled);
		
		_file.browseForOpenMultiple(dialogTitle, filterList);
	}
	
	private function onFilesSelected(evt:FileListEvent):Void
	{
		_file.removeEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
		_file.removeEventListener(Event.CANCEL, onFilesCancelled);
		
		_completeCallback(evt.files);
	}
	
	private function onFilesCancelled(evt:Event):Void
	{
		_file.removeEventListener(FileListEvent.SELECT_MULTIPLE, onFilesSelected);
		_file.removeEventListener(Event.CANCEL, onFilesCancelled);
		
		_cancelCallback();
	}
	
}