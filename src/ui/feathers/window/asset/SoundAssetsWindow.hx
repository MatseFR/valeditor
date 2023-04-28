package ui.feathers.window.asset;
import ui.feathers.window.asset.AssetsWindow;
import valedit.asset.AssetLib;
import feathers.data.ListViewItemState;
import feathers.utils.DisplayObjectRecycler;
import openfl.media.Sound;
import openfl.net.FileFilter;
import ui.feathers.renderers.SoundAssetItemRenderer;
#if desktop
import openfl.filesystem.File;
import utils.file.SoundFilesLoaderDesktop;
#else
import openfl.net.FileReference;
import utils.file.SoundFilesLoader;
#end
import valedit.asset.SoundAsset;

/**
 * ...
 * @author Matse
 */
class SoundAssetsWindow extends AssetsWindow<SoundAsset>
{
	#if desktop
	private var _soundLoader:SoundFilesLoaderDesktop = new SoundFilesLoaderDesktop();
	#else
	private var _soundLoader:SoundFilesLoader = new SoundFilesLoader();
	#end
	
	public function new() 
	{
		super();
	}
	
	@:access(valedit.asset.AssetLib)
	override function initialize():Void 
	{
		super.initialize();
		
		#if flash
		_extensionList = ["mp3", "wav"];
		_filterList = [new FileFilter("Sounds (*.mp3, *.wav)", "*.mp3;*.wav")];
		#else
		_extensionList = ["ogg", "wav"];
		_filterList = [new FileFilter("Sounds (*.ogg, *.wav)", "*.ogg;*.wav")];
		#end
		
		_assetList.dataProvider = AssetLib._soundCollection;
		
		var recycler = DisplayObjectRecycler.withFunction(() -> {
			return new SoundAssetItemRenderer();
		});
		
		recycler.update = (itemRenderer:SoundAssetItemRenderer, state:ListViewItemState) -> {
			itemRenderer.asset = state.data;
		};
		
		_assetList.itemRendererRecycler = recycler;
		_assetList.itemToText = function(item:Dynamic):String
		{
			return item.name;
		};
		
		controlsEnable();
	}
	
	private function soundLoadComplete(path:String, sound:Sound):Void
	{
		AssetLib.createSound(path, sound);
	}
	
	#if desktop
	override function onAddFilesComplete(files:Array<File>):Void 
	{
		_soundLoader.start(files, soundLoadComplete, enableUI);
	}
	
	override function onAddFolderComplete(files:Array<File>):Void 
	{
		_soundLoader.start(files, soundLoadComplete, enableUI);
	}
	#else
	override function onAddFilesComplete(files:Array<FileReference>):Void
	{
		_soundLoader.start(files, soundLoadComplete, enableUI);
	}
	#end
	
}