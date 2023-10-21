package valeditor.utils.file;
import openfl.events.Event;
import openfl.net.FileReference;

/**
 * ...
 * @author Matse
 */
class FileSaver 
{
	private var _fileReference:FileReference = new FileReference();
	
	private var _completeCallback:String->Void;
	private var _cancelCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._completeCallback = null;
		this._cancelCallback = null;
	}
	
	public function start(data:Dynamic, completeCallback:String->Void, cancelCallback:Void->Void, defaultFileName:String = null):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._fileReference.addEventListener(Event.SELECT, onFileSelected);
		this._fileReference.addEventListener(Event.CANCEL, onFileCancelled);
		this._fileReference.addEventListener(Event.COMPLETE, onFileCompleted);
		
		this._fileReference.save(data, defaultFileName);
	}
	
	private function onFileSelected(evt:Event):Void
	{
		this._fileReference.removeEventListener(Event.SELECT, onFileSelected);
		this._fileReference.removeEventListener(Event.CANCEL, onFileCancelled);
	}
	
	private function onFileCancelled(evt:Event):Void
	{
		this._fileReference.removeEventListener(Event.SELECT, onFileSelected);
		this._fileReference.removeEventListener(Event.CANCEL, onFileCancelled);
		this._fileReference.removeEventListener(Event.COMPLETE, onFileCompleted);
		
		this._cancelCallback();
	}
	
	private function onFileCompleted(evt:Event):Void
	{
		this._fileReference.removeEventListener(Event.COMPLETE, onFileCompleted);
		
		this._completeCallback(this._fileReference.name);
	}
	
}