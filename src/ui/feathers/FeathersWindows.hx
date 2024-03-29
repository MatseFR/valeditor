package ui.feathers;
import feathers.core.PopUpManager;
import openfl.Lib;
import ui.feathers.window.asset.AssetBrowser;
import ui.feathers.window.asset.BinaryAssetsWindow;
import ui.feathers.window.asset.BitmapAssetsWindow;
import ui.feathers.window.asset.ObjectEditWindow;
import ui.feathers.window.asset.SoundAssetsWindow;
import ui.feathers.window.asset.TextAssetsWindow;
import valedit.asset.BinaryAsset;
import valedit.asset.BitmapAsset;
import valedit.asset.SoundAsset;
import valedit.asset.TextAsset;
#if starling
import valedit.asset.starling.StarlingAtlasAsset;
import ui.feathers.window.asset.starling.StarlingAtlasAssetsWindow;
import valedit.asset.starling.StarlingTextureAsset;
import ui.feathers.window.asset.starling.StarlingTextureAssetsWindow;
#end

/**
 * ...
 * @author Matse
 */
class FeathersWindows 
{
	// Assets
	static private var _assetBrowser:AssetBrowser;
	
	static private var _binaryAssets:BinaryAssetsWindow;
	static private var _bitmapAssets:BitmapAssetsWindow;
	static private var _soundAssets:SoundAssetsWindow;
	static private var _textAssets:TextAssetsWindow;
	#if starling
	static private var _starlingAtlasAssets:StarlingAtlasAssetsWindow;
	static private var _starlingTextureAssets:StarlingTextureAssetsWindow;
	#end
	
	// Edit
	static private var _objectEdit:ObjectEditWindow;
	
	static public function showAssetBrowser():Void
	{
		if (_assetBrowser == null)
		{
			_assetBrowser = new AssetBrowser();
		}
		
		_assetBrowser.width = Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2;
		_assetBrowser.height = Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2;
		
		PopUpManager.addPopUp(_assetBrowser, Lib.current.stage);
	}
	
	static public function showBinaryAssets(?selectionCallback:BinaryAsset->Void, ?cancelCallback:Void->Void, title:String = "Binary assets"):Void
	{
		if (_binaryAssets == null)
		{
			_binaryAssets = new BinaryAssetsWindow();
			_binaryAssets.closeOnSelection = true;
			_binaryAssets.cancelEnabled = true;
		}
		
		_binaryAssets.reset();
		_binaryAssets.title = title;
		_binaryAssets.cancelCallback = cancelCallback;
		_binaryAssets.selectionCallback = selectionCallback;
		
		_binaryAssets.width = Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2;
		_binaryAssets.height = Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2;
		
		PopUpManager.addPopUp(_binaryAssets, Lib.current.stage);
	}
	
	static public function showBitmapAssets(?selectionCallback:BitmapAsset->Void, ?cancelCallback:Void->Void, title:String = "Bitmap assets"):Void
	{
		if (_bitmapAssets == null)
		{
			_bitmapAssets = new BitmapAssetsWindow();
			_bitmapAssets.closeOnSelection = true;
			_bitmapAssets.cancelEnabled = true;
		}
		
		_bitmapAssets.reset();
		_bitmapAssets.title = title;
		_bitmapAssets.cancelCallback = cancelCallback;
		_bitmapAssets.selectionCallback = selectionCallback;
		
		_bitmapAssets.width = Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2;
		_bitmapAssets.height = Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2;
		
		PopUpManager.addPopUp(_bitmapAssets, Lib.current.stage);
	}
	
	static public function showSoundAssets(?selectionCallback:SoundAsset->Void, ?cancelCallback:Void->Void, title:String = "Sound assets"):Void
	{
		if (_soundAssets == null)
		{
			_soundAssets = new SoundAssetsWindow();
			_soundAssets.closeOnSelection = true;
			_soundAssets.cancelEnabled = true;
		}
		
		_soundAssets.reset();
		_soundAssets.title = title;
		_soundAssets.cancelCallback = cancelCallback;
		_soundAssets.selectionCallback = selectionCallback;
		
		_soundAssets.width = Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2;
		_soundAssets.height = Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2;
		
		PopUpManager.addPopUp(_soundAssets, Lib.current.stage);
	}
	
	static public function showTextAssets(?selectionCallback:TextAsset->Void, ?cancelCallback:Void->Void, title:String = "Text assets"):Void
	{
		if (_textAssets == null)
		{
			_textAssets = new TextAssetsWindow();
			_textAssets.closeOnSelection = true;
			_textAssets.cancelEnabled = true;
		}
		
		_textAssets.reset();
		_textAssets.title = title;
		_textAssets.cancelCallback = cancelCallback;
		_textAssets.selectionCallback = selectionCallback;
		
		_textAssets.width = Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2;
		_textAssets.height = Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2;
		
		PopUpManager.addPopUp(_textAssets, Lib.current.stage);
	}
	
	#if starling
	static public function showStarlingAtlasAssetsWindow(?selectionCallback:StarlingAtlasAsset->Void, ?cancelCallback:Void->Void, title:String = "Starling Atlas assets"):Void
	{
		if (_starlingAtlasAssets == null)
		{
			_starlingAtlasAssets = new StarlingAtlasAssetsWindow();
			_starlingAtlasAssets.closeOnSelection = true;
			_starlingAtlasAssets.cancelEnabled = true;
		}
		
		_starlingAtlasAssets.reset();
		_starlingAtlasAssets.title = title;
		_starlingAtlasAssets.cancelCallback = cancelCallback;
		_starlingAtlasAssets.selectionCallback = selectionCallback;
		
		_starlingAtlasAssets.width = Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2;
		_starlingAtlasAssets.height = Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2;
		
		PopUpManager.addPopUp(_starlingAtlasAssets, Lib.current.stage);
	}
	
	static public function showStarlingTextureAssetsWindow(?selectionCallback:StarlingTextureAsset->Void, ?cancelCallback:Void->Void, title:String = "Starling Texture assets"):Void
	{
		if (_starlingTextureAssets == null)
		{
			_starlingTextureAssets = new StarlingTextureAssetsWindow();
			_starlingTextureAssets.closeOnSelection = true;
			_starlingTextureAssets.cancelEnabled = true;
		}
		
		_starlingTextureAssets.reset();
		_starlingTextureAssets.title = title;
		_starlingTextureAssets.cancelCallback = cancelCallback;
		_starlingTextureAssets.selectionCallback = selectionCallback;
		
		_starlingTextureAssets.width = Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2;
		_starlingTextureAssets.height = Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2;
		
		PopUpManager.addPopUp(_starlingTextureAssets, Lib.current.stage);
	}
	#end
	
	static public function showObjectEditWindow(object:Dynamic, ?confirmCallback:Void->Void, ?cancelCallback:Void->Void, ?title:String):Void
	{
		if (_objectEdit == null)
		{
			_objectEdit = new ObjectEditWindow();
		}
		
		_objectEdit.title = title;
		_objectEdit.editObject = object;
		_objectEdit.cancelCallback = cancelCallback;
		_objectEdit.confirmCallback = confirmCallback;
		
		_objectEdit.width = Lib.current.stage.stageWidth / 2;//Lib.current.stage.stageWidth - UIConfig.POPUP_STAGE_PADDING * 2;
		_objectEdit.height = Lib.current.stage.stageHeight - UIConfig.POPUP_STAGE_PADDING * 2;
		
		PopUpManager.addPopUp(_objectEdit, Lib.current.stage);
	}
	
}