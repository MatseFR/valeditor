package valeditor.utils.starling;
#if starling
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
	
	private var _bitmapAsset:BitmapAsset;
	private var _textureParams:TextureCreationParameters = TextureCreationParameters.fromPool();

	public function new() 
	{
		
	}
	
	private function clear():Void
	{
		this._asset = null;
		this._cancelCallback = null;
		this._completeCallback = null;
	}
	
	public function start(asset:StarlingTextureAsset, completeCallback:Void->Void, cancelCallback:Void->Void):Void
	{
		this._asset = asset;
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		selectBitmapAsset();
	}
	
	private function selectBitmapAsset():Void
	{
		FeathersWindows.showBitmapAssets(bitmapAssetSelected, cancel, "Select Bitmap source for Texture");
	}
	
	private function bitmapAssetSelected(asset:BitmapAsset):Void
	{
		this._bitmapAsset = asset;
		
		selectTextureParameters();
	}
	
	private function selectTextureParameters():Void
	{
		if (this._asset.textureParams != null)
		{
			this._asset.textureParams.clone(this._textureParams);
		}
		
		FeathersWindows.showObjectEditWindow(this._textureParams, textureParamsConfirm, selectBitmapAsset);
	}
	
	private function textureParamsConfirm():Void
	{
		if (this._asset.textureParams != null)
		{
			this._textureParams.clone(this._asset.textureParams);
		}
		else
		{
			this._asset.textureParams = this._textureParams.clone();
		}
		this._asset.assetUpdate(this._bitmapAsset);
		
		complete();
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
	
	private function cancel():Void
	{
		var cancelCallback:Void->Void = this._cancelCallback;
		clear();
		
		if (cancelCallback != null)
		{
			cancelCallback();
		}
	}
	
}
#end