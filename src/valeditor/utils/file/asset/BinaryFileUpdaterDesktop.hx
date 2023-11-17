package valeditor.utils.file.asset;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;
import valedit.ValEdit;
import valedit.asset.BinaryAsset;

/**
 * ...
 * @author Matse
 */
class BinaryFileUpdaterDesktop 
{
	private var _asset:BinaryAsset;
	private var _file:File;
	private var _completeCallback:Void->Void;
	
	private var _bytes:ByteArray;
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
	
	public function start(asset:BinaryAsset, file:File, completeCallback:Void->Void):Void
	{
		this._asset = asset;
		this._file = file;
		this._completeCallback = completeCallback;
		
		this._fileStream.open(this._file, FileMode.READ);
		this._bytes = new ByteArray();
		this._fileStream.readBytes(this._bytes, 0, this._fileStream.bytesAvailable);
		this._fileStream.close();
		
		ValEdit.assetLib.updateBinary(this._asset, this._file.nativePath, this._bytes);
		
		complete();
	}
	
}