package valeditor.utils.starling;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import valeditor.ui.feathers.FeathersWindows;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;

/**
 * ...
 * @author Matse
 */
class AtlasLoader 
{
	private var _atlasCallback:TextureAtlas->TextureCreationParameters->BitmapAsset->TextAsset->Void;
	private var _textureCallback:Texture->TextureCreationParameters->BitmapAsset->Void;
	private var _completeCallback:Void->Void;
	private var _cancelCallback:Void->Void;
	
	private var _bitmapAsset:BitmapAsset;
	private var _textAsset:TextAsset;
	
	private var _textureParams:TextureCreationParameters = TextureCreationParameters.fromPool();
	
	public function new() 
	{
		
	}
	
	private function clear():Void
	{
		this._bitmapAsset = null;
		this._textAsset = null;
		this._atlasCallback = null;
		this._textureCallback = null;
		this._completeCallback = null;
		this._cancelCallback = null;
	}
	
	public function resetTextureParams():Void
	{
		this._textureParams.reset();
	}
	
	public function start(atlasCallback:TextureAtlas->TextureCreationParameters->BitmapAsset->TextAsset->Void, completeCallback:Void->Void, cancelCallback:Void->Void):Void
	{
		this._atlasCallback = atlasCallback;
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
		this._textureParams.reset();
		
		FeathersWindows.showObjectEditWindow(this._textureParams, textureParamsConfirm, selectTextAsset);
	}
	
	private function textureParamsConfirm():Void
	{
		var texture:Texture = Texture.fromBitmapData(this._bitmapAsset.content, this._textureParams.generateMipMaps, this._textureParams.optimizeForRenderToTexture, this._textureParams.scale, this._textureParams.format, this._textureParams.forcePotTexture);
		
		var atlas:TextureAtlas = new TextureAtlas(texture, this._textAsset.content);
		this._atlasCallback(atlas, this._textureParams.clone(), this._bitmapAsset, this._textAsset);
		
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