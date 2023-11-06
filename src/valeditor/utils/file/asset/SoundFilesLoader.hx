package valeditor.utils.file.asset;
import haxe.io.Bytes;
import lime.media.AudioBuffer;
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
	public var isRunning(default, null):Bool;
	
	private var _files:Array<FileReference> = new Array<FileReference>();
	private var _fileIndex:Int;
	private var _fileCurrent:FileReference;
	
	private var _soundCallback:String->Sound->Bytes->Void;
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
		this._soundCallback = null;
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
	
	public function start(soundCallback:String->Sound->Bytes->Void, ?completeCallback:Void->Void):Void
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
			
			var bytes:Bytes = this._fileCurrent.data;
			var buffer:AudioBuffer = AudioBuffer.fromBytes(bytes);
			var sound:Sound = Sound.fromAudioBuffer(buffer);
			
			this._soundCallback(this._fileCurrent.name, sound, bytes);
			nextFile();
		}
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		if (this.isRunning)
		{
			this._fileCurrent.removeEventListener(Event.COMPLETE, onFileLoadComplete);
			this._fileCurrent.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			
			trace("SoundFilesLoader failed to load " + this._fileCurrent.name);
			
			nextFile();
		}
	}
	
}