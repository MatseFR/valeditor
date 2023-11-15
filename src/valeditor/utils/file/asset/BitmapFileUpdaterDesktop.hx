package valeditor.utils.file.asset;
import openfl.display.BitmapData;
import openfl.filesystem.File;
import openfl.filesystem.FileMode;
import openfl.filesystem.FileStream;
import openfl.utils.ByteArray;
import valedit.ValEdit;
import valedit.asset.BitmapAsset;

/**
 * ...
 * @author Matse
 */
class BitmapFileUpdaterDesktop 
{
	private var _asset:BitmapAsset;
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
		this._bytes = null;
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
	
	public function start(asset:BitmapAsset, file:File, completeCallback:Void->Void):Void
	{
		this._asset = asset;
		this._file = file;
		this._completeCallback = completeCallback;
		
		this._fileStream.open(this._file, FileMode.READ);
		this._bytes = new ByteArray();
		this._fileStream.readBytes(this._bytes, 0, this._fileStream.bytesAvailable);
		this._fileStream.close();
		
		BitmapData.loadFromBytes(this._bytes).onComplete(onImageLoadComplete).onError(onImageLoadError);
	}
	
	private function onImageLoadComplete(bmd:BitmapData):Void
	{
		ValEdit.assetLib.updateBitmap(this._asset, this._file.nativePath, bmd, this._bytes);
		
		complete();
	}
	
	private function onImageLoadError(error:Dynamic):Void
	{
		trace("ImageFilesLoaderDesktop failed to load " + this._file.nativePath + " error : " + error);
		
		complete();
	}
	
}