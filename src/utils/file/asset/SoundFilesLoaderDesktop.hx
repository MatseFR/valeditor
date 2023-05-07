package utils.file.asset;
import openfl.filesystem.File;
import openfl.media.Sound;

/**
 * ...
 * @author Matse
 */
class SoundFilesLoaderDesktop 
{
	private var _files:Array<File>;
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	
	private var _soundCallback:String->Sound->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(files:Array<File>, soundCallback:String->Sound->Void, completeCallback:Void->Void):Void
	{
		_files = files;
		_soundCallback = soundCallback;
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
			Sound.loadFromFile(_fileCurrent.nativePath).onComplete(onSoundLoadComplete).onError(onSoundLoadError);
		}
		else
		{
			_completeCallback();
			
			_files = null;
			_fileCurrent = null;
			_soundCallback = null;
			_completeCallback = null;
		}
	}
	
	private function onSoundLoadComplete(sound:Sound):Void
	{
		_soundCallback(_fileCurrent.nativePath, sound);
		nextFile();
	}
	
	private function onSoundLoadError(error:Dynamic):Void
	{
		trace("SoundFilesLoaderDesktop failed to load " + _fileCurrent.name);
		nextFile();
	}
	
}