package valeditor.utils.file;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileFilter;
import openfl.net.FileReference;

/**
 * ...
 * @author Matse
 */
class FileOpener 
{
	public var loadFile:Bool;
	
	private var _fileReference:FileReference = new FileReference();
	
	private var _completeCallback:FileReference->Void;
	private var _cancelCallback:Void->Void;
	private var _errorCallback:IOErrorEvent->Void;
	
	public function new(loadFile:Bool = false) 
	{
		this.loadFile = loadFile;
	}
	
	public function clear():Void
	{
		this._completeCallback = null;
		this._cancelCallback = null;
		this._errorCallback = null;
	}
	
	public function start(completeCallback:FileReference->Void, cancelCallback:Void->Void, ?errorCallback:IOErrorEvent->Void, ?filterList:Array<FileFilter>):Void
	{
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		this._errorCallback = errorCallback;
		
		this._fileReference.addEventListener(Event.SELECT, onFileSelected);
		this._fileReference.addEventListener(Event.CANCEL, onFileCancelled);
		
		this._fileReference.browse(filterList);
	}
	
	private function onFileSelected(evt:Event):Void
	{
		this._fileReference.removeEventListener(Event.SELECT, onFileSelected);
		this._fileReference.removeEventListener(Event.CANCEL, onFileCancelled);
		
		if (this.loadFile)
		{
			this._fileReference.addEventListener(Event.COMPLETE, onFileLoadComplete);
			this._fileReference.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			this._fileReference.load();
		}
		else
		{
			this._completeCallback(this._fileReference);
		}
	}
	
	private function onFileLoadComplete(evt:Event):Void
	{
		this._fileReference.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		this._completeCallback(this._fileReference);
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		this._fileReference.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._fileReference.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		this._errorCallback(evt);
	}
	
	private function onFileCancelled(evt:Event):Void
	{
		this._fileReference.removeEventListener(Event.SELECT, onFileSelected);
		this._fileReference.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._cancelCallback();
	}
	
}