package valeditor.utils.file.asset;
#if (desktop || air)
import haxe.io.Bytes;
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
	public var isRunning(default, null):Bool;
	
	private var _files:Array<File> = new Array<File>();
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _bytes:ByteArray;// = new ByteArray();
	
	private var _imageCallback:String->BitmapData->Bytes->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.isRunning = false;
		
		this._files.resize(0);
		this._fileCurrent = null;
		this._bytes = null;
		this._imageCallback = null;
		this._completeCallback = null;
	}
	
	public function addFile(file:File):Void
	{
		this._files[this._files.length] = file;
	}
	
	public function addFiles(files:Array<File>):Void
	{
		for (file in files)
		{
			this._files[this._files.length] = file;
		}
	}
	
	public function start(imageCallback:String->BitmapData->Bytes->Void, completeCallback:Void->Void):Void
	{
		this._imageCallback = imageCallback;
		this._completeCallback = completeCallback;
		
		this.isRunning = true;
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
			clear();
			
			if (completeCallback != null)
			{
				completeCallback();
			}
		}
	}
	
	private function onImageLoadComplete(bmd:BitmapData):Void
	{
		if (this.isRunning)
		{
			this._imageCallback(this._fileCurrent.nativePath, bmd, this._bytes);
			nextFile();
		}
		else
		{
			bmd.dispose();
		}
	}
	
	private function onImageLoadError(error:Dynamic):Void
	{
		trace("ImageFilesLoaderDesktop failed to load " + this._fileCurrent.name + " error : " + error);
		if (this.isRunning)
		{
			nextFile();
		}
	}
	
}
#end