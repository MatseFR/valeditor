package utils.file;
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
		_files = files;
		_binaryCallback = binaryCallback;
		_completeCallback = completeCallback;
		
		_fileIndex = -1;
		nextFile();
	}
	
	private function nextFile():Void
	{
		_fileIndex++;
		if (_fileIndex < _files.length)
		{
			_fileCurrent = _files[_fileIndex];
			_fileCurrent.addEventListener(Event.COMPLETE, onFileLoadComplete);
			_fileCurrent.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			_fileCurrent.load();
		}
		else
		{
			var completeCallback:Void->Void = _completeCallback;
			_files = null;
			_fileCurrent = null;
			_binaryCallback = null;
			_completeCallback = null;
			
			completeCallback();
		}
	}
	
	private function onFileLoadComplete(evt:Event):Void
	{
		_fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		_fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		_binaryCallback(_fileCurrent.name, _fileCurrent.data);
		nextFile();
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		_fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		_fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		trace("BinaryFilesLoader failed to load " + _fileCurrent.name);
		nextFile();
	}
	
}