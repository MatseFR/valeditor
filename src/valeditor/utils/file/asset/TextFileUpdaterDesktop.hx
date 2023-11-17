package valeditor.utils.file.asset;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import valedit.ValEdit;
import valedit.asset.TextAsset;

/**
 * ...
 * @author Matse
 */
class TextFileUpdaterDesktop 
{
	private var _asset:TextAsset;
	private var _file:File;
	private var _completeCallback:Void->Void;
	
	private var _fileStream:FileStream = new FileStream();
	
	public function new() 
	{
		
	}
	
	private function clear():Void
	{
		this._asset = null;
		this._file = null;
		this._completeCallback = null;
	}
	
	private function complete():Void
	{
		var completeCallback:Void->Void = this._completeCallback;
		clear();
		if (completeCallback != null)
		{
			completeCallback();
		}
	}
	
	public function start(asset:TextAsset, file:File, completeCallback:Void->Void):Void
	{
		this._asset = asset;
		this._file = file;
		this._completeCallback = completeCallback;
		
		this._fileStream.open(this._file, FileMode.READ);
		var str:String = this._fileStream.readUTFBytes(this._fileStream.bytesAvailable);
		this._fileStream.close();
		
		ValEdit.assetLib.updateText(this._asset, this._file.nativePath, str);
		
		complete();
	}
	
}