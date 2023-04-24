package utils.starling;
import starling.textures.Texture;
import ui.feathers.FeathersWindows;
import valedit.asset.BitmapAsset;

/**
 * ...
 * @author Matse
 */
class TextureLoader 
{
	private var _textureCallback:Texture->BitmapAsset->Void;
	private var _completeCallback:Void->Void;
	private var _cancelCallback:Void->Void;
	
	private var _bitmapAsset:BitmapAsset;
	
	private var _textureParams:TextureCreationParameters = new TextureCreationParameters();

	public function new() 
	{
		
	}
	
	public function start(textureCallback:Texture->BitmapAsset->Void, completeCallback:Void->Void, cancelCallback:Void->Void):Void
	{
		_textureCallback = textureCallback;
		_completeCallback = completeCallback;
		_cancelCallback = cancelCallback;
		
		FeathersWindows.showBitmapAssets(bitmapAssetSelected, cancel, "Select Bitmap source for Texture");
	}
	
	private function bitmapAssetSelected(asset:BitmapAsset):Void
	{
		_bitmapAsset = asset;
		_textureParams.reset();
		
		FeathersWindows.showObjectEditWindow(this._textureParams, textureParamsConfirm, cancel, "Texture options");
	}
	
	private function textureParamsConfirm():Void
	{
		var texture:Texture = Texture.fromBitmapData(_bitmapAsset.content, _textureParams.generateMipMaps, _textureParams.optimizeForRenderToTexture, _textureParams.scale, _textureParams.format, _textureParams.forcePotTexture);
		_textureCallback(texture, _bitmapAsset);
		
		var completeCallback:Void->Void = _completeCallback;
		_bitmapAsset = null;
		_textureCallback = null;
		_completeCallback = null;
		_cancelCallback = null;
		
		completeCallback();
	}
	
	private function cancel():Void
	{
		var cancelCallback:Void->Void = _cancelCallback;
		_bitmapAsset = null;
		_textureCallback = null;
		_completeCallback = null;
		_cancelCallback = null;
		
		cancelCallback();
	}
	
}