package utils.file;
import openfl.events.Event;
import openfl.net.FileFilter;
import openfl.net.FileReference;

/**
 * ...
 * @author Matse
 */
class FileOpener 
{
	private var _fileReference:FileReference = new FileReference();
	
	private var _completeCallback:FileReference->Void;
	private var _cancelCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function start(completeCallback:FileReference->Void, cancelCallback:Void->Void, ?filterList:Array<FileFilter>):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._fileReference.addEventListener(Event.SELECT, onFileSelected);
		this._fileReference.addEventListener(Event.CANCEL, onFileCancelled);
		
		this._fileReference.browse(filterList);
	}
	
	private function onFileSelected(evt:Event):Void
	{
		this._fileReference.removeEventListener(Event.SELECT, onFileSelected);
		this._fileReference.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._completeCallback(this._fileReference);
	}
	
	private function onFileCancelled(evt:Event):Void
	{
		this._fileReference.removeEventListener(Event.SELECT, onFileSelected);
		this._fileReference.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._cancelCallback();
	}
	
}