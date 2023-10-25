package valeditor.utils.file.asset;
import openfl.display.BitmapData;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class BitmapFilesLoaderDesktop 
{
	private var _files:Array<File>;
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _bytes:ByteArray;// = new ByteArray();
	
	private var _imageCallback:String->BitmapData->ByteArray->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(files:Array<File>, imageCallback:String->BitmapData->ByteArray->Void, completeCallback:Void->Void):Void
	{
		this._files = files;
		this._imageCallback = imageCallback;
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
			this._fileStream.open(this._fileCurrent, FileMode.READ);
			this._bytes = new ByteArray();
			this._fileStream.readBytes(this._bytes, 0, this._fileStream.bytesAvailable);
			this._fileStream.close();
			
			BitmapData.loadFromBytes(this._bytes).onComplete(onImageLoadComplete).onError(onImageLoadError);
		}
		else
		{
			var completeCallback:Void->Void = this._completeCallback;
			this._files = null;
			this._fileCurrent = null;
			this._bytes = null;
			this._imageCallback = null;
			this._completeCallback = null;
			
			completeCallback();
		}
	}
	
	private function onImageLoadComplete(bmd:BitmapData):Void
	{
		this._imageCallback(this._fileCurrent.nativePath, bmd, this._bytes);
		nextFile();
	}
	
	private function onImageLoadError(error:Dynamic):Void
	{
		trace("ImageFilesLoaderDesktop failed to load " + this._fileCurrent.name);
		nextFile();
	}
	
}