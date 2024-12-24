package valeditor.utils.starling;
#if starling
import starling.textures.Texture;
import valeditor.ui.feathers.FeathersWindows;
import valedit.asset.BitmapAsset;

/**
 * ...
 * @author Matse
 */
class TextureLoader 
{
	private var _textureCallback:Texture->TextureCreationParameters->BitmapAsset->Void;
	private var _completeCallback:Void->Void;
	private var _cancelCallback:Void->Void;
	
	private var _bitmapAsset:BitmapAsset;
	
	private var _textureParams:TextureCreationParameters = TextureCreationParameters.fromPool();

	public function new() 
	{
		
	}
	
	private function clear():Void
	{
		this._bitmapAsset = null;
		this._textureCallback = null;
		this._completeCallback = null;
		this._cancelCallback = null;
	}
	
	public function resetTextureParams():Void
	{
		this._textureParams.reset();
	}
	
	public function start(textureCallback:Texture->TextureCreationParameters->BitmapAsset->Void, completeCallback:Void->Void, cancelCallback:Void->Void):Void
	{
		this._textureCallback = textureCallback;
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
		FeathersWindows.showObjectEditWindow(this._textureParams, textureParamsConfirm, selectBitmapAsset, "Texture options");
	}
	
	private function textureParamsConfirm():Void
	{
		var texture:Texture = Texture.fromBitmapData(this._bitmapAsset.content, this._textureParams.generateMipMaps, this._textureParams.optimizeForRenderToTexture, this._textureParams.scale, this._textureParams.format, this._textureParams.forcePotTexture);
		this._textureCallback(texture, this._textureParams.clone(), this._bitmapAsset);
		
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