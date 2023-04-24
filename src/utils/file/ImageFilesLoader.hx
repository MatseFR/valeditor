package utils.file;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;

/**
 * ...
 * @author Matse
 */
class ImageFilesLoader 
{
	private var _files:Array<FileReference>;
	private var _fileIndex:Int;
	private var _fileCurrent:FileReference;
	
	private var _imageCallback:String->BitmapData->Void;
	private var _completeCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function start(files:Array<FileReference>, imageCallback:String->BitmapData->Void, completeCallback:Void->Void):Void
	{
		_files = files;
		_imageCallback = imageCallback;
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
			_imageCallback = null;
			_completeCallback = null;
			
			completeCallback();
		}
	}
	
	private function onFileLoadComplete(evt:Event):Void
	{
		_fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		_fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		BitmapData.loadFromBytes(_fileCurrent.data).onComplete(onImageLoadComplete).onError(onImageLoadError);
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		_fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		_fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		trace("ImageFilesLoader failed to load " + _fileCurrent.name);
		
		nextFile();
	}
	
	private function onImageLoadComplete(bmd:BitmapData):Void
	{
		_imageCallback(_fileCurrent.name, bmd);
		nextFile();
	}
	
	private function onImageLoadError(error:Dynamic):Void
	{
		trace("ImageFilesLoader failed to load " + _fileCurrent.name);
		nextFile();
	}
	
}