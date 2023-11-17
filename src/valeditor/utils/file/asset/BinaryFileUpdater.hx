package valeditor.utils.file.asset;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.net.FileReference;
import valedit.ValEdit;
import valedit.asset.BinaryAsset;

/**
 * ...
 * @author Matse
 */
class BinaryFileUpdater 
{
	private var _asset:BinaryAsset;
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
	
	public function start(asset:BinaryAsset, file:FileReference, completeCallback:Void->Void):Void
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
		
		ValEdit.assetLib.updateBinary(this._asset, this._file.name, this._file.data);
		
		complete();
	}
	
	private function onFileLoadError(evt:IOErrorEvent):Void
	{
		this._file.removeEventListener(Event.COMPLETE, onFileLoadComplete);
		this._file.removeEventListener(IOErrorEvent.IO_ERROR, onFileLoadError);
		
		trace("BinaryFileUpdater failed to load " + this._file.name);
		
		complete();
	}
	
}