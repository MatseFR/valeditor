package valeditor.utils.file.asset;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
class BinaryFilesLoaderDesktop 
{
	public var isRunnning(default, null):Bool;
	
	private var _files:Array<File> = new Array<File>();
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _bytes:ByteArray;
	
	private var _binaryCallback:String->ByteArray->Void;
	private var _completeCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function clear():Void
	{
		this.isRunnning = false;
		
		this._files.resize(0);
		this._fileCurrent = null;
		this._binaryCallback = null;
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
	
	public function start(binaryCallback:String->ByteArray->Void, completeCallback:Void->Void):Void
	{
		this._binaryCallback = binaryCallback;
		this._completeCallback = completeCallback;
		
		this.isRunnning = true;
		this._fileIndex = -1;
		nextFile();
	}
	
	private function nextFile():Void
	{
		this._fileIndex++;
		if (this._fileIndex < this._files.length)
		{
			this._fileCurrent = this._files[this._fileIndex];
			this._fileStream.open(this._fileCurrent, FileMode.READ);
			this._bytes = new ByteArray();
			this._fileStream.readBytes(this._bytes, 0, this._fileStream.bytesAvailable);
			this._fileStream.close();
			
			this._binaryCallback(this._fileCurrent.nativePath, this._bytes);
			this._bytes = null;
			
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