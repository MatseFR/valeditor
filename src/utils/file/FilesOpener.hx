package utils.file;
import openfl.events.Event;
import openfl.events.EventDispatcher;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.net.FileReferenceList;

/**
 * ...
 * @author Matse
 */
class FilesOpener
{
	private var _fileRefList:FileReferenceList = new FileReferenceList();
	
	private var _completeCallback:Array<FileReference>->Void;
	private var _cancelCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function start(completeCallback:Array<FileReference>->Void, cancelCallback:Void->Void, ?filterList:Array<FileFilter>):Void
	{
		_completeCallback = completeCallback;
		_cancelCallback = cancelCallback;
		
		_fileRefList.addEventListener(Event.SELECT, onFilesSelected);
		_fileRefList.addEventListener(Event.CANCEL, onFilesCancelled);
		_fileRefList.browse(filterList);
	}
	
	private function onFilesSelected(evt:Event):Void
	{
		_fileRefList.removeEventListener(Event.SELECT, onFilesSelected);
		_fileRefList.removeEventListener(Event.CANCEL, onFilesCancelled);
		
		_completeCallback(_fileRefList.fileList);
	}
	
	private function onFilesCancelled(evt:Event):Void
	{
		_fileRefList.removeEventListener(Event.SELECT, onFilesSelected);
		_fileRefList.removeEventListener(Event.CANCEL, onFilesCancelled);
		
		_cancelCallback();
	}
	
}