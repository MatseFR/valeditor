package utils.file.asset;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;

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
		_files = files;
		_textCallback = textCallback;
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
			_fileStream.open(_fileCurrent, FileMode.READ);
			var str:String = _fileStream.readUTFBytes(_fileStream.bytesAvailable);
			_fileStream.close();
			
			_textCallback(_fileCurrent.nativePath, str);
			nextFile();
		}
		else
		{
			var completeCallback:Void->Void = _completeCallback;
			_files = null;
			_fileCurrent = null;
			_textCallback = null;
			_completeCallback = null;
			
			completeCallback();
		}
	}
	
}