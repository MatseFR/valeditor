package valeditor.utils.file;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;
import openfl.net.FileReferenceList;

/**
 * ...
 * @author Matse
 */
class FilesOpener
{
	private var _fileRefList:FileReferenceList;
	
	private var _completeCallback:Array<FileReference>->Void;
	private var _cancelCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function start(completeCallback:Array<FileReference>->Void, cancelCallback:Void->Void, ?filterList:Array<FileFilter>):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._fileRefList = new FileReferenceList();
		this._fileRefList.addEventListener(Event.SELECT, onFilesSelected);
		this._fileRefList.addEventListener(Event.CANCEL, onFilesCancelled);
		this._fileRefList.browse(filterList);
	}
	
	private function onFilesSelected(evt:Event):Void
	{
		this._fileRefList.removeEventListener(Event.SELECT, onFilesSelected);
		this._fileRefList.removeEventListener(Event.CANCEL, onFilesCancelled);
		
		this._completeCallback(_fileRefList.fileList);
	}
	
	private function onFilesCancelled(evt:Event):Void
	{
		this._fileRefList.removeEventListener(Event.SELECT, onFilesSelected);
		this._fileRefList.removeEventListener(Event.CANCEL, onFilesCancelled);
		
		this._cancelCallback();
	}
	
}