package utils.starling;
import starling.textures.Texture;
import starling.textures.TextureAtlas;
import ui.feathers.FeathersWindows;
import valedit.asset.BitmapAsset;
import valedit.asset.TextAsset;

/**
 * ...
 * @author Matse
 */
class AtlasLoader 
{
	private var _atlasCallback:TextureAtlas->BitmapAsset->TextAsset->Void;
	private var _textureCallback:Texture-> BitmapAsset->Void;
	private var _completeCallback:Void->Void;
	private var _cancelCallback:Void->Void;
	
	private var _bitmapAsset:BitmapAsset;
	private var _textAsset:TextAsset;
	
	private var _textureParams:TextureCreationParameters = new TextureCreationParameters();
	
	public function new() 
	{
		
	}
	
	public function start(atlasCallback:TextureAtlas->BitmapAsset->TextAsset->Void, completeCallback:Void->Void, cancelCallback:Void->Void):Void
	{
		_atlasCallback = atlasCallback;
		_completeCallback = completeCallback;
		_cancelCallback = cancelCallback;
		
		FeathersWindows.showBitmapAssets(bitmapAssetSelected, cancel, "Select Bitmap source for Atlas");
	}
	
	private function bitmapAssetSelected(asset:BitmapAsset):Void
	{
		_bitmapAsset = asset;
		
		FeathersWindows.showTextAssets(textAssetSelected, cancel, "Select Xml source for Atlas");
	}
	
	private function textAssetSelected(asset:TextAsset):Void
	{
		_textAsset = asset;
		_textureParams.reset();
		
		FeathersWindows.showObjectEditWindow(_textureParams, textureParamsConfirm, cancel);
	}
	
	private function textureParamsConfirm():Void
	{
		var texture:Texture = Texture.fromBitmapData(_bitmapAsset.content, _textureParams.generateMipMaps, _textureParams.optimizeForRenderToTexture, _textureParams.scale, _textureParams.format, _textureParams.forcePotTexture);
		
		var atlas:TextureAtlas = new TextureAtlas(texture, _textAsset.content);
		_atlasCallback(atlas, _bitmapAsset, _textAsset);
		
		var completeCallback:Void->Void = _completeCallback;
		_bitmapAsset = null;
		_textAsset = null;
		_atlasCallback = null;
		_textureCallback = null;
		_completeCallback = null;
		_cancelCallback = null;
		
		completeCallback();
	}
	
	private function cancel():Void
	{
		var cancelCallback:Void->Void = _cancelCallback;
		_bitmapAsset = null;
		_textAsset = null;
		_atlasCallback = null;
		_textureCallback = null;
		_completeCallback = null;
		_cancelCallback = null;
		
		cancelCallback();
	}
	
}