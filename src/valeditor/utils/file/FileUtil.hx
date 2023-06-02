package valeditor.utils.file;

#if desktop
import openfl.filesystem.File;
#end

/**
 * ...
 * @author Matse
 */
class FileUtil 
{
	#if desktop
	public static function getFilesFromDirectory(directory:File, allowedExtensions:Array<String> = null, fileList:Array<File> = null):Array<File>
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
}