package valeditor.utils.file.asset;
#if (desktop || air)
import flash.filesystem.FileStream;
import haxe.io.Bytes;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.media.Sound;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class SoundFilesLoaderDesktop 
{
	public var isRunning(default, null):Bool;
	
	private var _files:Array<File> = new Array<File>();
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _bytes:ByteArray;
	
	private var _soundCallback:String->Sound->Bytes->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.isRunning = false;
		
		this._files.resize(0);
		this._fileCurrent = null;
		this._soundCallback = null;
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
	
	public function start(soundCallback:String->Sound->Bytes->Void, completeCallback:Void->Void):Void
	{
		this._soundCallback = soundCallback;
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
			this._fileCurrent = this._files[_fileIndex];
			this._fileStream.open(this._fileCurrent, FileMode.READ);
			this._bytes = new ByteArray();
			this._fileStream.readBytes(this._bytes, 0, this._fileStream.bytesAvailable);
			this._fileStream.close();
			
			Sound.loadFromFile(this._fileCurrent.nativePath).onComplete(onSoundLoadComplete).onError(onSoundLoadError);
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
	
	private function onSoundLoadComplete(sound:Sound):Void
	{
		if (this.isRunning)
		{
			this._soundCallback(this._fileCurrent.nativePath, sound, this._bytes);
			nextFile();
		}
	}
	
	private function onSoundLoadError(error:Dynamic):Void
	{
		trace("SoundFilesLoaderDesktop failed to load " + this._fileCurrent.nativePath);
		if (this.isRunning)
		{
			nextFile();
		}
	}
	
}
#end