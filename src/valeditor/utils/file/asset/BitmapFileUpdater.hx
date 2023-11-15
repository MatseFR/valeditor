package valeditor.utils.file.asset;
import openfl.display.BitmapData;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import valedit.asset.BitmapAsset;

/**
 * ...
 * @author Matse
 */
class BitmapFileUpdater 
{
	private var _asset:BitmapAsset;
	private var _file:FileReference;
	private var _completeCallback:Void->Void;
	
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
	
	public function start(asset:BitmapAsset, file:FileReference, completeCallback:Void->Void):Void
	{
		this._asset = asset;
		this._file = file;
		this._completeCallback = completeCallback;
		
		if (this._file.data == null)
		{
			this._file.addEventListener(Event.COMPLETE, onFileLoadComplete);
			this._file.addEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
			this._file.load();
		}
		else
		{
			onFileLoadComplete(null);
		}
	}
	
	private function onFileLoadComplete(evt:Event):Void
	{
		this._file.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._file.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		BitmapData.loadFromBytes(this._file.data).onComplete(onImageLoadComplete).onError(onImageLoadError);
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		this._file.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._file.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		trace("BitmapFileUpdater failed to load " + this._file.name);
		
		complete();
	}
	
	private function onImageLoadComplete(bmd:BitmapData):Void
	{
		this._asset.content = bmd;
		this._asset.data = this._bytes;
		this._asset.update();
		
		complete();
	}
	
	private function onImageLoadError(error:Dynamic):Void
	{
		trace("BitmapFileUpdater failed to load " + this._file.name);
		
		complete();
	}
	
}