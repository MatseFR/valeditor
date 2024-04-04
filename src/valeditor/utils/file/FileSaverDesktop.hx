package valeditor.utils.file;
import haxe.io.Path;
import openfl.events.Event;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray.ByteArrayData;

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
		
		if (path != null)
		{
			if (Path.directory(path) == "")
			{
				// we have a filename but no path to it
				
				var file:File = null;
				// this can fail if you're like me right now : my work drive died and Windows documents directory isn't set to anything anymore ^^
				try
				{
					file = File.documentsDirectory.resolvePath(path);
				}
				catch (e:Any)
				{
					// nothing
				}
				
				if (file == null)
				{
					try
					{
						file = File.desktopDirectory.resolvePath(path);
					}
					catch (e:Any)
					{
						// nothing
					}
				}
				
				if (file == null)
				{
					try
					{
						file = File.applicationDirectory.resolvePath(path);
					}
					catch (e:Any)
					{
						// nothing
					}
				}
				
				if (file == null)
				{
					path = null;
				}
				else
				{
					path = file.nativePath;
				}
			}
			
			if (path != null)
			{
				this._file = this._file.resolvePath(path);
			}
		}
		
		this._file.addEventListener(Event.SELECT, onFileSelected);
		this._file.addEventListener(Event.CANCEL, onFileCancelled);
		
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
		else if (Std.isOfType(this._data, ByteArrayData))
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