package valeditor.utils.file.asset;
import haxe.io.Path;
import lime.media.AudioBuffer;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class SoundFilesLoader 
{
	private var _files:Array<FileReference>;
	private var _fileIndex:Int;
	private var _fileCurrent:FileReference;
	
	private var _soundCallback:String->Sound->ByteArray->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(files:Array<FileReference>, soundCallback:String->Sound->ByteArray->Void, completeCallback:Void->Void):Void
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
			this._fileCurrent = this._files[this._fileIndex];
			this._fileCurrent.addEventListener(Event.COMPLETE, onFileLoadComplete);
			this._fileCurrent.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			this._fileCurrent.load();
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
	
	private function onFileLoadComplete(evt:Event):Void
	{
		this._fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		var buffer:AudioBuffer = AudioBuffer.fromBytes(this._fileCurrent.data);
		var sound:Sound = Sound.fromAudioBuffer(buffer);
		
		//var sound:Sound = new Sound();
		//var extension:String = Path.extension(_fileCurrent.name).toLowerCase();
		//if (extension == "wav")
		//{
			//// TODO : find how to load a WAV file on html5 target
			////sound.loadPCMFromByteArray(_fileCurrent.data,
		//}
		//else
		//{
			//sound.loadCompressedDataFromByteArray(_fileCurrent.data, _fileCurrent.data.bytesAvailable);
		//}
		this._soundCallback(this._fileCurrent.name, sound, this._fileCurrent.data);
		nextFile();
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		this._fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		trace("SoundFilesLoader failed to load " + this._fileCurrent.name);
		
		nextFile();
	}
	
}