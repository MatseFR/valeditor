package valeditor.utils.file.asset;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;

/**
 * ...
 * @author Matse
 */
class TextFilesLoaderDesktop 
{
	private var _files:Array<File>;
	private var _fileIndex:Int;
	private var _fileCurrent:File;
	private var _fileStream:FileStream = new FileStream();
	
	private var _textCallback:String->String->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(files:Array<File>, textCallback:String->String->Void, completeCallback:Void->Void):Void
	{
		this._files = files;
		this._textCallback = textCallback;
		this._completeCallback = completeCallback;
		
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
			this._files = null;
			this._fileCurrent = null;
			this._textCallback = null;
			this._completeCallback = null;
			
			completeCallback();
		}
	}
	
}