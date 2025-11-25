package valeditor.utils.file;

#if (desktop || air)
import haxe.Json;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
#else
import openfl.net.SharedObject;
#end

/**
 * ...
 * @author Matse
 */
class FileUtil 
{
	#if (desktop || air)
	static public function getFilesFromDirectory(directory:File, allowedExtensions:Array<String> = null, fileList:Array<File> = null):Array<File>
	{
		if (fileList == null) fileList = new Array<File>();
		var files:Array<File> = directory.getDirectoryListing();
		
		for (file in files)
		{
			if (file.isDirectory)
			{
				getFilesFromDirectory(file, allowedExtensions, fileList);
			}
			else
			{
				if (allowedExtensions == null || allowedExtensions.indexOf(file.extension) != -1)
				{
					fileList.push(file);
				}
			}
		}
		
		return fileList;
	}
	#end
	
	static public function loadEditorSettings():Void
	{
		#if (desktop || air)
		var file:File = File.applicationStorageDirectory.resolvePath("editorSettings.json");
		if (file.exists)
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open(file, FileMode.READ);
			var str:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
			fileStream.close();
			var json:Dynamic = Json.parse(str);
			ValEditor.editorSettings.fromJSON(json);
		}
		#else
		var so:SharedObject = SharedObject.getLocal("valEditor");
		if (so.data.editorSettings != null)
		{
			ValEditor.editorSettings.fromJSON(so.data.editorSettings);
		}
		#end
	}
	
	static public function saveEditorSettings():Void
	{
		var json:Dynamic = ValEditor.editorSettings.toJSON();
		
		#if (desktop || air)
		var str:String = Json.stringify(json);
		var file:File = File.applicationStorageDirectory.resolvePath("editorSettings.json");
		var fileStream:FileStream = new FileStream();
		fileStream.open(file, FileMode.WRITE);
		fileStream.writeUTFBytes(str);
		fileStream.close();
		#else
		var so:SharedObject = SharedObject.getLocal("valEditor");
		so.data.editorSettings = json;
		so.flush();
		#end
	}
	
}