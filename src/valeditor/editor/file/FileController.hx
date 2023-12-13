package valeditor.editor.file;
import openfl.filesystem.FileMode;
import openfl.utils.ByteArray;
#if desktop
import openfl.filesystem.File;
import openfl.filesystem.FileStream;
import valeditor.utils.file.FileOpenerDesktop;
import valeditor.utils.file.FileSaverDesktop;
#else
import openfl.net.FileReference;
import valeditor.utils.file.FileOpener;
import valeditor.utils.file.FileSaver;
#end

/**
 * ...
 * @author Matse
 */
class FileController 
{
	#if desktop
	static private var _fileOpener:FileOpenerDesktop = new FileOpenerDesktop();
	static private var _fileSaver:FileSaverDesktop = new FileSaverDesktop();
	static private var _fileStream:FileStream = new FileStream();
	#else
	static private var _fileOpener:FileOpener = new FileOpener(true);
	static private var _fileSaver:FileSaver = new FileSaver();
	#end
	
	static private var _completeCallback:String->Void;
	static private var _cancelCallback:Void->Void;
	
	static public function open(?completeCallback:String->Void, ?cancelCallback:Void->Void):Void
	{
		_completeCallback = completeCallback;
		_cancelCallback = cancelCallback;
		#if desktop
		_fileOpener.start(onOpenComplete, onOpenCancel);
		#else
		_fileOpener.start(onOpenComplete, onOpenCancel);
		#end
	}
	
	#if desktop
	static public function openFile(file:File, ?completeCallback:String->Void):Void
	{
		_completeCallback = completeCallback;
		onOpenComplete(file);
	}
	#else
	static public function openFile(file:FileReference, ?completeCallback:String->Void):Void
	{
		_completeCallback = completeCallback;
		onOpenComplete(file);
	}
	#end
	
	#if desktop
	static private function onOpenComplete(file:File):Void
	{
		var ba:ByteArray = new ByteArray();
		_fileStream.open(file, FileMode.READ);
		_fileStream.readBytes(ba, 0, _fileStream.bytesAvailable);
		_fileStream.close();
		ValEditor.fromZipSave(ba);
		
		if (_completeCallback != null)
		{
			_completeCallback(file.nativePath);
		}
		
		_fileOpener.clear();
	}
	#else
	static private function onOpenComplete(file:FileReference):Void
	{
		ValEditor.fromZipSave(file.data);
		
		if (_completeCallback != null)
		{
			_completeCallback(file.name);
		}
		
		_fileOpener.clear();
	}
	#end
	
	static private function onOpenCancel():Void
	{
		if (_cancelCallback != null)
		{
			_cancelCallback();
		}
		
		_fileOpener.clear();
	}
	
	static public function save(forceBrowse:Bool = false):Void
	{
		var data:Dynamic = ValEditor.toZipSave();
		
		#if desktop
		_fileSaver.start(data, onSaveComplete, onSaveCancel, ValEditor.fileSettings.fullPath, ValEditor.fileSettings.filePath == null || forceBrowse);
		#else
		_fileSaver.start(data, onSaveComplete, onSaveCancel, ValEditor.fileSettings.fileName);
		#end
	}
	
	#if desktop
	static private function onSaveComplete(path:String):Void
	{
		ValEditor.fileSettings.fullPath = path;
		_fileSaver.clear();
	}
	#else
	static private function onSaveComplete(fileName:String):Void
	{
		ValEditor.fileSettings.fileName = fileName;
		_fileSaver.clear();
	}
	#end
	
	static private function onSaveCancel():Void
	{
		_fileSaver.clear();
	}
	
}