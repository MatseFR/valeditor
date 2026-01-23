package valeditor.editor.file;
import openfl.net.FileFilter;
#if (desktop || air)
import openfl.filesystem.File;
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
	#if (desktop || air)
	static private var _fileOpener:FileOpenerDesktop = new FileOpenerDesktop();
	static private var _fileSaver:FileSaverDesktop = new FileSaverDesktop();
	#else
	static private var _fileOpener:FileOpener = new FileOpener(true);
	static private var _fileSaver:FileSaver = new FileSaver();
	#end
	
	static private var _completeCallback:String->Void;
	static private var _cancelCallback:Void->Void;
	
	#if (desktop || air)
	static public function open(completeCallback:File->Void, ?cancelCallback:Void->Void, ?filterList:Array<FileFilter>, ?path:String, dialogTitle:String = "Select file"):Void
	{
		_fileOpener.start(completeCallback, cancelCallback, filterList, path, dialogTitle);
	}
	#else
	static public function open(completeCallback:FileReference->Void, ?cancelCallback:Void->Void, ?filterList:Array<FileFilter>):Void
	{
		_fileOpener.start(completeCallback, cancelCallback, filterList);
	}
	#end
	
	#if (desktop || air)
	static public function save(data:Dynamic, completeCallback:String->Void, ?cancelCallback:Void->Void, ?path:String, forceBrowse:Bool = false, ?forcedExtenstion:String, dialogTitle:String = "Save as"):Void
	{
		_fileSaver.start(data, completeCallback, cancelCallback, path, path == null || forceBrowse, forcedExtenstion, dialogTitle);
	}
	#else
	static public function save(data:Dynamic, completeCallback:String->Void, ?cancelCallback:Void->Void, ?fileName:String):Void
	{
		_fileSaver.start(data, completeCallback, cancelCallback, fileName);
	}
	#end
}