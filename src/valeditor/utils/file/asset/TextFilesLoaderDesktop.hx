package valeditor.utils.file.asset;
#if (desktop || air)
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;

/**
 * ...
 * @author Matse
 */
class TextFilesLoaderDesktop 
{
	public var isRunning(default, null):Bool;
	
	private var _files:Array<File> = new Array<File>();
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _textCallback:String->String->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.isRunning = false;
		
		this._files.resize(0);
		this._fileCurrent = null;
		this._textCallback = null;
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
	
	public function start(textCallback:String->String->Void, completeCallback:Void->Void):Void
	{
		this._textCallback = textCallback;
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
			var str:String = this._fileStream.readUTFBytes(this._fileStream.bytesAvailable);
			this._fileStream.close();
			
			this._textCallback(this._fileCurrent.nativePath, str);
			nextFile();
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
	
}
#end