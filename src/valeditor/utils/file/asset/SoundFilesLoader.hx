package valeditor.utils.file.asset;
import haxe.io.Path;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;

/**
 * ...
 * @author Matse
 */
class SoundFilesLoader 
{
	private var _files:Array<FileReference>;
	private var _fileIndex:Int;
	private var _fileCurrent:FileReference;
	
	private var _soundCallback:String->Sound->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(files:Array<FileReference>, soundCallback:String->Sound->Void, completeCallback:Void->Void):Void
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
			_fileCurrent.addEventListener(Event.COMPLETE, onFileLoadComplete);
			_fileCurrent.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			_fileCurrent.load();
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
	
	private function onFileLoadComplete(evt:Event):Void
	{
		_fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		_fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		var sound:Sound = new Sound();
		var extension:String = Path.extension(_fileCurrent.name).toLowerCase();
		if (extension == "wav")
		{
			//sound.loadPCMFromByteArray(_fileCurrent.data, 
		}
		else
		{
			sound.loadCompressedDataFromByteArray(_fileCurrent.data, _fileCurrent.data.bytesAvailable);
		}
		_soundCallback(_fileCurrent.name, sound);
		nextFile();
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		_fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		_fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		trace("SoundFilesLoader failed to load " + _fileCurrent.name);
		
		nextFile();
	}
	
}