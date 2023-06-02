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
		_files = files;
		_binaryCallback = binaryCallback;
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
			_bytes = new ByteArray();
			_fileStream.readBytes(_bytes, 0, _fileStream.bytesAvailable);
			_fileStream.close();
			
			_binaryCallback(_fileCurrent.nativePath, _bytes);
			_bytes = null;
			
			nextFile();
		}
		else
		{
			var completeCallback:Void->Void = _completeCallback;
			_files = null;
			_fileCurrent = null;
			_binaryCallback = null;
			_completeCallback = null;
			
			completeCallback();
		}
	}
	
}