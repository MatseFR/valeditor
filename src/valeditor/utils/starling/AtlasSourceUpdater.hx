package valeditor.utils.starling;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;
import valedit.asset.starling.StarlingAtlasAsset;
import valeditor.ui.feathers.FeathersWindows;

/**
 * ...
 * @author Matse
 */
class AtlasSourceUpdater 
{
	private var _asset:StarlingAtlasAsset;
	private var _cancelCallback:Void->Void;
	private var _completeCallback:Void->Void;
	
	private var _bitmapAsset:BitmapAsset;
	private var _textAsset:TextAsset;
	private var _textureParams:TextureCreationParameters = TextureCreationParameters.fromPool();

	public function new() 
	{
		
	}
	
	private function clear():Void
	{
		this._asset = null;
		this._cancelCallback = null;
		this._completeCallback = null;
		
		this._bitmapAsset = null;
		this._textAsset = null;
	}
	
	public function start(asset:StarlingAtlasAsset, completeCallback:Void->Void, cancelCallback:Void->Void):Void
	{
		this._asset = asset;
		this._completeCallback = completeCallback;
		this._cancelCallback = cancelCallback;
		
		selectBitmapAsset();
	}
	
	private function selectBitmapAsset():Void
	{
		FeathersWindows.showBitmapAssets(bitmapAssetSelected, cancel, "Select Bitmap source for Atlas");
	}
	
	private function bitmapAssetSelected(asset:BitmapAsset):Void
	{
		this._bitmapAsset = asset;
		
		selectTextAsset();
	}
	
	private function selectTextAsset():Void
	{
		FeathersWindows.showTextAssets(textAssetSelected, selectBitmapAsset, "Select Xml source for Atlas");
	}
	
	private function textAssetSelected(asset:TextAsset):Void
	{
		this._textAsset = asset;
		
		selectTextureParameters();
	}
	
	private function selectTextureParameters():Void
	{
		this._asset.textureParams.clone(this._textureParams);
		FeathersWindows.showObjectEditWindow(this._textureParams, textureParamsConfirm, selectTextAsset);
	}
	
	private function textureParamsConfirm():Void
	{
		this._textureParams.clone(this._asset.textureParams);
		this._asset.bitmapAsset = this._bitmapAsset;
		this._asset.assetUpdate(this._textAsset);
		
		complete();
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
	
	private function complete():Void
	{
		var completeCallback:Void->Void = this._completeCallback;
		clear();
		
		if (completeCallback != null)
		{
			completeCallback();
		}
	}
	
}