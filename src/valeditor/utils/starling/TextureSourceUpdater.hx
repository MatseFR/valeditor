package valeditor.utils.starling;
import valedit.asset.BitmapAsset;
import valedit.asset.starling.StarlingTextureAsset;
import valeditor.ui.feathers.FeathersWindows;

/**
 * ...
 * @author Matse
 */
class TextureSourceUpdater 
{
	private var _asset:StarlingTextureAsset;
	private var _cancelCallback:Void->Void;
	private var _completeCallback:Void->Void;

	public function new() 
	{
		
	}
	
	public function start(asset:StarlingTextureAsset, completeCallback:Void->Void, cancelCallback:Void->Void):Void
	{
		this._asset = asset;
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		FeathersWindows.showBitmapAssets(bitmapAssetSelected, cancel, "Select Bitmap source for Texture");
	}
	
	private function bitmapAssetSelected(asset:BitmapAsset):Void
	{
		this._asset.bitmapAsset = asset;
		
		complete();
	}
	
	private function complete():Void
	{
		var completeCallback:Void->Void = this._completeCallback;
		this._asset = null;
		this._cancelCallback = null;
		this._completeCallback = null;
		
		if (completeCallback != null)
		{
			completeCallback();
		}
	}
	
	private function cancel():Void
	{
		var cancelCallback:Void->Void = this._cancelCallback;
		this._asset = null;
		this._cancelCallback = null;
		this._completeCallback = null;
		
		if (cancelCallback != null)
		{
			cancelCallback();
		}
	}
	
}