package utils.file;
import openfl.display.BitmapData;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class ImageFilesLoaderDesktop 
{
	private var _files:Array<File>;
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _bytes:ByteArray = new ByteArray();
	
	private var _imageCallback:String->BitmapData->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(files:Array<File>, imageCallback:String->BitmapData->Void, completeCallback:Void->Void):Void
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
			_fileStream.open(_fileCurrent, FileMode.READ);
			_fileStream.readBytes(_bytes, 0, _fileStream.bytesAvailable);
			_fileStream.close();
			
			BitmapData.loadFromBytes(_bytes).onComplete(onImageLoadComplete).onError(onImageLoadError);
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
	
	private function onImageLoadComplete(bmd:BitmapData):Void
	{
		_imageCallback(_fileCurrent.nativePath, bmd);
		nextFile();
	}
	
	private function onImageLoadError(error:Dynamic):Void
	{
		trace("ImageFilesLoaderDesktop failed to load " + _fileCurrent.name);
		nextFile();
	}
	
}