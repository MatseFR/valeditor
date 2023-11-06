package valeditor.utils.file.asset;
import haxe.io.Bytes;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class BitmapFilesLoader 
{
	public var isRunning(default, null):Bool;
	
	private var _files:Array<FileReference> = new Array<FileReference>();
	private var _fileIndex:Int;
	private var _fileCurrent:FileReference;
	
	private var _imageCallback:String->BitmapData->Bytes->Void;
	private var _completeCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.isRunning = false;
		
		if (this._fileCurrent != null)
		{
			this._fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			this._fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		}
		
		this._files.resize(0);
		this._fileCurrent = null;
		this._imageCallback = null;
		this._completeCallback = null;
	}
	
	public function addFile(file:FileReference):Void
	{
		this._files[this._files.length] = file;
	}
	
	public function addFiles(files:Array<FileReference>):Void
	{
		for (file in files)
		{
			this._files[this._files.length] = file;
		}
	}
	
	public function start(imageCallback:String->BitmapData->Bytes->Void, ?completeCallback:Void->Void):Void
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
			if (this._fileCurrent.data == null)
			{
				this._fileCurrent.addEventListener(Event.COMPLETE, onFileLoadComplete);
				this._fileCurrent.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
				this._fileCurrent.load();
			}
			else
			{
				onFileLoadComplete(null);
			}
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
	
	private function onFileLoadComplete(evt:Event):Void
	{
		if (this.isRunning)
		{
			this._fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			this._fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			
			BitmapData.loadFromBytes(this._fileCurrent.data).onComplete(onImageLoadComplete).onError(onImageLoadError);
		}
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		if (this.isRunning)
		{
			this._fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			this._fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			
			trace("ImageFilesLoader failed to load " + this._fileCurrent.name);
			
			nextFile();
		}
	}
	
	private function onImageLoadComplete(bmd:BitmapData):Void
	{
		if (this.isRunning)
		{
			this._imageCallback(this._fileCurrent.name, bmd, this._fileCurrent.data);
			nextFile();
		}
		else
		{
			bmd.dispose();
		}
	}
	
	private function onImageLoadError(error:Dynamic):Void
	{
		if (this.isRunning)
		{
			trace("ImageFilesLoader failed to load " + this._fileCurrent.name);
			nextFile();
		}
	}
	
}