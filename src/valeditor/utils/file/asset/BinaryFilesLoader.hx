package valeditor.utils.file.asset;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class BinaryFilesLoader 
{
	private var _files:Array<FileReference>;
	private var _fileIndex:Int;
	private var _fileCurrent:FileReference;	
	
	private var _binaryCallback:String->ByteArray->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(files:Array<FileReference>, binaryCallback:String->ByteArray->Void, completeCallback:Void->Void):Void
	{
		this._files = files;
		this._binaryCallback = binaryCallback;
		this._completeCallback = completeCallback;
		
		this._fileIndex = -1;
		nextFile();
	}
	
	private function nextFile():Void
	{
		this._fileIndex++;
		if (this._fileIndex < this._files.length)
		{
			this._fileCurrent = this._files[this._fileIndex];
			this._fileCurrent.addEventListener(Event.COMPLETE, onFileLoadComplete);
			this._fileCurrent.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			this._fileCurrent.load();
		}
		else
		{
			var completeCallback:Void->Void = this._completeCallback;
			this._files = null;
			this._fileCurrent = null;
			this._binaryCallback = null;
			this._completeCallback = null;
			
			completeCallback();
		}
	}
	
	private function onFileLoadComplete(evt:Event):Void
	{
		this._fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		this._binaryCallback(this._fileCurrent.name, this._fileCurrent.data);
		nextFile();
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		this._fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		trace("BinaryFilesLoader failed to load " + this._fileCurrent.name);
		nextFile();
	}
	
}