package valeditor.utils.file.asset;
import flash.filesystem.FileStream;
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
	private var _files:Array<File>;
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _bytes:ByteArray;
	
	private var _soundCallback:String->Sound->ByteArray->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(files:Array<File>, soundCallback:String->Sound->ByteArray->Void, completeCallback:Void->Void):Void
	{
		this._files = files;
		this._soundCallback = soundCallback;
		this._completeCallback = completeCallback;
		
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
			this._files = null;
			this._fileCurrent = null;
			this._soundCallback = null;
			this._completeCallback = null;
			
			completeCallback();
		}
	}
	
	private function onSoundLoadComplete(sound:Sound):Void
	{
		this._soundCallback(this._fileCurrent.nativePath, sound, this._bytes);
		nextFile();
	}
	
	private function onSoundLoadError(error:Dynamic):Void
	{
		trace("SoundFilesLoaderDesktop failed to load " + this._fileCurrent.name);
		nextFile();
	}
	
}