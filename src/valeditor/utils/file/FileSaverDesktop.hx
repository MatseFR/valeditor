package valeditor.utils.file;
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
	
	private var _completeCallback:String->Void;
	private var _cancelCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this._data = null;
		this._completeCallback = null;
		this._cancelCallback = null;
	}
	
	public function start(data:Dynamic, completeCallback:String->Void, cancelCallback:Void->Void, path:String = null, browseForSave:Bool = true, dialogTitle:String = "Save as"):Void
	{
		this._data = data;
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		this._file.addEventListener(Event.SELECT, onFileSelected);
		this._file.addEventListener(Event.CANCEL, onFileCancelled);
		
		if (path != null)
		{
			this._file.resolvePath(path);
		}
		
		if (browseForSave)
		{
			this._file.browseForSave(dialogTitle);
		}
		else
		{
			onFileSelected(null);
		}
	}
	
	private function onFileSelected(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._fileStream.open(this._file, FileMode.WRITE);
		
		if (Std.isOfType(this._data, String))
		{
			this._fileStream.writeUTFBytes(this._data);
		}
		else if (Std.isOfType(_data, ByteArrayData))
		{
			this._fileStream.writeBytes(this._data);
		}
		
		this._fileStream.close();
		this._data = null;
		
		this._completeCallback(this._file.nativePath);
	}
	
	private function onFileCancelled(evt:Event):Void
	{
		this._file.removeEventListener(Event.SELECT, onFileSelected);
		this._file.removeEventListener(Event.CANCEL, onFileCancelled);
		
		this._cancelCallback();
	}
	
}