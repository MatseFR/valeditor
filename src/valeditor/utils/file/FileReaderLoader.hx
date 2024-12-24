package valeditor.utils.file;
#if html5
import haxe.io.Path;
import js.html.Event;
import js.html.File;
import js.html.FileReader;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

/**
 * ...
 * @author Matse
 */
@:access(openfl.net.FileReference)
class FileReaderLoader 
{
	public var isRunning(default, null):Bool;
	public var numFiles(get, never):Int;
	
	private function get_numFiles():Int { return this._files.length; }
	
	private var _completeCallback:Array<FileReference>->Void;
	private var _currentFile:FileReference;
	private var _fileIndex:Int;
	private var _files:Array<File> = new Array<File>();
	private var _fileReader:FileReader = new FileReader();
	private var _loadedFiles:Array<FileReference> = new Array<FileReference>();

	public function new() 
	{
		this._fileReader.onload = onFileLoaded;
	}
	
	public function clear():Void
	{
		this._completeCallback = null;
		this._files.resize(0);
		this._fileReader.abort();
		this._loadedFiles.resize(0);
		
		this.isRunning = false;
	}
	
	public function addFile(file:File):Void
	{
		this._files[this._files.length] = file;
	}
	
	public function start(completeCallback:Array<FileReference>->Void):Void
	{
		if (this.isRunning)
		{
			trace("FileReaderLoader is already running");
		}
		
		this._completeCallback = completeCallback;
		this._fileIndex = -1;
		nextFile();
	}
	
	private function nextFile():Void
	{
		this._fileIndex++;
		if (this._fileIndex < this._files.length)
		{
			var file:File = this._files[this._fileIndex];
			this._currentFile = new FileReference();
			this._currentFile.__path = file.name;
			this._currentFile.name = file.name;
			this._currentFile.extension = Path.extension(file.name);
			this._currentFile.size = file.size;
			this._currentFile.type = file.type;
			// Set creationDate and modificationDate properties
			var lastModified = Date.fromTime(file.lastModified);
			this._currentFile.creationDate = lastModified;
			this._currentFile.modificationDate = lastModified;
			
			this._fileReader.readAsArrayBuffer(file);
		}
		else
		{
			var completeCallback:Array<FileReference>->Void = this._completeCallback;
			var loadedFiles:Array<FileReference> = this._loadedFiles.copy();
			clear();
			
			completeCallback(loadedFiles);
		}
	}
	
	private function onFileLoaded(evt:Event):Void
	{
		this._currentFile.data = ByteArray.fromArrayBuffer(this._fileReader.result);
		this._loadedFiles[this._loadedFiles.length] = this._currentFile;
		
		nextFile();
	}
	
}
#end