package valeditor.editor.file;
import haxe.Json;
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
import openfl.filesystem.FileMode;
import openfl.utils.ByteArray;

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
	static private var _fileOpener:FileOpener = new FileOpener();
	static private var _fileSaver:FileSaver = new FileSaver();
	#end
	
	static public function open():Void
	{
		#if desktop
		_fileOpener.start(onOpenComplete, onOpenCancel);
		#else
		_fileOpener.start(onOpenComplete, onOpenCancel);
		#end
	}
	
	#if desktop
	static private function onOpenComplete(file:File):Void
	{
		var ba:ByteArray = new ByteArray();
		_fileStream.open(file, FileMode.READ);
		_fileStream.readBytes(ba, 0, _fileStream.bytesAvailable);
		_fileStream.close();
		ValEditor.fromZipSave(ba);
		_fileOpener.clear();
	}
	#else
	static private function onOpenComplete(file:FileReference):Void
	{
		ValEditor.fromZipSave(file.data);
		_fileOpener.clear();
	}
	#end
	
	static private function onOpenCancel():Void
	{
		_fileOpener.clear();
	}
	
	static public function save(forceBrowse:Bool = false):Void
	{
		var data:Dynamic = ValEditor.toZipSave();
		
		#if desktop
		_fileSaver.start(data, onSaveComplete, onSaveCancel, ValEditor.file.fullPath, ValEditor.file.fullPath == null || forceBrowse);
		#else
		_fileSaver.start(data, onSaveComplete, onSaveCancel, ValEditor.file.fileName);
		#end
	}
	
	#if desktop
	static private function onSaveComplete(path:String):Void
	{
		ValEditor.file.fullPath = path;
		_fileSaver.clear();
	}
	#else
	static private function onSaveComplete(fileName:String):Void
	{
		ValEditor.file.fileName = fileName;
		_fileSaver.clear();
	}
	#end
	
	static private function onSaveCancel():Void
	{
		_fileSaver.clear();
	}
	
}