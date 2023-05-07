package utils.file;
import openfl.events.Event;
import openfl.filesystem.File;

/**
 * ...
 * @author Matse
 */
class FolderOpenerDesktop 
{
	private var _file:File;
	private var _extensionList:Array<String>;
	
	private var _completeCallback:Array<File>->Void;
	private var _cancelCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(completeCallback:Array<File>->Void, cancelCallback:Void->Void, extensions:Array<String> = null, dialogTitle:String = "Select folder"):Void
	{
		_completeCallback = completeCallback;
		_cancelCallback = cancelCallback;
		_extensionList = extensions;
		
		_file.addEventListener(Event.SELECT, onFolderSelect);
		_file.addEventListener(Event.CANCEL, onFolderCancel);
		
		_file.browseForDirectory("select folder");
	}
	
	private function onFolderSelect(evt:Event):Void
	{
		_file.removeEventListener(Event.SELECT, onFolderSelect);
		_file.removeEventListener(Event.CANCEL, onFolderCancel);
		
		_completeCallback(FileUtil.getFilesFromDirectory(_file, _extensionList));
	}
	
	private function onFolderCancel(evt:Event):Void
	{
		_file.removeEventListener(Event.SELECT, onFolderSelect);
		_file.removeEventListener(Event.CANCEL, onFolderCancel);
		
		_cancelCallback();
	}
	
}