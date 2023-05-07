package utils.file;
import openfl.events.Event;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class FileSaverDesktop 
{
	private var _file:File = new File();
	private var _fileStream:FileStream = new FileStream();
	
	private var _data:Dynamic;
	
	private var _completeCallback:Void->Void;
	private var _cancelCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function start(data:Dynamic, completeCallback:Void->Void, cancelCallback:Void->Void, path:String = null, dialogTitle:String = "Save as"):Void
	{
		this._data = data;
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._file.addEventListener(Event.SELECT, onFileSelected);
		this._file.addEventListener(Event.CANCEL, onFileCancelled);
		
		this._file.resolvePath(path);
		this._file.browseForSave(dialogTitle);
	}
	
	private function onFileSelected(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		_fileStream.open(_file, FileMode.WRITE);
		
		if (Std.isOfType(_data, String))
		{
			_fileStream.writeUTFBytes(data);
		}
		else if (Std.isOfType(_data, ByteArray))
		{
			_fileStream.writeBytes(_data);
		}
		
		_fileStream.close();
		_data = null;
		
		this._completeCallback();
	}
	
	private function onFileCancelled(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._cancelCallback();
	}
	
}