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
	private var _files:Array<File>;
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _bytes:ByteArray;
	
	private var _binaryCallback:String->ByteArray->Void;
	private var _completeCallback:Void->Void;
	
	public function new() 
	{
		
	}
	
	public function start(files:Array<File>, binaryCallback:String->ByteArray->Void, completeCallback:Void->Void):Void
	{
		this._files = files;
		this._binaryCallback = binaryCallback;
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
			this._files = null;
			this._fileCurrent = null;
			this._binaryCallback = null;
			this._completeCallback = null;
			
			completeCallback();
		}
	}
	
}